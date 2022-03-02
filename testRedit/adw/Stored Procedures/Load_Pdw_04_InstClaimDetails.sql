CREATE PROCEDURE [adw].[Load_Pdw_04_InstClaimDetails]
   ( @LatestDataDate DATE = '12/31/2099')
AS
  /* PURPOSE: -- 4. de dup claims details     */	
    DECLARE @DataDate DATE;
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 9	  -- 9: Ast Load, 10: Ast Transform, 11:Ast Validation	
    DECLARE @ClientKey INT	 = 25; -- ipan
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();    
    DECLARE @DestName VARCHAR(100) = 'ast.Claim_04_Detail_Dedup'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	-- do I need the date?
	 IF @LatestDataDate = '12/31/2099'
	   BEGIN
	   SELECT @DataDate = MAX(ch.FILEDate)
		  FROM adi.CCLF2 ch		  
	   END
	   ELSE SET @DataDate = @LatestDataDate; 
    TRUNCATE TABLE ast.Claim_04_Detail_Dedup;   
	 
    CREATE TABLE #OutputTbl (srcAdiKey INT NOT NULL, SrcClaimType CHAR(5) NOT NULL , PRIMARY KEY (srcAdiKey, SrcClaimType));	

	/* create a temp version of claim Line number, to fix the missing claim line numbers in source file */
	IF OBJECT_ID(N'tempdb..#tmpNewClmLineNum') IS NOT NULL			
		DROP table tempdb..#tmpNewClmLineNum

    SELECT cl.urn, cl.CUR_CLM_UNIQ_ID, cl.CLM_LINE_NUM, cl.FileDate	
		, ROW_NUMBER() OVER (Partition BY cl.CUR_CLM_UNIQ_ID ORDER BY cl.URN) NewClmLinNum
	INTO #tmpNewClmLineNum
	FROM adi.cclf2 cl;
	
	BEGIN -- Inst Claims Details	
	--declare @DataDate date = '01/01/2021'
    SELECT @InpCnt = COUNT(c.URN)      		
	FROM ast.Claim_03_Header_LatestEffective CHdrLatest	
		JOIN adi.cclf2 c
			ON CHdrLatest.LatestClaimID = c.CUR_CLM_UNIQ_ID   
		JOIN #tmpNewClmLineNum t ON c.URN = t.URN
	WHERE CHdrLatest.LatestClaimAdiKey = CHdrLatest.ReplacesAdiKey 
		AND CHdrLatest.SrcClaimType = 'INST'					
		;

    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF2'
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



    INSERT INTO ast.Claim_04_Detail_Dedup(
	ClaimDetailSrcAdiKey
	, ClaimDetailSrcAdiTableName
	, AdiDataDate
	, ClaimSeqClaimId
	, ClaimDetailLineNumber
	, SrcClaimType)
    OUTPUT Inserted.pstClmDetailKey, inserted.SrcClaimType INTO #OutputTbl(srcAdiKey, SrcClaimType)    
    SELECT
	 cl.URN
	 , @SrcName
	 , cl.FileDate
	 , cl.CUR_CLM_UNIQ_ID
	 , t.NewClmLinNum
	 , CHdrLatest.SrcClaimType
	FROM ast.Claim_03_Header_LatestEffective CHdrLatest	
		JOIN adi.cclf2 cl
			ON CHdrLatest.LatestClaimID = cl.CUR_CLM_UNIQ_ID   
		JOIN #tmpNewClmLineNum t ON cl.URN = t.URN
	WHERE CHdrLatest.LatestClaimAdiKey = CHdrLatest.ReplacesAdiKey 
		AND CHdrLatest.SrcClaimType = 'INST'					
		;
    ;
	-- if this fails it just stops. How should this work, structure from the WLC or AET COM care Op load, acedw do this soon.
	SELECT @OutCnt = COUNT(*) FROM #OutputTbl otb WHERE otb.SrcClaimType = 'INST'; 
	SET @ActionStart = GETDATE();    
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

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
BEGIN -- PROF Claims Details
    -- declare @DataDate date = '01/01/2021';
    SELECT @InpCnt = COUNT(cl.URN)        	
	FROM ast.Claim_03_Header_LatestEffective lr -- list of latest effective claims		  
	   JOIN adi.CCLF5 cl
		  ON lr.LatestClaimID = cl.CUR_CLM_UNIQ_ID		  		 
	WHERE lr.LatestClaimAdiKey = lr.ReplacesAdiKey 		  
		AND lr.SrcClaimType = 'PROF'				
    ;

    set @SrcName = 'adi.CCLF5';
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
    
    INSERT INTO ast.Claim_04_Detail_Dedup(
	ClaimDetailSrcAdiKey
	, ClaimDetailSrcAdiTableName
	, AdiDataDate
	, ClaimSeqClaimId
	, ClaimDetailLineNumber
	, SrcClaimType)
    OUTPUT Inserted.pstClmDetailKey, inserted.SrcClaimType INTO #OutputTbl(srcAdiKey, SrcClaimType)
    SELECT cl.URN
			, @SrcName
			, cl.FileDate
			, cl.CUR_CLM_UNIQ_ID
			, CLM_LINE_NUM			
			, lr.SrcClaimType
   FROM ast.Claim_03_Header_LatestEffective lr -- list of latest effective claims		  
	   JOIN adi.CCLF5 cl
		  ON lr.LatestClaimID = cl.CUR_CLM_UNIQ_ID		  		 
	WHERE lr.LatestClaimAdiKey = lr.ReplacesAdiKey 		  
		AND lr.SrcClaimType = 'PROF'	
	ORDER BY CUR_CLM_UNIQ_ID, CLM_LINE_NUM
    ;
     
	-- if this fails it just stops. How should this work, structure from the WLC or AET COM care Op load, acedw do this soon.
	SELECT @OutCnt = COUNT(*) FROM #OutputTbl otb WHERE otb.SrcClaimType = 'PROF'; 
	SET @ActionStart = GETDATE();    
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

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */

