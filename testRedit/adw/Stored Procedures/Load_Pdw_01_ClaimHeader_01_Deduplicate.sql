
CREATE PROCEDURE [adw].[Load_Pdw_01_ClaimHeader_01_Deduplicate]
    ( @LatestDataDate DATE = '12/31/2099')
AS
	-- Claims Dedup: Use this table to remove any duplicated input rows, they will be duplicated and versioned.. 
	-- Ensure records loaded tallies with cclf1 records (validation)
    DECLARE @DataDate DATE;
     
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 9	  -- AST load
    DECLARE @ClientKey INT	 = 25; -- ipan
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF1'
    DECLARE @DestName VARCHAR(100) = 'ast.Claim_01_Header_Dedup'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
    /* load INST CLAIMS */
BEGIN -- Inst Claims
    IF @LatestDataDate = '12/31/2099'
	   BEGIN	   
			SELECT @DataDate =  MAX(ch.FILEDATE) 
			FROM [adi].CCLF1 ch	
	   END
	   ELSE SET @DataDate = @LatestDataDate;   

	-- GET all claims by cliam ID, get a latest data date
    SELECT @InpCnt = COUNT(*) 
    FROM (SELECT ch.URN ClaimSKey, ch.CUR_CLM_UNIQ_ID AS ClaimNUmber, ch.OriginalFileName, FileDate AS DATADATE, 
				ROW_NUMBER() OVER(PARTITION BY ch.CUR_CLM_UNIQ_ID ORDER BY ch.DataDate DESC, ch.OriginalFileName ASC) arn
			FROM [adi].CCLF1 ch
			WHERE ch.FileDate <= @DataDate -- count all rows ;
			) s
	WHERE s.arn = 1	
	;
	
	EXEC amd.sp_AceEtlAudit_Open 
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
	
	CREATE TABLE #OutputTbl (
		  srcAdiKey INT NOT NULL
		  , SrcClaimType CHAR(5)
		  ,PRIMARY KEY CLUSTERED 
		   ([SrcAdiKey] ASC,[SrcClaimType] ASC
		   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		  ) ON [PRIMARY];	

	TRUNCATE TABLE ast.Claim_01_Header_Dedup;
	
	-- start tran
	/* load INST Claims */
	INSERT INTO ast.Claim_01_Header_Dedup(SrcAdiKey, SeqClaimId, OriginalFileName, LoadDate, SrcClaimType)
	OUTPUT inserted.SrcAdiKey, inserted.SrcClaimType INTO #OutputTbl(srcAdiKey, SrcClaimType)
	SELECT s.ClaimSKey, s.ClaimID, s.OriginalFileName, s.datadate, s.SrcClaimType
	FROM (SELECT ch.URN ClaimSKey, ch.CUR_CLM_UNIQ_ID AS ClaimID, ch.OriginalFileName, FileDate AS DATADATE, 'INST' SrcClaimType,
				ROW_NUMBER() OVER(PARTITION BY ch.CUR_CLM_UNIQ_ID ORDER BY ch.DataDate DESC, ch.OriginalFileName ASC) arn
			FROM [adi].CCLF1 ch
			WHERE ch.FileDate <= @DataDate -- count all rows ;
		  ) s
	WHERE s.arn = 1
	      ---AND DataDate <= @DataDate;

    SELECT @OutCnt = COUNT(*) FROM #OutputTbl otb WHERE otb.srcClaimType = 'INST';
    SET @ActionStart  = GETDATE();
    SET @JobStatus =2  -- complete
    
	EXEC amd.sp_AceEtlAudit_Close 
        @AuditId = @AuditID
        , @ActionStopTime = @ActionStart
        , @SourceCount = @InpCnt		  
        , @DestinationCount = @OutCnt
        , @ErrorCount = @ErrCnt
        , @JobStatus = @JobStatus
	   ;
