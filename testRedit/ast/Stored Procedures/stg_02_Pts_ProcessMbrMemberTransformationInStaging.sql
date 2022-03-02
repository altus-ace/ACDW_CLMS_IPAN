

CREATE PROCEDURE [ast].[stg_02_Pts_ProcessMbrMemberTransformationInStaging] -- [ast].[stg_02_Pts_ProcessMbrMemberTransformationInStaging]'2021-07-01','2021-07-01'
							(@MbrShipDataDate  DATE
							,@EffectiveDate DATE)

AS

BEGIN
BEGIN TRAN
BEGIN TRY
						DECLARE @AuditId INT;    
						DECLARE @JobStatus tinyInt = 1    
						DECLARE @JobType SmallInt = 9	  
						DECLARE @ClientKey INT	 = (SELECT ClientKey FROM lst.List_Client); 
						DECLARE @JobName VARCHAR(100) = 'IPAN MbrMember';
						DECLARE @ActionStart DATETIME2 = GETDATE();
						DECLARE @SrcName VARCHAR(100) = 'adi.Attribution'
						DECLARE @DestName VARCHAR(100) = ''
						DECLARE @ErrorName VARCHAR(100) = 'NA';
						DECLARE @InpCnt INT = -1;
						DECLARE @OutCnt INT = -1;
						DECLARE @ErrCnt INT = -1;
	SELECT				@InpCnt = COUNT(m.mbrStg2_MbrDataUrn)    
	FROM				ast.MbrStg2_MbrData m
	WHERE				DataDate = @MbrShipDataDate 
	
	SELECT				@InpCnt, @MbrShipDataDate
	
	
	EXEC				amd.sp_AceEtlAudit_Open 
						@AuditID = @AuditID OUTPUT
						, @AuditStatus = @JobStatus
						, @JobType = @JobType
						, @ClientKey = @ClientKey
						, @JobName = @JobName
						, @ActionStartTime = @ActionStart
						, @InputSourceName = @SrcName
						, @DestinationName = @DestName
						, @ErrorName = @ErrorName
						;

		BEGIN			--- More unidentified biz rules to be built here
					  					 
					/*Rule A:
						Build Job for Auto Assigned Members, ie Members with invalid NPI are auto assigned NPI using 
						their TIN: Request made by the BAs on Nov 2021*/
					/*i. Update prvNPI who is null with the assigned NPI*/
  					 
					BEGIN
					UPDATE	ast.mbrstg2_mbrdata 	
					SET		prvNPI = (CASE WHEN prvNPI IS NULL THEN Destination ELSE prvNPI END)
					FROM	ast.mbrstg2_mbrdata stg  
					JOIN	(SELECT Source,Destination,ClientKey
								FROM lst.ListAceMapping
								WHERE ClientKey = @ClientKey
								AND	  MappingTypeKey = 22
								AND	  ACTIVE = 'Y') acemapping
					ON		stg.srcTIN = acemapping.Source
					WHERE	stg.EffectiveDate = @EffectiveDate
					AND		stg.prvNPI  IS NULL;
					END
					/*ii. Update NPIReplacedFlg to 1 and iii Update prvTIN to source*/
					--SELECT  prvNPI,prvTIN,srcTIN,srcNPI,Source,Destination,NPIReplacedFlg 
					BEGIN
					UPDATE	 ast.mbrstg2_mbrdata 	
					SET		NPIReplacedFlg = 1 
							, prvTIN = acemapping.Source
					FROM	ast.mbrstg2_mbrdata stg  
					JOIN (SELECT Source,Destination,ClientKey
								FROM lst.ListAceMapping
								WHERE ClientKey = @ClientKey
								AND	  MappingTypeKey = 22
								AND	  ACTIVE = 'Y') acemapping
					ON	stg.srcTIN = acemapping.Source
					WHERE	stg.EffectiveDate = @EffectiveDate 
					AND		prvTIN IS NULL;
					END

					/*Rule B: Update stgRowStatus validity for NPI and Plans*/
					BEGIN
					UPDATE	[ast].[MbrStg2_MbrData]	
					SET		stgRowStatus = (CASE WHEN  prvNPI IS NULL THEN 'Not Valid' 
												 WHEN plnProductPlan IS NULL THEN 'Not Valid'
												 WHEN plnClientPlanEndDate <= @EffectiveDate THEN 'Not Valid' /*Amerigroup send us future data. So we treat data sent that predates the month of execution*/
												 ELSE 'Valid'
											END)
					WHERE	EffectiveDate = @EffectiveDate
					AND		DataDate = @MbrShipDataDate
					END

					/*Update stgRowStatus in Mbr Address/Email/Phone Table*/ 
					BEGIN
					UPDATE		[ast].[MbrStg2_PhoneAddEmail]
					SET			stgRowStatus = m.stgRowStatus --- select m.AdiKey,ad.AdiKey, *
					FROM		[ast].[MbrStg2_PhoneAddEmail] ad
					JOIN		(SELECT  MAX(DataDate) DataDate
													,AdiKey,stgRowStatus
											FROM	ast.MbrStg2_MbrData
											WHERE	ClientKey = @ClientKey
											AND		DataDate = @MbrShipDataDate
											GROUP BY AdiKey,stgRowStatus
												)m
					ON		   ad.AdiKey = m.AdiKey
					WHERE	   ad.DataDate = @MbrShipDataDate 
					END

					/* Update Active Flag using MbrDOD field and Exclusion File for update*/
					BEGIN
					UPDATE			ast.MbrStg2_MbrData
					SET				Active = 1   
					WHERE			EffectiveDate = @EffectiveDate
					AND				MbrDOD IS NULL 
					END

					--Update MbrNPIFlg
					UPDATE ast.MbrStg2_MbrData
					SET MbrNPIFlg = (CASE WHEN prvNPI IS NULL THEN 0 ELSE 1 END)
					WHERE	EffectiveDate = @EffectiveDate
					AND		DataDate = @MbrShipDataDate

					--Update MbrPlnFlg
					UPDATE ast.MbrStg2_MbrData
					SET MbrPlnFlg = (CASE WHEN plnProductPlan IS NULL THEN 0 ELSE 1 END)
					WHERE	EffectiveDate = @EffectiveDate
					AND		DataDate = @MbrShipDataDate
					
					--Update MbrFlgCount
					UPDATE ast.MbrStg2_MbrData
					SET MbrFlgCount = OutputResult  --- Select OutputResult,MbrFlgCount,*
					FROM	ast.MbrStg2_MbrData trg
					JOIN 	(SELECT CASE WHEN MbrCount >1 
										THEN MbrCount ELSE 1 END OutputResult
										,ClientSubscriberId
											FROM (
												SELECT	 COUNT(*) MbrCount
														,ClientSubscriberId
												FROM	 ast.MbrStg2_MbrData
												GROUP BY ClientSubscriberId
												)cnt
										)src
					ON		trg.ClientSubscriberId = src.ClientSubscriberId
					
					/*
					Count of Membership Indices from adi to adw
					 */
					BEGIN
					EXECUTE [AceMetaData].[ast].[03_GetMbrshipIndicesCntForAllMembersFromAdiToAdwIntoTable]@EffectiveDate
					END

					--Count for Npi
					SELECT	COUNT(*)
					FROM	[ast].[MbrStg2_MbrData]	-- 
					WHERE	DataDate = @MbrShipDataDate
					AND		EffectiveDate = @EffectiveDate
					AND		MbrNPIFlg = 1
						
					--Count for Pln
					SELECT	COUNT(*)
					FROM	[ast].[MbrStg2_MbrData]	-- 
					WHERE	DataDate = @MbrShipDataDate
					AND		EffectiveDate = @EffectiveDate
					AND		MbrPlnFlg = 1

					--Summary
					SELECT	COUNT(*)RecCnt, stgRowStatus
							,MbrFlgCount,MbrNPIFlg,MbrPlnFlg
							,DataDate,EffectiveDate
					FROM	ACDW_CLMS_AMGTX_MA.ast.MbrStg2_MbrData 
					GROUP BY stgRowStatus
							 ,MbrFlgCount,MbrNPIFlg,MbrPlnFlg
							 ,DataDate,EffectiveDate
					ORDER BY DataDate DESC
	


		SET					@ActionStart  = GETDATE();
		SET					@JobStatus =2  
	    				
		EXEC				amd.sp_AceEtlAudit_Close 
							@AuditId = @AuditID
							, @ActionStopTime = @ActionStart
							, @SourceCount = @InpCnt		  
							, @DestinationCount = @OutCnt
							, @ErrorCount = @ErrCnt
							, @JobStatus = @JobStatus

		END			
		
COMMIT
END TRY
BEGIN CATCH
EXECUTE [adw].[usp_MPI_Error_handler]
END CATCH

END

