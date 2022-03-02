
	CREATE PROCEDURE [ast].[pdw_CareOppsStagingToAdw] (@QMDate DATE, @ClientID INT) -- [ast].[pdw_CareOppsStagingToAdw]'2021-11-15',21
	AS
	 
SET NOCOUNT ON
	BEGIN
	
	BEGIN TRY
	BEGIN TRAN  

						DECLARE @AuditId INT;    
						DECLARE @JobStatus tinyInt = 1    
						DECLARE @JobType SmallInt = 9	  
						DECLARE @ClientKey INT	 = @ClientID; 
						DECLARE @JobName VARCHAR(100) = 'DHTX_Load_adw';
						DECLARE @ActionStart DATETIME2 = GETDATE();
						DECLARE @SrcName VARCHAR(100) = 'ast.[QM_ResultByMember_History]'
						DECLARE @DestName VARCHAR(100) = '[adw].[QM_ResultByMember_History]'
						DECLARE @ErrorName VARCHAR(100) = 'NA';
						DECLARE @InpCnt INT = -1;
						DECLARE @OutCnt INT = -1;
						DECLARE @ErrCnt INT = -1;
	SELECT				@InpCnt = COUNT(a.pstQM_ResultByMbr_HistoryKey)    
	FROM				ast.QM_ResultByMember_History  a
	WHERE				QMDate = @QMDate 
	AND					ClientKey = @ClientKey 
	
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
	CREATE TABLE		#OutputTbl (ID INT NOT NULL );

	INSERT	INTO		[adw].[QM_ResultByMember_History]
						(ClientKey, ClientMemberKey,QmMsrId,QmCntCat,QMDate,CreateDate,CreateBy,AdiKey)
	OUTPUT				inserted.QM_ResultByMbr_HistoryKey INTO #OutputTbl(ID)
	SELECT				ClientKey
						, ClientMemberKey
						,QmMsrId
						,QmCntCat
						,QMDate
						,CreateDate
						,CreateBy
						,AdiKey
	FROM				[ast].[QM_ResultByMember_History]  
	WHERE				ClientKey = @ClientKey 
	AND					QMDate = @QMDate
	AND					astRowStatus = 'Valid'


	BEGIN
					/*---Insert into DW -- Details Tables  */
		INSERT INTO adw.QM_ResultByValueCodeDetails_History(
						ClientKey
						,ClientMemberKey
						,ValueCodeSystem
						,ValueCode
						,ValueCodePrimarySvcDate
						,QmMsrID
						,QmCntCat
						,QMDate
						,SEQ_CLAIM_ID
						,SVC_TO_DATE
						,srcFileName
						,AdiKey
						,adiTableName
						,SVC_PROV_NPI)
		SELECT			ClientKey
						,ClientMemberKey
						,'CareGapReport'					AS ValueCodeSystem ---srcData
						,'0'								AS ValueCode
						,LoadDate							AS ValueCodePrimarySvcDate
						,QmMsrId							
						,QmCntCat							
						,QMDate								
						,'0'								AS SEQ_CLAIM_ID
						,''									AS SVC_TO_DATE
						,'ast.Qm_ResultByMember_History'	AS srcFileName
						,0									AS AdiKey
						,'ast.Qm_ResultByMember_History'	AS adiTableName
						, ''								AS SVC_PROV_NPI
		FROM			[ast].[QM_ResultByMember_History]  
		WHERE			ClientKey = @ClientKey 
		AND				QMDate =	@QMDATE
		AND				QmCntCat IN ('NUM')
		AND				astRowStatus = 'Valid'
	END

	/*Update staging*/
	BEGIN
	UPDATE	ast.QM_ResultByMember_History
	SET		astRowStatus = 'Exported'
	WHERE	astRowStatus = 'Valid'
	AND		QMDate = @QMDate

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

	
