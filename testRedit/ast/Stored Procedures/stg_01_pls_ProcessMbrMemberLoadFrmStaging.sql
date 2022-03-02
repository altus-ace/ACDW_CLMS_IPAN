
--SET ANSI_WARNINGS OFF
--GO
CREATE PROCEDURE [ast].[stg_01_pls_ProcessMbrMemberLoadFrmStaging] -- [ast].[stg_01_pls_ProcessMbrMemberLoadFrmStaging]'2021-07-01','2021-07-01'
                 (@LoadDate DATE, @EffectiveDate DATE)

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
						DECLARE @SrcName VARCHAR(100) = '[adi].[Attribution]'
						DECLARE @DestName VARCHAR(100) = 'ast.[MbrStg2_MbrData]'
						DECLARE @ErrorName VARCHAR(100) = 'NA';
						DECLARE @InpCnt INT = -1;
						DECLARE @OutCnt INT = -1;
						DECLARE @ErrCnt INT = -1;
	SELECT				@InpCnt = COUNT(adi.IPAN_AttributionKey)    
	FROM				[adi].[Attribution] adi 
	WHERE				LoadDate = @LoadDate  
	
	SELECT				@InpCnt, @LoadDate
	
	
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
 
	/*Create PR DataSet*/
  BEGIN
		--  DECLARE @LoadDate DATE = '2021-07-01' DECLARE @ClientKey INT = 25 	
		IF OBJECT_ID('tempdb..#Prr') IS NOT NULL DROP TABLE #Prr
		CREATE TABLE #Prr(NPI VARCHAR(50),ClientNPI VARCHAR(50),AttribTIN VARCHAR(50)
							,ClientTIN VARCHAR(50),MemberID VARCHAR(50)
							)

		INSERT INTO #Prr(NPI,ClientNPI,AttribTIN,ClientTIN,MemberID)
		EXECUTE  [adi].[GetMbrNpiAndTin_IPAN] @LoadDate,0,@ClientKey -- select * from #prr
   END
  BEGIN

		IF OBJECT_ID('tempdb..#Ipan') IS NOT NULL DROP TABLE #Ipan 
		----- DECLARE @ClientKey INT = 25 DECLARE @EFFECTIVEDATE DATE = '2021-07-01' DECLARE @LoadDate DATE = '2021-07-01'
			SELECT	DISTINCT adi.IPAN_AttributionKey						[AdiKey]
					,adi.[SrcFileName]										[SrcFileName]
					,'[adi].[Attribution]'									[AdiTableName]
					,adi.[DataDate]											[DataDate]
					,@ClientKey												[ClientKey]
					,1234													MstrMrnKey
					,adi.CurrentMBI											ClientSubscriberId
					,adi.CurrentMBI											[MBI]
					,''														[HICN]
					,adi.[mbrFirstName]										[mbrFirstName]
					,adi.[mbrMiddleName]									[mbrMiddleName]
					,adi.mbrLastName										[mbrLastName]
					,adi.mbrGender											[mbrGENDER]
					,adi.mbrDOB												[mbrDob]
					,adi.MbrDOD												[mbrDOD]  
					,DATEDIFF(YY,adi.mbrDOB,@EffectiveDate)					[CurrentAge] 
					,MONTH(@EffectiveDate)									[MbrMonth]
					,YEAR(@EffectiveDate)									[MbrYear]
					,adi.AddAddress1										[MemberHomeAddress]
					,adi.AddAddress2										[MemberHomeAddress1]
					,adi.AddCity											[MemberHomeCity]
					,adi.MbrState											[MemberHomeState]
					,adi.AddZip												[MemberHomeZip]
					,(SELECT LobName 
						FROM lst.List_Client 
						WHERE ClientKey = 25)								[LOB]
					, CASE WHEN pr.NPI IS NOT NULL THEN pr.NPI 	
						ELSE '1111111111' END								[prvNPI]
					, CASE WHEN pr.AttribTIN IS NOT NULL THEN pr.AttribTIN
						ELSE '123456789' END								[prvTIN]
					,0														[ClientRiskScore]
					,@EffectiveDate											[plnClientPlanEffective]
					,'2099-12-31'											[plnClientPlanEndDate]
					,lstPln.TargetValue										[plnProductPlan]
					,ISNULL(lstSubPln.TargetValue,'')						[plnProductSubPlan]
					,ISNULL(lstSubPln.TargetValue,'')						[plnProductSubPlanName]
					,ISNULL(lstCsPln.TargetValue,'')						[CsplnProductSubPlanName]
					,''														[MbrState]
					,''														MemberMailingState
					,''														[MemberMailingZip]	
					,adi.BMNPI												srcNPI
					,lstPln.SourceValue										srcPln
					,adi.BMTIN												srcTIN
					,@EffectiveDate											EffectiveDate
					,'Loaded'												stgRowStatus
					,adi.CurrentMBI											mbrMEDICARE_ID					
					,''														mbrMEDICAID_NO
					,''														mbrPrimaryLanguage
					,''														plnMbrIsDualCoverage
					,adi.Member_Dual_Eligible_Flag							Member_Dual_Eligible_Flag
					,@EffectiveDate											MemberOriginalEffectiveDate
					, ''					AS prvAutoAssign
					,'2099-12-31'			AS prvClientExpiration
					,'1900-01-01'			AS [MemberOriginalEndDate]
					, @EffectiveDate		AS LoadDate
					INTO #Ipan   
	FROM			(SELECT  CurrentMBI
							,BMNPI
							,BMTIN
							,LoadDate
							,DataDate
							,RowStatus
							,IPAN_AttributionKey
							,attrib.SrcFileName
							,ISNULL(cclf8.AddAddress1,'')			AS	 AddAddress1
							,ISNULL(cclf8.AddAddress2,'')			AS	 AddAddress2
							,ISNULL(cclf8.AddCity,'')				AS   AddCity
							,ISNULL(cclf8.AddZip,'')				AS   AddZip
							,ISNULL(cclf8.Member_Dual_Eligible_Flag,'') AS	Member_Dual_Eligible_Flag
							,ISNULL(cclf8.mbrDOB,'')				AS	mbrDOB
							,cclf8.MbrDOD
							,ISNULL(cclf8.mbrFirstName,'')			AS  mbrFirstName
							,ISNULL(cclf8.mbrGender,'')				AS  mbrGender
							,ISNULL(cclf8.mbrLastName,'')			AS	mbrLastName
							,ISNULL(cclf8.mbrMiddleName,'')			AS	mbrMiddleName
							,ISNULL(cclf8.MbrState,'')				AS	MbrState
							,ROW_NUMBER()OVER(PARTITION BY CurrentMBI ORDER BY LoadDate)RwCnt
					 FROM  adi.Attribution attrib
					 LEFT JOIN  (SELECT *  
							FROM (
									SELECT DISTINCT	[BENE_ZIP_CD]		AS	AddZip
											,FileDate
											,[BENE_DOB]					AS mbrDOB
											,CASE WHEN [BENE_SEX_CD] = '1' THEN 'M'
												WHEN [BENE_SEX_CD] = '2' THEN 'F' 
												ELSE ISNULL([BENE_SEX_CD],'') END AS mbrGender
											,[BENE_DUAL_STUS_CD]  AS  Member_Dual_Eligible_Flag
											,[BENE_DEATH_DT] AS MbrDOD
											,ISNULL(GEO_USPS_STATE_CD,'') AS MbrState
											,[adi].[udf_ConvertToCamelCase](ISNULL(GEO_ZIP_PLC_NAME,'')) AS  AddCity 
											,[adi].[udf_ConvertToCamelCase](ISNULL([BENE_1ST_NAME],'')) AS  mbrFirstName
											,[adi].[udf_ConvertToCamelCase](ISNULL([BENE_LAST_NAME],''))AS	mbrLastName
											,[adi].[udf_ConvertToCamelCase](ISNULL([BENE_MIDL_NAME],''))AS	mbrMiddleName
											,[BENE_MBI_ID]
											,[adi].[udf_ConvertToCamelCase](ISNULL([BENE_LINE_1_ADR],'')) AS AddAddress1 
											,[adi].[udf_ConvertToCamelCase](ISNULL([BENE_LINE_2_ADR],'')) AS AddAddress2
											, ROW_NUMBER() OVER(PARTITION BY BENE_MBI_ID, BENE_SEX_CD ORDER BY BENE_LINE_1_ADR)RwCnt 
										--- SELECT  DISTINCT [BENE_MBI_ID] -- select *
									FROM   [ACDW_CLMS_IPAN].[adi].[CCLF8] 
								)cclf8
							WHERE RwCnt = 1
								) cclf8
					ON		attrib.CurrentMBI = cclf8.BENE_MBI_ID
					) [adi]
	LEFT JOIN		(SELECT	TargetValue,SourceValue
						FROM	lst.LstPlanMapping
						WHERE	ClientKey = @ClientKey
						AND		TargetSystem = 'ACDW_Plan'
						AND		@LoadDate BETWEEN EffectiveDate AND ExpirationDate) lstPln
	ON					lstPln.TargetValue = 'MSSP'
	LEFT JOIN		(SELECT	TargetValue
						FROM	lst.LstPlanMapping
						WHERE	ClientKey = @ClientKey
						AND		TargetSystem = 'ACDW_SubPlan'
						AND		@LoadDate BETWEEN EffectiveDate AND ExpirationDate) lstSubPln
	ON					lstSubPln.TargetValue = 'MSSP'
	LEFT JOIN		(SELECT	TargetValue
						FROM	lst.LstPlanMapping
						WHERE	ClientKey = @ClientKey
						AND		TargetSystem = 'CS_AHS'
						AND		@LoadDate BETWEEN EffectiveDate AND ExpirationDate) lstCsPln
	ON					lstCsPln.TargetValue = 'MSSP' /*To make this a place holder just incase in future we start receive a plan Name we can associate with our csPlan name*/
	LEFT JOIN			#Prr  pr
	ON					pr.NPI = adi.BMNPI
	AND					pr.MemberID = adi.CurrentMBI
	WHERE				LoadDate =  @LoadDate 
	AND					adi.RwCnt = 1
	AND					RowStatus = 0   /*Should only apply for processing a new set of records because records are re-used*/
	END
		--- Select srcNPI,prvNpi,prvTIN,[MbrState],CLIENTSUBSCRIBERID,* from #ipan where prvnpi = '1111111111'

	/*Transform ZIP COdes with 4 digits*/
	BEGIN
	UPDATE	#Ipan
	SET		[MemberHomeZip] = '0' + [MemberHomeZip]
	WHERE	[MemberHomeZip] NOT IN ('','0')
	AND		[MemberHomeZip] = LEFT([MemberHomeZip],4)
	END
	
		/*Load Data into Mbr Staging*/
	BEGIN
	INSERT INTO  ast.MbrStg2_MbrData	
					([AdiKey]
					,[SrcFileName]		
					,[AdiTableName]		
					,[LoadDate]
					,[DataDate]
					,[ClientKey]		
					,[MstrMrnKey] 		
					,[ClientSubscriberId] 
					,[MBI]				
					,[HICN]				
					,[mbrFirstName]
					,[mbrMiddleName] 		
					,[mbrLastName] 		 	
					,[mbrGENDER]		
					,[mbrDob]
					,[MbrDOD]		
					,[LOB]			
					,[prvNPI]
					,[prvTIN]
					,[ClientRiskScore]	
					,[plnClientPlanEffective]	
					,[plnClientPlanEndDate]
					,[plnProductPlan]
					,[plnProductSubPlan]
					,[plnProductSubPlanName]
					,[CsplnProductSubPlanName]
					,[MbrState]
					,[srcNPI]
					,[srcPln]
					,[EffectiveDate]
					,[stgRowStatus]
					,[mbrMEDICARE_ID]
					,[mbrMEDICAID_NO]
					,[mbrPrimaryLanguage]
					,[plnMbrIsDualCoverage]
					,[Member_Dual_Eligible_Flag]
					,[MemberOriginalEffectiveDate]
					,[srcTIN]
					,[prvAutoAssign]
					,[prvClientEffective]
					,[prvClientExpiration]
					,[MemberOriginalEndDate]
					)			
	SELECT			[AdiKey]							[AdiKey]
					,[SrcFileName]						[SrcFileName]		
					,[AdiTableName]						[AdiTableName]		
					,LoadDate							[LoadDate]
					,[EffectiveDate]					[DataDate]
					,[ClientKey]						[ClientKey]		
					,[MstrMrnKey] 						[MstrMrnKey] 		
					,[ClientSubscriberId] 				[ClientSubscriberId] 
					,[MBI]								[MBI]				
					,[HICN]								[HICN]				
					,[mbrFirstName]						[mbrFirstName]
					,[mbrMiddleName] 					[mbrMiddleName] 		
					,[mbrLastName] 		 				[mbrLastName] 		 	
					,[mbrGENDER]						[mbrGENDER]		
					,[mbrDob]							[mbrDob]
					,[MbrDOD]							[MbrDOD]
					,[LOB]								[LOB]			
					,[prvNPI]							[prvNPI]
					,[prvTIN]							[prvTIN]
					,[ClientRiskScore]					[ClientRiskScore]	
					,[plnClientPlanEffective]			[plnClientPlanEffective]	
					,[plnClientPlanEndDate]				[plnClientPlanEndDate]
					,[plnProductPlan]					[plnProductPlan]
					,[plnProductSubPlan]				[plnProductSubPlan]
					,[plnProductSubPlanName]			[plnProductSubPlanName]
					,[CsplnProductSubPlanName]			[CsplnProductSubPlanName]
					,[MbrState]							[MbrState]
					,[srcNPI]							[srcNPI]
					,[srcPln]							[srcPln]
					,[EffectiveDate]					[EffectiveDate]
					,[stgRowStatus]						[stgRowStatus]
					,[mbrMEDICARE_ID]					[mbrMEDICARE_ID]
					,[mbrMEDICAID_NO]					[mbrMEDICAID_NO]
					,[mbrPrimaryLanguage]				[mbrPrimaryLanguage]
					,[plnMbrIsDualCoverage]				[plnMbrIsDualCoverage]
					,[Member_Dual_Eligible_Flag]		[Member_Dual_Eligible_Flag]
					,[MemberOriginalEffectiveDate]		[MemberOriginalEffectiveDate]
					,[srcTIN]							[srcTIN]
					,[prvAutoAssign]					[prvAutoAssign]
					,[MemberOriginalEffectiveDate]		[prvClientEffective]
					,[prvClientExpiration]				[prvClientExpiration]
					,[MemberOriginalEndDate]			[MemberOriginalEndDate]--- SELECT *
	FROM			#Ipan src
	END

 BEGIN
		/*Load Data into Mbr Phone,Address,Email Table*/
		INSERT INTO		[ast].[MbrStg2_PhoneAddEmail]
						(							 
						[ClientMemberKey]
						,[SrcFileName]
						,[LoadType]
						,[LoadDate]
						,[DataDate]
						,[AdiTableName]
						,[AdiKey]
						,[lstPhoneTypeKey]
						,[PhoneNumber]
						,[PhoneCarrierType]
						,[PhoneIsPrimary]
						,[lstAddressTypeKey] 
						,[AddAddress1]
						,[AddAddress2]
						,[AddCity]
						,[AddState]
						,[AddZip]
						,[AddCounty]
						,[lstEmailTypeKey]
						,[EmailAddress]
						,[EmailIsPrimary]
						,[stgRowStatus]
						,[ClientKey]
						,CellPhone
						,HomePhone
						)
		SELECT			DISTINCT																
						ClientSubscriberId						AS [ClientMemberKey]
						,src.SrcFileName						AS [SrcFileName]
						,'P'									AS [LoadType]
						,LoadDate								AS [LoadDate]
						,src.EffectiveDate						AS [DataDate]
						,src.AdiTableName						AS [AdiTableName]
						,src.AdiKey								AS [AdiKey]	
						,1										AS [lstPhoneTypeKey]
						,''										AS [PhoneNumber]
						,0										AS [PhoneCarrierType]
						,0										AS [PhoneIsPrimary]
						,1										AS [lstAddressTypeKey]
						,src.MemberHomeAddress						AS [AddAddress1]
						,src.MemberHomeAddress						AS [AddAddress2]
						,src.MemberHomeCity							AS [AddCity]
						,src.MemberHomeState						AS [AddState]
						,src.MemberHomeZip							AS [AddZip]
						,''											AS [AddCounty]
						,0										AS [lstEmailTypeKey]
						,''										AS [EmailAddress]
						,0										AS [EmailIsPrimary]
						,[stgRowStatus]							AS [stgRowStatus]
						,[ClientKey]								AS [ClientKey]	
						,''										AS CellPhone
						,''										AS HomePhone
		FROM			#Ipan src
END

		DROP TABLE #Ipan
		DROP TABLE #Prr


		SET					@ActionStart  = GETDATE();
		SET					@JobStatus =2  
	    				
		EXEC				amd.sp_AceEtlAudit_Close 
							@AuditId = @AuditID
							, @ActionStopTime = @ActionStart
							, @SourceCount = @InpCnt		  
							, @DestinationCount = @OutCnt
							, @ErrorCount = @ErrCnt
							, @JobStatus = @JobStatus

COMMIT
END TRY
BEGIN CATCH
EXECUTE [adw].[usp_MPI_Error_handler]
END CATCH

END