END;
BEGIN -- PROF claims 

    IF @LatestDataDate = '12/31/2099'
	   BEGIN	   
			SELECT @DataDate =  MAX(ch.FILEDATE) 
			FROM [adi].cclf5 ch			
	   END
	   ELSE SET @DataDate = @LatestDataDate;     

    -- GET all claims by cliam ID, get a latest data date
    SELECT @InpCnt = COUNT(*) 
    FROM (SELECT ch.URN ClaimSKey, ch.CUR_CLM_UNIQ_ID AS ClaimNUmber, ch.OriginalFileName, FileDate AS DATADATE, 
				ROW_NUMBER() OVER(PARTITION BY ch.CUR_CLM_UNIQ_ID ORDER BY ch.FILEDate DESC, ch.OriginalFileName ASC) arn			
			FROM [adi].CCLF5 ch
			WHERE ch.FileDate <=@DataDate
			) s
	WHERE s.arn = 1
	
    SET  @SrcName = 'adi.CCLF5'	 	 ;
    EXEC amd.sp_AceEtlAudit_Open 
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
	/* Get Prof Claims */ 
	-- start tran	
	INSERT INTO ast.Claim_01_Header_Dedup(SrcAdiKey, SeqClaimId, OriginalFileName, LoadDate, SrcClaimType)
	OUTPUT inserted.SrcAdiKey, inserted.SrcClaimType INTO #OutputTbl(srcAdiKey, SrcClaimType)
	SELECT s.SrcAdiKey, s.SeqClaimId, s.OriginalFileName, s.FileDate, s.SrcClaimType
	--srcAdiKey, SeqClaimID, OrigFIleName, SrcClaimType, LoadDate, CreatedDate, CreatedBy
    FROM (select ch.urn SrcAdiKey,  ch.CUR_CLM_UNIQ_ID SeqClaimId, ch.OriginalFileName, 'PROF' SrcClaimType, ch.FileDate    		  
    		  , ROW_NUMBER() OVER (partition by ch.CUR_CLM_UNIQ_ID ORDER BY FileDate Desc, clm_line_num ASC /* get only headers so get the lowest row rank*/) arn
           FROM adi.cclf5 ch
		   WHERE ch.FileDate <= @DATADATE) s
    WHERE s.arn = 1 
	      

    SELECT @OutCnt = COUNT(*) FROM #OutputTbl otb WHERE otb.srcClaimType = 'PROF';
    SET @ActionStart  = GETDATE();
    SET @JobStatus =2  -- complete
    
	EXEC amd.sp_AceEtlAudit_Close 
        @AuditId = @AuditID
        , @ActionStopTime = @ActionStart
        , @SourceCount = @InpCnt		  
        , @DestinationCount = @OutCnt
        , @ErrorCount = @ErrCnt
        , @JobStatus = @JobStatus
	   ;
END
BEGIN -- RX CLAIMS
    IF @LatestDataDate = '12/31/2099'
	   BEGIN
	   SELECT @DataDate = MAX(ch.FileDate)	   
		  FROM adi.CCLF7 ch
	   END
	   ELSE SET @DataDate = @LatestDataDate;   

    SELECT @InpCnt = COUNT(*) 
    FROM (SELECT ch.adiCCLF7_SKey, ch.CUR_CLM_UNIQ_ID, ch.OriginalFileName, ch.FileDate DataDate
				, ROW_NUMBER() OVER(PARTITION BY ch.CUR_CLM_UNIQ_ID ORDER BY ch.FileDate DESC, ch.OriginalFileName ASC) arn
			FROM adi.CCLF7 ch
			WHERE ch.FileDate <= @DataDate
		) s
	WHERE s.arn = 1;
	
	SELECT @InpCnt, @LatestDataDate, @DataDate
	    
	
    SET  @SrcName = 'adi.CCLF7'	 	
    EXEC amd.sp_AceEtlAudit_Open 
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
	/* Get Prof Claims */ 
	-- start tran	
    INSERT INTO ast.Claim_01_Header_Dedup(SrcAdiKey, SeqClaimId, OriginalFileName, LoadDate, SrcClaimType)
    OUTPUT inserted.SrcAdiKey, inserted.SrcClaimType INTO #OutputTbl(srcAdiKey, SrcClaimType)
    SELECT s.ClaimSKey, s.CUR_CLM_UNIQ_ID , s.OriginalFileName, s.FileDate, 'RX'
    FROM (SELECT ch.adiCCLF7_SKey ClaimSKey, ch.CUR_CLM_UNIQ_ID, ch.OriginalFileName, FileDate, 
	           ROW_NUMBER() OVER(PARTITION BY ch.CUR_CLM_UNIQ_ID ORDER BY ch.FileDate DESC, ch.OriginalFileName ASC) arn
			FROM adi.CCLF7 ch
			WHERE ch.FileDate <= @DataDate
		  ) s
    WHERE s.arn = 1;

    SELECT @OutCnt = COUNT(*) FROM #OutputTbl otb WHERE otb.srcClaimType = 'RX';
    SET @ActionStart  = GETDATE();
    SET @JobStatus =2  -- complete
    
	EXEC amd.sp_AceEtlAudit_Close 
        @AuditId = @AuditID
        , @ActionStopTime = @ActionStart
        , @SourceCount = @InpCnt		  
        , @DestinationCount = @OutCnt
        , @ErrorCount = @ErrCnt
        , @JobStatus = @JobStatus
	   ;
	
END
