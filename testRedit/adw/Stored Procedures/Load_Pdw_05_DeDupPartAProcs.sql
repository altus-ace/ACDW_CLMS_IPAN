
------DO NOT PROCESS SP UNTIL VALIDATED WITH COUNT FROM SOURCE FILE
CREATE PROCEDURE [adw].[Load_Pdw_05_DeDupPartAProcs] 
    ( @LatestDataDate DATE = '12/31/2099')
    
AS 
    /* -- 5. de dup procedures

	   get procs sets by claim and line and adj and ???
	   deduplicate for cases:
		  1. deal with duplicates: all relavant details are the same
		  2. deal with adjustments: if details sub line code is different
		  3. deal with???? will determin as we move forward

	   sort by file date or???
	   
	   insert into ast claims dedup procedure urns table
    */

	DECLARE @DataDate DATE;

    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 9	  -- 9: Ast Load, 10: Ast Transform, 11:Ast Validation	
    DECLARE @ClientKey INT	 = 25; -- ipan
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF3'
    DECLARE @DestName VARCHAR(100) = 'ast.Claim_05_Procs_Dedup;'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;

	    /* load INST CLAIMS */
 -- Inst Claims
    
    CREATE TABLE #OutputTbl (srcAdiKey INT NOT NULL, srcClaimType CHAR(5) NOT NULL,  PRIMARY KEY(srcAdiKey,srcClaimType));	
    TRUNCATE table ast.Claim_05_Procs_Dedup;

begin -- inst proc    

    SELECT @InpCnt = COUNT(c3.URN)    
    FROM ast.Claim_03_Header_LatestEffective CHdrLatest
		JOIN adi.CCLF3 c3 
		ON CHdrLatest.LatestClaimID = c3.CUR_CLM_UNIQ_ID
	WHERE CHdrLatest.SrcClaimType = 'INST'
	
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
	   	
    INSERT INTO ast.Claim_05_Procs_Dedup  (ProcAdiKey, ProcNumber)
    OUTPUT inserted.ClaimProcDedupKey, inserted.SrcClaimType INTO #OutputTbl(srcAdiKey, srcClaimType)    
	SELECT c3.URN AS SrcAdiKey, c3.CLM_VAL_SQNC_NUM ProcNum
    FROM ast.Claim_03_Header_LatestEffective CHdrLatest
		JOIN adi.CCLF3 c3 
		ON CHdrLatest.LatestClaimID = c3.CUR_CLM_UNIQ_ID
	WHERE CHdrLatest.SrcClaimType = 'INST'
		
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
END -- inst proc

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/

begin -- Prof proc 
    -- no proc codes to load in Prof Claim set
    set @SrcName = 'adi.CCLF3'    
END -- Prof proc
/*
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
begin -- RX proc 
    set @SrcName = 'adi.Steward_BCBS_RXClaim'
    -- No Procs in the RX claimsd
END -- RX proc
*/
