
	CREATE PROCEDURE	[ast].[plsCareopps_GapAdherence]( ---  [ast].[plsCareopps_GapAdherence]'2021-11-15',21,'2021-10-04'  
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
					DECLARE @SrcName VARCHAR(100) = 'Pharmacy_Altus Ace Gap in Care Report May.2021 (13).csv'
					DECLARE @DestName VARCHAR(100) = '[ACECAREDW].[ast].[QM_ResultByMember_History]'
					DECLARE @ErrorName VARCHAR(100) = 'NA';
					DECLARE @InpCnt INT = -1;
					DECLARE @OutCnt INT = -1;
					DECLARE @ErrCnt INT = -1;
					DECLARE @OutputTbl TABLE (ID INT) 
	---Step 1a Create a temp table to hold records
		
		IF OBJECT_ID('tempdb..#AmgMA_CareOpps') IS NOT NULL DROP TABLE #AmgMA_CareOpps
		CREATE TABLE  #AmgMA_CareOpps ([pstQM_ResultByMbr_HistoryKey] [int] IDENTITY(1,1) NOT NULL,
								[srcFileName] [varchar](150) NULL,
								[adiTableName] [varchar](100) NOT NULL,	[adiKey] [int] NOT NULL
								,[ClientKey] [int] NOT NULL,[ClientMemberKey] [varchar](50) NOT NULL 
								,[QmMsrId] [varchar](100) NULL
								,[QmCntCat] [varchar](10) NULL,[QMDate] [date] NULL
								,srcQMID VARCHAR(50), srcQMDescription VARCHAR(50))

					SELECT				@InpCnt = COUNT(adiKey)
					FROM				#AmgMA_CareOpps
								
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
	
			/*Create a tmp table to hold population*/
			IF OBJECT_ID('tempdb..#COP') IS NOT NULL DROP TABLE #COP --  Declare @ClientKey int = 21 DECLARE @DataDate DATE = '2021-10-04' DECLARE @QMDATE DATE = '2021-11-15'
			SELECT	ClientMemberKey
					,trf.QmMsrId
					,QmCntCat 
					,QMDATE
					,MbrCOPStatus
					,AdiKey
					,srcFileName
					,DataDate
					,AdiTableName
					,ClientKey
					,trf.Source				AS aceSrcMeasure
					,trf.Destination		AS srcQMID
					,Unpvt.QmMsrId			AS srcQmDescription
					INTO	#COP  ---- DECLARE @DataDate DATE = '2021-10-04' DECLARE @ClientKey INT = 21 SELECT *
			FROM   (
			
			SELECT [AnthemMemberID] AS ClientMemberKey
					,'    ' AS QmCntCat
					,[SBSCRBR_ID]
					,[MemberFirstName]
					,[MemberLastName]
					,[DiabetesProportionDaysCovered_PDC]
					,[HypertensionProportionDaysCovered_PDC]
					,[CholesterolProportionofDaysCovered_PDC]
					,[Statin_use_inPersonsWDiabetesIndicator]
					,[Amerigroup_PharmacyKey]						AS AdiKey
					,adi.[SrcFileName]								AS srcFileName
					,adi.[DataDate]									AS DataDate
					,'[adi].[Amerigroup_AltusAceGapAdherence]'		AS AdiTableName
					,(SELECT ClientKey	
						FROM lst.list_client 
						WHERE ClientShortName = 'AMTX_MA')						 AS ClientKey
					,(SELECT DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),15)) AS QMDATE
			FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_AltusAceGapAdherence] adi
			WHERE	RowStatus = 0
			AND		DataDate = @DataDate
				  )pvt
			UNPIVOT
					(MbrCOPStatus FOR [QmMsrId] IN ([DiabetesProportionDaysCovered_PDC]
												,[HypertensionProportionDaysCovered_PDC]
												,[CholesterolProportionofDaysCovered_PDC]
												,[Statin_use_inPersonsWDiabetesIndicator]
										)
					 ) AS Unpvt
			LEFT JOIN	 /*Match on the lookup tables for matching values*/
						(	SELECT DISTINCT IsActive
											,Source
											,Destination 
											,MeasureID AS [QmMsrId]
								FROM        [lst].[ListAceMapping] ace
								LEFT JOIN	(SELECT DISTINCT MeasureID
													 ,MeasureDESC
												FROM lst.lstCareOpToPlan
												WHERE ClientKey = @ClientKey 
												AND ACTIVE = 'Y'
											) qm		
								ON		ace.Destination=qm.MeasureID
								WHERE	ClientKey = @ClientKey
								AND		ace.MappingTypeKey = 14
								AND		ace.ACTIVE = 'Y'
						) trf
				ON		Unpvt.QmMsrId = trf.Source

			/*Clean and transform MbrCOPStatus field*/
			BEGIN
			UPDATE #COP
			SET MbrCOPStatus = (CASE WHEN MbrCOPStatus = 'Excluded' THEN REPLACE(MbrCOPStatus,'Excluded','')
									WHEN MbrCOPStatus = 'N' THEN REPLACE(MbrCOPStatus,'N',73) /*To Capture AMTX_MA_SUPD*/
									WHEN MbrCOPStatus = 'Y' THEN REPLACE(MbrCOPStatus,'Y',100) /*To Capture AMTX_MA_SUPD*/
									--WHEN MbrCOPStatus = '' THEN REPLACE(MbrCOPStatus,'',0.00)
									WHEN MbrCOPStatus = 'FIRSTFILL' THEN REPLACE(MbrCOPStatus,'FIRSTFILL','')
									WHEN MbrCOPStatus = MbrCOPStatus THEN REPLACE(RIGHT(MbrCOPStatus,LEN(MbrCOPStatus)),RIGHT(MbrCOPStatus,1),'')
								ELSE MbrCOPStatus
								END) 
			END

			/*Delete Records for population not eligible for the CarGap*/
			BEGIN
			DELETE FROM #COP WHERE MbrCOPStatus = '' /*The are blank because they are not in the population*/
			END

			/*Transform Column Data Type to accomodate Arithemetic Calcs*/
			BEGIN
			UPDATE #COP
		    SET	MbrCOPStatus = CAST(MbrCOPStatus AS decimal(15,2))  
			END
		  
		    /*Identify members not in the population, 
			  ie they have scores less than 65 and eliminate from the population*/
			BEGIN
			DELETE
			-- SELECT * 
			FROM   #COP
			WHERE	CAST(MbrCOPStatus AS decimal(15,2))  <65.00
		    END   

		   /*Calculate for DEN population*/
			BEGIN
			UPDATE	#COP
			SET		QmCntCat = (CASE   WHEN QmMsrId IS NOT NULL THEN 'DEN' 
								       ELSE QmCntCat 
									   END)
			END
		   -- Select * From #COP 
	  		/*Inserting DEN from the tmp Table*/	
		   BEGIN	
			INSERT INTO	#AmgMA_CareOpps(
							[srcFileName]
							, [adiTableName]
							, [adiKey]
							, [ClientKey]
							, [ClientMemberKey]
							, [QmMsrId]
							, [QmCntCat]
							, [QMDate]
							, srcQMID
							, srcQMDescription)
				SELECT		tmp.SrcFileName
							,tmp.AdiTableName
							,tmp.Adikey
							,tmp.ClientKey
							,tmp.[ClientMemberKey]
							,tmp.QmMsrId
							,QmCntCat
							,tmp.QMDate
							,tmp.srcQMID
							,tmp.srcQmDescription		
				FROM		 #COP tmp
			END

			/*Calculating Records for NUM and COP*/
			BEGIN	
					INSERT INTO	#AmgMA_CareOpps(
							[srcFileName]
							, [adiTableName]
							, [adiKey]
							, [ClientKey]
							, [ClientMemberKey]
							, [QmMsrId]
							, [QmCntCat]
							, [QMDate]
							, srcQMID
							, srcQMDescription)
				SELECT		tmp.SrcFileName
							,tmp.AdiTableName
							,tmp.Adikey
							,tmp.ClientKey
							,tmp.[ClientMemberKey]
							,tmp.QmMsrId
							,CASE    WHEN   CONVERT(DECIMAL(15,2),MbrCOPStatus) BETWEEN 65 AND 95.99 THEN 'COP'
									 WHEN   CONVERT(DECIMAL(15,2),MbrCOPStatus) BETWEEN 96 AND 100 THEN 'NUM'
							          ELSE  QmCntCat 
									  END				AS   QmCntCat ---,MbrCOPStatus
							,tmp.QMDate
							,tmp.srcQMID
							,tmp.srcQmDescription		
				FROM		 #COP tmp
				WHERE		QmCntCat = 'DEN'  
			END
			-- SELECT * FROM #AmgMA_CareOpps
			
			/*Insert into staging*/
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
								, CONVERT(DATE,GETDATE())	AS LoadDate
								, [ClientKey]
								, [ClientMemberKey]
								, [QmMsrId]
								, [QmCntCat]
								, [QMDate]
								, [srcQMID]
								, [srcQmDescription]
				FROM			#AmgMA_CareOpps
			
	
			END

			/*Update adi RowStatus*/
			BEGIN
			UPDATE  [adi].[Amerigroup_AltusAceGapAdherence]
			SET		RowStatus = 1
			WHERE	RowStatus = 0
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

		---Validation_Tmp
		SELECT		COUNT(*)
                        ,[QmMsrId]
                        ,[QmCntCat] 
		FROM	#AmgMA_CareOpps
		WHERE           QMDate = @QMDATE
        AND             ClientKey = 21
        GROUP BY        [QmMsrId]
                        ,[QmCntCat]
        ORDER BY        [QmMsrId],[QmCntCat]
		
		
		DROP TABLE #AmgMA_CareOpps

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






 
  