BEGIN -- RX Claims Details
    -- declare @DataDate date = '01/01/2021';
    SELECT @InpCnt = COUNT(ch.adiCCLF7_SKey)            
    FROM [adi].CCLF7 ch
	   JOIN ast.Claim_03_Header_LatestEffective lr 
		  ON ch.adiCCLF7_SKey = lr.LatestClaimAdiKey
		  AND lr.LatestClaimAdiKey = lr.ReplacesAdiKey	   
		  AND lr.SrcClaimType = 'RX'	
    ;

    set @SrcName = 'adi.CCLF7';
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
    
    INSERT INTO ast.Claim_04_Detail_Dedup(ClaimDetailSrcAdiKey, ClaimDetailSrcAdiTableName, AdiDataDate, ClaimSeqClaimId, ClaimDetailLineNumber, SrcClaimType)
    OUTPUT Inserted.pstClmDetailKey, inserted.SrcClaimType INTO #OutputTbl(srcAdiKey, SrcClaimType)
    SELECT 
	ch.adiCCLF7_SKey
	, @SrcName
	, ch.FileDate
	, ch.CUR_CLM_UNIQ_ID
	, ROW_NUMBER() OVER(PARTITION BY ch.CUR_CLM_UNIQ_ID ORDER BY ch.FileDate DESC, ch.OriginalFileName ASC) ClaimLinenumber	
	, lr.SrcClaimType
    FROM [adi].CCLF7 ch
	   JOIN ast.Claim_03_Header_LatestEffective lr 
		  ON ch.adiCCLF7_SKey = lr.LatestClaimAdiKey
		  AND lr.LatestClaimAdiKey = lr.ReplacesAdiKey	   
		  AND lr.SrcClaimType = 'RX'	
    ;
	-- if this fails it just stops. How should this work, structure from the WLC or AET COM care Op load, acedw do this soon.
	SELECT @OutCnt = COUNT(*) FROM #OutputTbl otb WHERE otb.SrcClaimType = 'RX'; 
	SET @ActionStart = GETDATE();    
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
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
