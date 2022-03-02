



CREATE PROCEDURE [adw].[PdwMbr_03_LoadDemo]		(@DataDate DATE
											    ,@ClientID INT
												)
AS

BEGIN

BEGIN TRY 
BEGIN TRAN
				
					DECLARE @AuditId INT;    
					DECLARE @JobStatus tinyInt = 1    
					DECLARE @JobType SmallInt = 9	  
					DECLARE @ClientKey INT	 = @ClientID; 
					DECLARE @JobName VARCHAR(100) = 'AMGTX_MA MbrMember';
					DECLARE @ActionStart DATETIME2 = GETDATE();
					DECLARE @SrcName VARCHAR(100) = '[ast].[MbrStg2_MbrData]'
					DECLARE @DestName VARCHAR(100) = '[adw].[MbrDemographic]'
					DECLARE @ErrorName VARCHAR(100) = 'NA';
					DECLARE @InpCnt INT = -1;
					DECLARE @OutCnt INT = -1;
					DECLARE @ErrCnt INT = -1;
					DECLARE @OutputTbl TABLE (ID INT);
	SELECT			@InpCnt = COUNT(a.mbrStg2_MbrDataUrn)    
	FROM			ast.MbrStg2_MbrData a
	WHERE			stgRowStatus = 'Valid'
	AND				DataDate = @DataDate

SELECT				@InpCnt, @DataDate


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
					

					

	IF NOT EXISTS ( SELECT		[ClientMemberKey], [ClientKey], [adiKey], [adiTableName]
	 							, [EffectiveDate], [ExpirationDate], [LastName]
	 							, [FirstName], [MiddleName], [SSN], [Gender], [DOB]
	 							, [mbrInsuranceCardIdNum], [MedicaidID], [HICN], [MBI], [MedicareID]
	 							, [Ethnicity], [Race], [PrimaryLanguage], [LoadDate], [DataDate]
	 							, [DOD]
					FROM			adw.MbrDemographic
					WHERE			DataDate = @DataDate
					)
	
	INSERT INTO		[adw].[MbrDemographic]( 
	 					[ClientMemberKey]
						, [ClientKey]
	 					, [adiKey]
	 					, [adiTableName]
	 					, [EffectiveDate]
	 					, [ExpirationDate]
	 					, [LastName]
	 					, [FirstName]
	 					, [MiddleName]
	 					, [SSN]
	 					, [Gender]
	 					, [DOB]
	 					, [mbrInsuranceCardIdNum]
	 					, [MedicaidID]
	 					, [HICN]
	 					, [MBI]
	 					, [MedicareID]
	 					, [Ethnicity]
	 					, [Race]
	 					, [PrimaryLanguage]
	 					, [LoadDate]
	 					, [DataDate]
	 					, [DOD]
						, [MemberOriginalEffectiveDate])
	 OUTPUT inserted.adiKey INTO @OutputTbl(ID)
	 SELECT				[ClientMemberKey]
						, [ClientKey]
	 					, [adiKey]
	 					, [adiTableName]
	 					, EffectiveDate
	 					, [ExpirationDate]
	 					, [LastName]
	 					, [FirstName]
	 					, [MiddleName]
	 					, [SSN]
	 					, [Gender]
	 					, [DOB]
	 					, [mbrInsuranceCardIdNum]
	 					, [MedicaidID]
	 					, [HICN]
	 					, [MBI]
	 					, [MedicareID]
	 					, [Ethnicity]
	 					, [Race]
	 					, [PrimaryLanguage]
	 					, [LoadDate]
	 					, [DataDate]
	 					, [mbrDOD]
						, [MemberOriginalEffectiveDate]
	 FROM				(
	 								SELECT
	 														stg.AdiKey
	 														,stg.AdiTableName
	 														,mbr.ClientMemberKey
	 														,Mbr.EffectiveDate
	 														,Mbr.ExpirationDate
	 														,stg.mbrLastName		AS LastName
	 														,stg.mbrFirstName		AS FirstName
	 														,stg.mbrMiddleName		AS MiddleName
	 														,''						AS SSN
	 														,stg.mbrGENDER			AS Gender
	 														,stg.mbrDob				AS DOB
	 														,''						AS [mbrInsuranceCardIdNum]
	 														,''						AS [MedicaidID]
	 														,stg.HICN
	 														,stg.MBI
	 														,''						AS [MedicareID]
	 														,stg.mbrEthnicity		AS Ethnicity
	 														,stg.mbrRace			AS Race
	 														,stg.mbrPrimaryLanguage	AS PrimaryLanguage
	 														,stg.mbrDOD
	 														,Mbr.LoadDate
	 														,Mbr.DataDate
															,Mbr.ClientKey
															,stg.[MemberOriginalEffectiveDate]
	 								FROM					ast.MbrStg2_MbrData  stg
	 								JOIN					adw.MbrMember mbr
	 								ON						stg.ClientSubscriberID = mbr.ClientMemberKey
	 								AND						stg.AdiKey = mbr.AdiKey
	 								AND						stg.AdiTableName = mbr.AdiTableName
	 								AND						stg.DataDate = mbr.DataDate
	 								WHERE					mbr.DataDate =  @DataDate--
	 								AND						mbr.ClientKey = @ClientID  -- 
	 								AND						stg.stgRowStatus = 'Valid'
	 											
						)			AS Src
	 					
	 					
	 
	UPDATE			adw.MbrDemographic
	SET				IsCurrent = 'N'		
	---- SELECT * FROM adw.MbrDemographic
	WHERE			DataDate <>  @DataDate 
	AND				IsCurrent <> 'N'

	UPDATE			adw.MbrDemographic
	SET				ExpirationDate = (SELECT CONVERT(DATE,DATEADD(d,-1,DATEADD(mm, DATEDIFF(m,0,CONVERT(DATE,GETDATE())),0))))
	--	SELECT * FROM adw.MbrDemographic --  ORDER BY LoadDate DESC
	WHERE			DataDate <>  @DataDate
	AND				ExpirationDate = '2099-12-31'
	 
 
SET						@ActionStart  = GETDATE();
SET						@JobStatus =2  
    					
EXEC					amd.sp_AceEtlAudit_Close 
						@AuditId = @AuditID
						, @ActionStopTime = @ActionStart
						, @SourceCount = @InpCnt		  
						, @DestinationCount = @OutCnt
						, @ErrorCount = @ErrCnt
						, @JobStatus = @JobStatus

COMMIT
END TRY
BEGIN CATCH
EXECUTE				[dbo].[usp_QM_Error_handler]
END CATCH


END

/*
[adw].[PdwMbr_03_LoadDemo]
	@DataDate ='2021-04-15'
	,@ClientID =21
*/

--Validation
	/*
	 SELECT		COUNT(*), DataDate 
	 FROM		adw.MbrDemographic 
	 GROUP BY	DataDate
	 ORDER BY	DataDate DESC
	 */

	

	
