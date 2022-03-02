CREATE PROCEDURE [adw].[Load_Pdw_13_ClmsProcsCclf3]
AS
    --Task 3 Insert Proc: -- Insert to proc    
	/* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 8	  -- AST load
    DECLARE @ClientKey INT	 = 25; -- ipan
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF3'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Procs'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
    SELECT @InpCnt = COUNT(*) 	
    FROM ast.Claim_05_Procs_Dedup ast 
    WHERE ast.SrcClaimType = 'INST'
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
    CREATE TABLE #OutputTbl (ID INT NOT NULL PRIMARY KEY);	
    
    INSERT INTO adw.Claims_Procs
               (SEQ_CLAIM_ID
				,SUBSCRIBER_ID
				,ProcNumber
				,ProcCode
				,ProcDate
				,LoadDate
				,SrcAdiTableName
				,SrcAdiKey	)	
    OUTPUT Inserted.URN INTO #OutputTbl(ID)
    SELECT cp.CUR_CLM_UNIQ_ID				AS SEQ_CLAIM_ID
        , cp.BENE_MBI_ID	 				AS subscriberID
        , ast.ProcNumber			 		AS ProcNum
        , cp.CLM_PRCDR_CD					AS ProcCode
        , cp.CLM_PRCDR_PRFRM_DT	  			AS ProcDate
	   , getdate()							AS LoadDate
	   , 'adi.CCLF3'						AS SrcAdiTableName
	   , ast.ProcAdiKey					   	AS SrcAdiKey
		-- implicit: 	CreatedDate,CreatedBy,LastUpdatedDate,LastUpdatedBy
    FROM adi.CCLF3 cp
        JOIN ast.Claim_05_Procs_Dedup ast 
			ON cp.URN = ast.ProcAdiKey 
			AND ast.SrcClaimType = 'INST'		
    ORDER BY cp.CUR_CLM_UNIQ_ID, ast.ProcNumber;
  

	-- if this fails it just stops. How should this work, structure from the WLC or AET COM care Op load, acedw do this soon.
	SELECT @OutCnt = COUNT(*) FROM #OutputTbl; 
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

