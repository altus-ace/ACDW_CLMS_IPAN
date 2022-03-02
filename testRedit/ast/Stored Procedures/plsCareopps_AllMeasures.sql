
	CREATE PROCEDURE	[ast].[plsCareopps_AllMeasures]( ---  [ast].[plsCareopps_AllMeasures]'2021-11-15',21,'2021-11-01'  
							@QMDATE DATE
							,@ClientKey INT
							,@DataDate DATE)
	AS


	BEGIN
	BEGIN TRY
	BEGIN TRAN

					DECLARE @AuditId INT;    
					DECLARE @JobStatus tinyInt = 1    
					DECLARE @JobType SmallInt = 9; 
					DECLARE @JobName VARCHAR(100) = 'AMGTX_MA_CareOpps';
					DECLARE @ActionStart DATETIME2 = GETDATE();
					DECLARE @SrcName VARCHAR(100) = 'adi.[Amerigroup_CARE-OPPS]'
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
								[adiTableName] [varchar](100) NOT NULL,	[adiKey] [int] NOT NULL,
								[ClientKey] [int] NOT NULL,[ClientMemberKey] [varchar](50) NOT NULL 
								,[QmMsrId] [varchar](100) NULL,[QmCntCat] [varchar](10) NOT NULL,[QMDate] [date] NULL
								,srcQMID VARCHAR(50),srcQMDescription VARCHAR(50)
								)

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
		IF OBJECT_ID('tempdb..#COP') IS NOT NULL DROP TABLE #COP -- Declare @ClientKey int = 21 DECLARE @DataDate DATE = '2021-11-01' 
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
				INTO	#COP  ---- DECLARE @DataDate DATE = '2021-11-01' DECLARE @ClientKey INT = 21 SELECT *
		FROM   (			
				SELECT	CONVERT(VARCHAR(50),MCID) AS ClientMemberKey
						,'      ' AS QmCntCat
						,[BCS] 
						,[CBP]
						,[CDC_HbA1c_Test]
						,[CDC_HbA1c_LE9] 
						,[CDC_EyeExam] 
						,[CDC_Nephro]
						,[KED]
						,[COA_ACP]
						,[COA_FSA]
						,[COA_MR] 
						,[COA_PS]
						,[COL]
						,[OSW]
						,CAST(OMW collate database_default AS VARCHAR(20))		AS [OMW] 
						,CAST([AOMW] collate database_default AS VARCHAR(20))	AS [AOMW]
						,[FUH_Followup_30]
						,[FUH_Followup_7]
						,[TRC_ENGAGEMENT] 
						,[SPC_REC_TOTAL]
						,CAST([TRC_RECONCILIATION] collate database_default AS VARCHAR(20)) AS[TRC_RECONCILIATION]
						,(SELECT DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),15))AS QMDATE 
						,adi.Amerigroup_AltusAceGapKey								AS AdiKey
						,adi.SrcFileName											AS srcFileName
						,adi.DataDate												AS DataDate
						,'[adi].[Amerigroup_AltusAceGap]'							AS AdiTableName
						,(SELECT ClientKey 
								FROM lst.list_client 
								WHERE ClientShortName = 'AMTX_MA')					AS ClientKey
				FROM	[ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_AltusAceGap] adi
				WHERE	RowStatus = 0
				AND		DataDate = @DataDate
				)p
		UNPIVOT
					(MbrCOPStatus FOR [QmMsrId] IN ([BCS],[CBP],[CDC_HbA1c_Test],[CDC_HbA1c_LE9]
									,[CDC_EyeExam],[CDC_Nephro],[KED],[COA_ACP],[COA_FSA]
									,[COA_MR],[COA_PS],[COL],[OSW]
									,[OMW]
									,[AOMW]
									,[FUH_Followup_30],[FUH_Followup_7]
									,[TRC_ENGAGEMENT] 
									,[SPC_REC_TOTAL]
									,[TRC_RECONCILIATION]
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
				
				/*Delete Records for population not eligible for the CarGap*/
				BEGIN
				DELETE 
				--  SELECT *
				FROM #COP WHERE MbrCOPStatus = '' /*The are blank because they are not in the population*/
				END

				/*Calculate for DEN population*/
				BEGIN
				UPDATE	#COP
				SET		QmCntCat = (CASE   WHEN MbrCOPStatus IN ('1', '0') AND QmMsrId IS NOT NULL THEN 'DEN' 
									       ELSE QmCntCat 
										   END)
				END
				--- SELECT * FROM #COP
				/*Calculating DEN from the tmp Table*/	
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
							,CASE    WHEN MbrCOPStatus = '1' THEN 'NUM' 
									 WHEN MbrCOPStatus = '0' THEN 'COP'
							          ELSE QmCntCat 
									  END					 AS   QmCntCat
							,tmp.QMDate
							,tmp.srcQMID
							,tmp.srcQmDescription		
				FROM		 #COP tmp
				WHERE		QmCntCat = 'DEN'
				END
		
			    	
			    /*Inserting Records into staging*/
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
			    
				/*Update adi Rowstatus*/
				BEGIN
				UPDATE [adi].[Amerigroup_AltusAceGap]
				SET	RowStatus = 1
				WHERE Rowstatus = 0
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
		
		
				
			
