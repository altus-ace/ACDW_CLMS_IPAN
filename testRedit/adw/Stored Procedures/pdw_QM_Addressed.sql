

	CREATE PROCEDURE [adw].[pdw_QM_Addressed]
							(@QMDate DATE, @ClientID INT)

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
						DECLARE @JobName VARCHAR(100) = 'adw.QM_Addressed';
						DECLARE @ActionStart DATETIME2 = GETDATE();
						DECLARE @SrcName VARCHAR(100) = 'ast.QM_Addressed'
						DECLARE @DestName VARCHAR(100) = 'ACDW_CLMS_SHCN_MSSP.adw.QM_Addressed'
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

			

			INSERT INTO		[adw].[Qm_Addressed](
							[srcFileName]
							, [AdiKey]
							, [adiTableName]
							, [ClientKey]
							, [ClientMemberKey]
							, [QmMsrId]
							, [QmCntCat]
							, [QMDate]
							, [DataDate]
							, [AddressedDate]
							, [AddressedDataSource]
							, [NPI]
							, [ProviderName])
							--Should it inherit ast lineage?
			OUTPUT			inserted.AdiKey INTO #OutputTbl(ID)
			SELECT			[srcFileName]
							, [AdiKey]
							, [adiTableName]
							, [ClientKey]
							, [ClientMemberKey]
							, [QmMsrId]
							, [QmCntCat]
							, [QMDate]
							, [DataDate]
							, [AddressedDate]
							, [AddressedDataSource]
							, [NPI]
							, [ProviderName]
			FROM			[ast].[QM_Addressed]
			WHERE			QmCntCat = 'NUM'
			AND				QMDate =  @QMDate
			AND				AddressedDate >= DATEADD(YEAR,-1,GETDATE()) --Added to have members from both sets(QmMembersByHistory and EMR) within the same measurement year (Si instruction)
			AND				RowStatus = 0


			BEGIN
			---Update Staging to 1 (Processed)
			UPDATE			ast.QM_Addressed
			SET				RowStatus = 1
			WHERE			RowStatus = 0;
			---Update DW to 1 (Processed)
			UPDATE			[adw].[Qm_Addressed]
			SET				RowStatus = 1
			WHERE			RowStatus = 0
			END

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
	EXECUTE [adw].[pdw_QM_Addressed]'2021-03-15',20
	*/

	

	
