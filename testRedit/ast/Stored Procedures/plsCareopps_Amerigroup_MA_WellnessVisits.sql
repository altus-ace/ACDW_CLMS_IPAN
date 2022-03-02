

	
	CREATE PROCEDURE	[ast].[plsCareopps_Amerigroup_MA_WellnessVisits]( ---  [ast].[plsCareopps_Amerigroup_MA_WellnessVisits]'2021-11-15',21,'2021-11-07' 
							@QMDATE DATE
							,@ClientKey INT
							,@DataDate DATE)
	AS


	BEGIN
	BEGIN TRY
	BEGIN TRAN

					DECLARE @AuditId INT;    
					DECLARE @JobStatus tinyInt = 1    
					DECLARE @JobType SmallInt = 9	  
					DECLARE @ClientID INT	 = @ClientKey; 
					DECLARE @JobName VARCHAR(100) = 'AMGTX_MA_CareOpps';
					DECLARE @ActionStart DATETIME2 = GETDATE();
					DECLARE @SrcName VARCHAR(100) = 'Altus ACE MWOV.APV'
					DECLARE @DestName VARCHAR(100) = '[ast].[QM_ResultByMember_History]'
					DECLARE @ErrorName VARCHAR(100) = 'NA';
					DECLARE @InpCnt INT = -1;
					DECLARE @OutCnt INT = -1;
					DECLARE @ErrCnt INT = -1;
					DECLARE @OutputTbl TABLE (ID INT) 
	---Step 1a Create a temp table to hold records
		
		IF OBJECT_ID('tempdb..#AmgCOP') IS NOT NULL DROP TABLE #AmgCOP
		CREATE TABLE  #AmgCOP ([pstQM_ResultByMbr_HistoryKey] [int] IDENTITY(1,1) NOT NULL,
								[srcFileName] [varchar](150) NULL,[adiTableName] [varchar](100) NOT NULL,[adiKey] [int] NOT NULL
								,[ClientKey] [int] NOT NULL,[ClientMemberKey] [varchar](50) NOT NULL 
								,[QmMsrId] [varchar](100) NULL,[QmCntCat] [varchar](10) NULL,[QMDate] [date] NULL
								,[MbrCOPStatus] [varchar](50) NULL, LoadDate DATE
								,srcQMID VARCHAR(50),PlanName VARCHAR(50), srcQmDescription VARCHAR(50)
								)

					SELECT				@InpCnt = COUNT(adiKey)
					FROM				#AmgCOP
								
					--SELECT				 @InpCnt  

		EXEC		amd.sp_AceEtlAudit_Open 
					@AuditID = @AuditID OUTPUT
					, @AuditStatus = @JobStatus
					, @JobType = @JobType
					, @ClientKey = @ClientKey
					, @JobName = @JobName
					, @ActionStartTime = @ActionStart
					, @InputSourceName = @SrcName
					, @DestinationName = @DestName
					, @ErrorName = @ErrorName
	
	--1c Create a tmp table to hold population
	IF OBJECT_ID('tempdb..#COP') IS NOT NULL DROP TABLE #COP --- DECLARE @QMDATE DATE = '2021-12-15' DECLARE @DataDate DATE = '2021-11-07' DECLARE @ClientKey INT = 21
	SELECT DISTINCT	ClientMemberKey
			,[QmMsrId]
			,QmCntCat 
			,QMDATE
			,MbrCOPStatus
			,AdiKey
			,srcFileName
			,LoadDate
			,AdiTableName
			,ClientKey
			,srcQMID
			,srcQmDescription
			INTO	#COP
	FROM   (		--
			SELECT DISTINCT ClientMemberKey
					,acepln.QmMsrId
					,src.QmCntCat
					,QMDATE
					,MbrCOPStatus
					,src.AdiKey
					,src.srcFileName
					,src.LoadDate
					,src.AdiTableName
					,src.ClientKey
					,acepln.Destination AS srcQMID
					,src.MeasureName AS srcQmDescription
			FROM	( /*Get dataset for processing*/  --- DECLARE @QMDATE DATE = '2021-12-15' DECLARE @DataDate DATE = '2021-11-07' 
					SELECT DISTINCT		tvf.ClientMemberKey
							,adi.HICN,tvf.HICN_could_contain_ssn
							,CASE WHEN adi.MbrsWithWellnessVisits <> ''
									AND tvf.ClientMemberKey IS NOT NULL
									THEN 'DEN' ELSE '' END			AS QmCntCat
							,'MbrsWithWellnessVisits'				AS MeasureName /*To include the actual name from lstmapping*/
							,adi.MbrsWithWellnessVisits				AS MbrCOPStatus
							,adi.Amerigroup_MA_WellnessVisitsKey	AS AdiKey
							,adi.[SrcFileName]						AS srcFileName
							,adi.[DataDate]							AS DataDate
							,'[adi].[Amerigroup_MA_WellnessVisits]'	AS AdiTableName
							,adi.LoadDate							AS LoadDate
							,(SELECT ClientKey	
								FROM lst.list_client 
								WHERE ClientShortName = 'AMTX_MA') AS ClientKey
							, @QMDATE AS QMDATE ----  SELECT  *
					FROM    [adi].[Amerigroup_MA_WellnessVisits]  adi
					JOIN	[ast].[tvf_Get_MemberID_ConvertedTo_ClientMemberKey](GETDATE()) tvf
					ON		adi.HICN = tvf.HICN_could_contain_ssn
					WHERE	RowStatus = 0
					AND		DataDate =  @DataDate 
					)src
			LEFT JOIN   /*Match on the lookup tables for matching values*/
					(	SELECT DISTINCT IsActive
									,Source
									,Destination
									,MeasureID AS [QmMsrId]
							FROM [lst].[ListAceMapping] ace
							LEFT JOIN	(SELECT DISTINCT MeasureID
												,MeasureDESC
												,PlanName
											FROM  lst.lstCareOpToPlan
											WHERE ClientKey = @ClientKey 
											AND   ACTIVE = 'Y'
										) qm		
							ON		ace.Destination=qm.MeasureID
							WHERE ClientKey = @ClientKey
							AND	MappingTypeKey = 14
							AND ace.Active = 'Y'
					) acePln
			ON		src.MeasureName = acePln.Source
	)srcOut
	
	-- SELECT * FROM #COP WHERE QmMsrId IS NULL
	/*Step 2:
		Inserting DEN from tmp table*/
	INSERT INTO	#AmgCOP(
					[srcFileName]
					, [adiTableName]
					, [adiKey]
					, [ClientKey]
					, [ClientMemberKey]
					, [QmMsrId]
					, [QmCntCat]
					, [QMDate]
					, [LoadDate]
					, [MbrCOPStatus]
					, [srcQMID]
					, [srcQmDescription])
		SELECT		src.SrcFileName
					,src.AdiTableName
					,src.Adikey
					,src.ClientKey
					,src.[ClientMemberKey]
					,src.QmMsrId
					,src.QmCntCat
					,src.QMDate
					,src.LoadDate
					,src.MbrCOPStatus
					,src.srcQMID
					,src.srcQmDescription
		FROM		#COP src
		WHERE		QmCntCat = 'DEN'


		/*Step 3
		 Inserting COP from tmp Table*/

		BEGIN

		INSERT INTO	#AmgCOP(
					[srcFileName]
					, [adiTableName]
					, [adiKey]
					, [ClientKey]
					, [ClientMemberKey]
					, [MbrCOPStatus]
					, [QmMsrId]
					, [QmCntCat]
					, [QMDate]
					, [LoadDate]
					, [srcQMID]
					, [srcQmDescription])
		SELECT		srcFileName
					,AdiTableName
					,adiKey
					,ClientKey
					,ClientMemberKey
					,[MbrCOPStatus] 
					,[QmMsrId]
					,CASE WHEN MbrCOPStatus = '0' THEN 'COP' 
							WHEN MbrCOPStatus = '1' THEN 'NUM' ELSE '' 
							END QMCntCat
					,mbr.[QMDate]
					,mbr.LoadDate
					,srcQMID
					,srcQmDescription
		FROM		#COP mbr
		WHERE		QmCntCat = 'DEN'

		END

		/*Step 4: Calculating Invalid Records*/
		BEGIN
		INSERT INTO	#AmgCOP(
					[srcFileName]
					, [adiTableName]
					, [adiKey]
					, [ClientKey]
					, [ClientMemberKey]
					, [MbrCOPStatus]
					, [QmMsrId]
					, [QmCntCat]
					, [QMDate]
					, [LoadDate]
					, [srcQMID]
					, [srcQmDescription]
					)
		SELECT		srcFileName
					,AdiTableName
					,AdiKey
					,ClientKey
					,ClientMemberKey
					,[MbrCOPStatus] 
					,[QmMsrId]
					,[QmCntCat]
					,[QMDate]
					,[LoadDate]
					,srcQMID
					,srcQmDescription
		FROM		#COP mbr
		WHERE		QmMsrId IS NULL
		AND			QmCntCat = ''
		UNION
		SELECT		srcFileName
					,AdiTableName
					,adiKey
					,ClientKey
					,ClientMemberKey
					,[MbrCOPStatus] 
					,[QmMsrId]
					,[QmCntCat]
					,[QMDate]
					,[LoadDate]
					,srcQMID
					,srcQmDescription
		FROM		#COP mbr
		WHERE		QmMsrId IS NOT NULL
		AND			QmCntCat = ''

		END
		-- Insert into staging
		BEGIN

		INSERT INTO		[ast].[QM_ResultByMember_History](
						[astRowStatus]
						, [srcFileName]
						, [adiTableName]
						, [adiKey]
						, [LoadDate]
						, [ClientKey]
						, [ClientMemberKey]
						, [QmMsrId]
						, [QmCntCat]
						, [QMDate]
						, [srcQMID]
						, [srcQmDescription])
		
		SELECT			'Loaded'
						, [srcFileName]
						, [adiTableName]
						, [adiKey]
						, [LoadDate]
						, [ClientKey]
						, [ClientMemberKey]
						, [QmMsrId]
						, [QmCntCat]
						, [QMDate]
						, [srcQMID]
						, [srcQmDescription]
		FROM			#AmgCOP
		
	
		END 

		--Update adi RowStatus
		BEGIN
		UPDATE [adi].[Amerigroup_MA_WellnessVisits] 
		SET RowStatus = 1
		WHERE RowStatus = 0
		END

					SET					@ActionStart  = GETDATE();
					SET					@JobStatus =2  
					    				
					EXEC				ACECAREDW.amd.sp_AceEtlAudit_Close 
										@Audit_Id = @AuditID
										, @ActionStopTime = @ActionStart
										, @SourceCount = @InpCnt		  
										, @DestinationCount = @OutCnt
										, @ErrorCount = @ErrCnt
										, @JobStatus = @JobStatus   

		/*Validation_Tmp*/
		SELECT		COUNT(*)
                        ,[QmMsrId]
                        ,[QmCntCat] 
		FROM		#AmgCOP
		WHERE           QMDate = @QMDATE
        AND             ClientKey = @ClientKey
        GROUP BY        [QmMsrId]
                        ,[QmCntCat]
        ORDER BY        [QmMsrId],[QmCntCat]
		

		DROP TABLE #AmgCOP
		DROP TABLE #COP

		COMMIT
		END TRY

		BEGIN CATCH
		EXECUTE [dbo].[usp_QM_Error_handler]
		END CATCH

		END
		
		
		--Validation
		SELECT          COUNT(*)
                        ,[QmMsrId]
                        ,[QmCntCat]
        FROM            [ast].[QM_ResultByMember_History]
        WHERE           QMDate = @QMDATE
        AND             ClientKey = @ClientKey
        GROUP BY        [QmMsrId]
                        ,[QmCntCat]
        ORDER BY        [QmMsrId],[QmCntCat]






 
  
