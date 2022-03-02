

	/*What the frequency for this process run? do we process from 15th of the current month to the next in accordance with the QM?
	--@createddate just an anchor for what decision is made enventually*/

	CREATE PROCEDURE [ast].[pls_QM_Addressed_AWV]
					(@QMDate DATE
					, @LoadDate DATE
					,@ClientID INT)

	AS
	 
	SET NOCOUNT ON
	BEGIN
	
	BEGIN TRY
	BEGIN TRAN  

	CREATE TABLE		#OutputTbl (ID INT NOT NULL );

						DECLARE @AuditId INT;    
						DECLARE @JobStatus tinyInt = 1    
						DECLARE @JobType SmallInt = 9	  
						DECLARE @ClientKey INT	 = @ClientID; 
						DECLARE @JobName VARCHAR(100) = 'ast.QM_Addressed';
						DECLARE @ActionStart DATETIME2 = GETDATE();
						DECLARE @SrcName VARCHAR(100) = '[adi].[Athena_AWV]'
						DECLARE @DestName VARCHAR(100) = 'ACDW_CLMS_SHCN_BCBS.ast.QM_Addressed'
						DECLARE @ErrorName VARCHAR(100) = 'NA';
						DECLARE @InpCnt INT = -1;
						DECLARE @OutCnt INT = -1;
						DECLARE @ErrCnt INT = -1;
	SELECT				@InpCnt = COUNT(a.ID)    
	FROM				#OutputTbl  a
	
	
	SELECT				@InpCnt, @QMDate
	
	
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
	--CREATE TABLE		#OutputTbl (ID INT NOT NULL );

			INSERT INTO		[ast].[QM_Addressed](
							[srcFileName]
							, [AdiKey]
							, [adiTableName]
							, [ClientKey]
							, [ClientMemberKey]
							, [QmMsrId]
							, [QmCntCat]
							, [QMDate]
							, [DataDate]
							, [AddressedDataSource]
							, [AddressedDate]
							, [NPI]
							, [ProviderName]
							)
			OUTPUT			inserted.astQMAdressedKey INTO #OutputTbl(ID)
			SELECT			DISTINCT srcFileName
							,AdiKey
							,adiTableName
							,ClientKey
							,a.ClientMemberKey
							,QM
							,ResultStatus
							,@QMDate
							,DataDate
							,[AddressedDataSource]
							,[AddressedDate]
							,[NPI]
							,[ProviderName]
							--,RwCnt
			FROM			(
			SELECT			srcFileName
							, MSSPAWVadiKey AdiKey
							,'[adi].[Athena_AWV]' adiTableName
							, (SELECT ClientKey FROM lst.List_Client WHERE ClientShortName = 'SHCN_BCBS') ClientKey
							, RTRIM(LTRIM(REPLACE(PrimaryInsurancePolicyNumber,'''',' '))) PrimaryInsurancePolicyNumber
							, b.ClientMemberKey
							, MeasureName
							, CASE ResultStatus
								 WHEN 'Excluded' THEN 'Excluded'
								 WHEN 'Needs Data' THEN 'Needs Data' 
								 WHEN 'Satisfied' THEN 'NUM'
								 ELSE 'Ukn'
								 END ResultStatus
							, LoadDate
							, DataDate
							, (SELECT SUBSTRING('adi.Athena_AWV',5,10)) AS [AddressedDataSource]
							, SatisfiedDate									AS [AddressedDate]
							, ROW_NUMBER()OVER(PARTITION BY RTRIM(LTRIM(REPLACE(PrimaryInsurancePolicyNumber,'''',' '))),MeasureName,LastName,FirstName,DOBDate,SEX
							  ORDER BY DateRun DESC)RwCnt
							, [NPI]
							, [ProviderName]
			FROM			[ACDW_CLMS_SHCN_MSSP].[adi].[Athena_AWV] a
			JOIN			[ast].[vw_BCBS_SubscriberID_To_PatientID_Conversion] b
			ON				RTRIM(LTRIM(REPLACE(PrimaryInsurancePolicyNumber,'''',' '))) = SubscriberID
			WHERE			PrimaryInsurancePolicyNumber <> ''
			--AND				RowStatus = 0 -- This data serves as an addedum for BCBS and cant have this flag in the process, as it will be flagged to zero
			--frequency and date range will detrmine how i filter
							)a
			JOIN			(	SELECT	QM, QM_DESC, CreatedDate 
								FROM	lst.LIST_QM_Mapping
								WHERE	QM = 'ACE_PREV_AWV'
							)b
			ON				a.MeasureName = b.QM_DESC
			JOIN			(	SELECT	ClientMemberKey 
								FROM	adw.FctMembership
								WHERE	Active = 1
							)c
			ON				a.ClientMemberKey = c.ClientMemberKey
			WHERE			RwCnt = 1  
			AND				LoadDate =  @LoadDate --  (SELECT distinct loaddate FROM [ACDW_CLMS_SHCN_MSSP].[adi].[Athena_AWV]) --
			/*LoadDate in the ast represents QMDATE
			*/


	SELECT				@OutCnt = COUNT(*) FROM #OutputTbl;
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
	EXECUTE [dbo].[usp_QM_Error_handler]
	END CATCH

	END  

	/*
	USAGE 
	EXECUTE [ast].[pls_QM_Addressed_AWV]'2021-04-15','2021-04-13',20
	*/
	/*
	--HouseKeeping
	SELECT	 COUNT(*), LoadDate, RowStatus
	FROM	 [adi].[Athena_AWV]
	GROUP BY LoadDate, RowStatus
	ORDER BY LoadDate DESC

	*/



		
