
CREATE PROCEDURE [adw].[Load_Pdw_07_DeDupCclf5]
 ( @latestDataDate DATE = '12/31/2099')
AS    
    /* THIS IS UNIQUE TO CCLF model to handle PROFESSIONAL Component */	 
	/* PURPOSE: Get Latest Claims Header/details Seq_claims_id/ seq_claim/ClaimLineNum
			 1. Use the super key to find duplicated cliams: BCBS CLAIM ID IS SUPERKEY the only dups will be month over month
			 2. order by activity_date desc 
			 
			 */

    /* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 9	  -- AST load
    DECLARE @ClientKey INT	 = 25; -- ipan
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF5'
    DECLARE @DestName VARCHAR(100) = 'ast.pstDeDupClms_PartBPhys'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;

    CREATE TABLE #OutputTbl (ID NUMERIC (18,0) NOT NULL, PRIMARY KEY (ID) );	
    TRUNCATE TABLE ast.pstDeDupClms_PartBPhys;
	
	BEGIN -- inst Claims 
    SELECT @InpCnt =COUNT(*) 
    FROM (SELECT csk.clmSKey, ch.URN, ch.CUR_CLM_UNIQ_ID LatestClaimID
				, ch.URN ReplacesAdiKey, ch.CUR_CLM_UNIQ_ID  ReplacesClaimID, GETDATE()AS ProcessDate, ch.CLM_ADJSMT_TYPE_CD
				, ROW_NUMBER() OVER (PARTITION BY csk.clmSKey ORDER BY ch.CLM_EFCTV_DT desc, ch.CLM_ADJSMT_TYPE_CD DESC) LastClaimRank
				, csk.srcClaimType	
			FROM ast.Claim_02_HeaderSuperKey csk
				JOIN adi.CCLF1 ch ON csk.PRVDR_OSCAR_NUM = ch.PRVDR_OSCAR_NUM
	   				AND csk.BENE_EQTBL_BIC_HICN_NUM = ch.BENE_MBI_ID
	   				AND csk.CLM_FROM_DT = ch.CLM_FROM_DT
	   				and csk.CLM_THRU_DT = ch.CLM_THRU_DT
				JOIN ast.Claim_01_Header_Dedup ddH ON ch.urn = ddH.SrcAdiKey
			) src
    WHERE src.LastClaimRank = 1
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
	DECLARE @LoadDate DATE;
	
	SELECT @LoadDate = max(c5.filedate) 
	FROM adi.cclf5 c5

	IF @LoadDate > @latestDataDate 
		SET @LoadDate = @latestDataDate;
    
	TRUNCATE TABLE ast.[pstDeDupClms_PartBPhys];

    INSERT INTO ast.[pstDeDupClms_PartBPhys] (srcAdiKey, CUR_CLM_UNIQ_ID, CLM_LINE_NUM, BENE_MBI_ID, CLM_FROM_DT, CLM_THRU_DT, fileDate, srcfileName)
	OUTPUT INSERTED.srcAdiKey INTO #OutputTbl(ID)
    SELECT s.urn, CUR_CLM_UNIQ_ID, CLM_LINE_NUM, BENE_MBI_ID, CLM_FROM_DT, CLM_THRU_DT, fileDate, srcfileName
    FROM (SELECT urn, CUR_CLM_UNIQ_ID, clm_line_num, BENE_MBI_ID, CLM_FROM_DT, CLM_THRU_DT, fileDate, srcfileName
    		  , ROW_NUMBER() OVER (partition by CUR_CLM_UNIQ_ID, clm_line_num ORDER BY FileDate Desc) arn
           FROM adi.cclf5 
		   WHERE FileDate >= @LoadDate 
		   ) s
    WHERE s.arn = 1 ;

	SELECT @OutCnt = COUNT(*) FROM #OutputTbl  otb --WHERE otb.srcClaimType = 'INST';
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
END ;