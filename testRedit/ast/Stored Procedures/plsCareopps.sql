


	CREATE PROCEDURE	[ast].[plsCareopps]( ---  [ast].[plsCareopps]'2021-03-15',21,'2021-03-010'  
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
					DECLARE @SrcName VARCHAR(100) = 'adi.[Amerigroup_CARE-OPPS]'
					DECLARE @DestName VARCHAR(100) = '[ACECAREDW].[ast].[QM_ResultByMember_History]'
					DECLARE @ErrorName VARCHAR(100) = 'NA';
					DECLARE @InpCnt INT = -1;
					DECLARE @OutCnt INT = -1;
					DECLARE @ErrCnt INT = -1;
					DECLARE @OutputTbl TABLE (ID INT) 

	IF OBJECT_ID('tempdb..#AmgMA_CareOpps') IS NOT NULL DROP TABLE #AmgMA_CareOpps
	

	CREATE TABLE  #AmgMA_CareOpps ([pstQM_ResultByMbr_HistoryKey] [int] IDENTITY(1,1) NOT NULL,[astRowStatus] [varchar](20) DEFAULT'P' NOT NULL,
								[srcFileName] [varchar](150) NULL,
								[adiTableName] [varchar](100) NOT NULL,	[adiKey] [int] NOT NULL,[LoadDate] [date] NOT NULL,	
								[CreateDate] [datetime] NOT NULL,
								[CreateBy] [varchar](50) NOT NULL,[ClientKey] [int] NOT NULL,[ClientMemberKey] [varchar](50) NOT NULL 
								,[QmMsrId] [varchar](100) NOT NULL,[QmCntCat] [varchar](10) NOT NULL,[QMDate] [date] NULL
								,[MemberStatus] VARCHAR(50) NOT NULL
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
		
		BEGIN			----  DECLARE @QMDATE DATE = '2021-03-15' DECLARE @DataDate DATE = '2021-03-10' 
		
		INSERT INTO	#AmgMA_CareOpps(
					[srcFileName]
					, [adiTableName]
					, [adiKey]
					, [LoadDate] --Becomes Data date of the file
					, [CreateDate]
					, [CreateBy]
					, [ClientKey]
					, [ClientMemberKey]
					, [MemberStatus]
					, [QmMsrId]
					, [QmCntCat]
					, [QMDate])
		OUTPUT		inserted.adiKey INTO @OutputTbl(ID)
		SELECT		a.SrcFileName
					,a.AdiTableName
					,a.Adikey
					,a.DataDate
					,a.CreateDate
					,a.CreateBy
					,a.ClientKey
					,a.[ClientMemberKey]
					,a.MSR_CMPLNC_CD AS [MemberStatus]
					,a.QM
					,a.QmCntCat
					,a.QMDate

		FROM		(   -- Calculating for DEN --  SELECT * FROM (
						SELECT		[Amerigroup_CARE-OPPSKey] AS AdiKey
									,src.SrcFileName,DataDate
									,RULE_NM
									,RULE_ID
									,NEXT_CLNCL_DUE_DT
									,MSR_CMPLNC_CD
									,ROW_NUMBER()OVER(PARTITION BY MasterConsumerID,Rule_NM ORDER BY MSR_CMPLNC_CD ASC)RwCnt
									,(SELECT ClientKey FROM lst.list_client WHERE ClientShortName = 'AMTX_MA') ClientKey
									,MSR_NMRTR_NBR
									,MSR_DNMNTR_NBR
									,MasterConsumerID AS ClientMemberKey
									,FirstName
									,LastName
									,DateBirth
									,Gender
									,CONVERT(DATE,src.CreatedDate) AS CreateDate
									,'adi.[Amerigroup_CARE-OPPS]' AS AdiTableName
									,SUSER_NAME()[CreateBy]
									,'DEN' AS QmCntCat
									,QM
									,QM_DESC
									,@QMDATE AS QMDATE--- 
						FROM		adi.[Amerigroup_CARE-OPPS] src
						JOIN		(SELECT		*
									 FROM		lst.LIST_QM_Mapping
									 WHERE		ClientKey = 21
									 AND		ACTIVE = 'Y'
									 ) lk
						ON			src.RULE_NM = lk.QM_DESC
						JOIN		(	SELECT		CLIENT_SUBSCRIBER_ID
										FROM		ACECAREDW.dbo.vw_ActiveMembers vw
										WHERE		ClientKey = 21
									) vw
						ON			src.MasterConsumerID = vw.CLIENT_SUBSCRIBER_ID
						WHERE		MSR_DNMNTR_NBR = '1'
						AND			DataDate =  @DataDate --  '2021-03-10' --
						AND			NEXT_CLNCL_DUE_DT >= @DataDate
						AND			MA_RowStatus = 0 --order by ClientMemberKey, RULE_NM
						
					)a
		WHERE		RwCnt = 1
				
		END
		
		-- SELECT QmMsrId, ClientMemberKey,MemberStatus,* FROM #AmgMA_CareOpps a 
		 
		BEGIN
		--Insert NUM
		INSERT INTO	#AmgMA_CareOpps(
					[srcFileName]
					, [adiTableName]
					, [adiKey]
					, [LoadDate]
					, [CreateDate]
					, [CreateBy]
					, [ClientKey]
					, [ClientMemberKey]
					, [MemberStatus]
					, [QmMsrId]
					, [QmCntCat]
					, [QMDate])
		SELECT		srcFileName
					,AdiTableName
					,adiKey
					,LoadDate
					,[CreateDate]
					,[CreateBy]
					,ClientKey
					,ClientMemberKey
					,[MemberStatus]
					,[QmMsrId]
					,'NUM'
					,[QMDate]
		FROM		#AmgMA_CareOpps
		WHERE		MemberStatus = '01'
		
		END

		BEGIN
		--Insert COP
		INSERT INTO	#AmgMA_CareOpps(
					[srcFileName]
					, [adiTableName]
					, [adiKey]
					, [LoadDate]
					, [CreateDate]
					, [CreateBy]
					, [ClientKey]
					, [ClientMemberKey]
					, [MemberStatus]
					, [QmMsrId]
					, [QmCntCat]
					, [QMDate])
		SELECT		srcFileName
					,AdiTableName
					,adiKey
					,LoadDate
					,[CreateDate]
					,[CreateBy]
					,ClientKey
					,ClientMemberKey
					,[MemberStatus]
					,[QmMsrId]
					,'COP'
					,[QMDate]
		FROM		#AmgMA_CareOpps
		WHERE		MemberStatus = '02'

		END


		-- Insert into staging
		BEGIN

		INSERT INTO		[ast].[QM_ResultByMember_History](
						[astRowStatus]
						, [srcFileName]
						, [adiTableName]
						, [adiKey]
						, [LoadDate]
						, [CreateDate]
						, [CreateBy]
						, [ClientKey]
						, [ClientMemberKey]
						, [QmMsrId]
						, [QmCntCat]
						, [QMDate])
		
		SELECT			'Exported'
						, [srcFileName]
						, [adiTableName]
						, [adiKey]
						, [LoadDate]
						, [CreateDate]
						, [CreateBy]
						, [ClientKey]
						, [ClientMemberKey]
						, [QmMsrId]
						, [QmCntCat]
						, [QMDate]
		FROM			#AmgMA_CareOpps
		
	
		END

					SET					@ActionStart  = GETDATE();
					SET					@JobStatus =2  
					    				
					EXEC				amd.sp_AceEtlAudit_Close 
										@AuditId = @AuditID
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
		WHERE           QMDate = '2021-03-15'
        AND             ClientKey = 21
        GROUP BY        [QmMsrId]
                        ,[QmCntCat]
        ORDER BY        [QmMsrId]
		

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
        AND             ClientKey = 21
        GROUP BY        [QmMsrId]
                        ,[QmCntCat]
        ORDER BY        [QmMsrId]


	
