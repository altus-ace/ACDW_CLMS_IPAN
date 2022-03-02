
CREATE PROCEDURE [adw].[Load_Pdw_03_LatestEffectiveClmsHeader]( 
    @LatestDataDate DATE = '12/31/2099'
    )
AS 
	/* PURPOSE: Get Latest Claims Header Seq_claims_id 
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
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF1'
    DECLARE @DestName VARCHAR(100) = 'ast.Claim_03_Header_LatestEffective'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;

    CREATE TABLE #OutputTbl (ID VARCHAR(50) NOT NULL, ReplacesAdiKey VARCHAR(50) NOT NULL, srcClaimType CHAR(4), PRIMARY KEY (ID, ReplacesAdiKey, srcClaimType) );	
    TRUNCATE TABLE ast.Claim_03_Header_LatestEffective;
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
    
    INSERT INTO [ast].Claim_03_Header_LatestEffective (
			[clmSKey]
		   ,[LatestClaimAdiKey]
		   ,[LatestClaimID]
		   ,[ReplacesAdiKey]
		   ,[ReplacesClaimID]
		   ,[ProcessDate]
		   ,[ClaimAdjCode]
		   ,[LatestClaimRankNum]
		   ,SrcClaimType)
    OUTPUT INSERTED.clmSKey, inserted.ReplacesAdiKey, inserted.SrcClaimType INTO #OutputTbl(ID, ReplacesAdiKey, srcClaimType)
	SELECT src.clmSKey, src.URN, src.LatestClaimID
		, src.ReplacesAdiKey, src.ReplacesClaimID, src.ProcessDate, src.CLM_ADJSMT_TYPE_CD
		, src.LastClaimRank, src.srcClaimType
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
					and ddH.SrcClaimType = csk.srcClaimType
	   ) src
    WHERE src.LastClaimRank = 1


    /* TRANSFORM: Remove ClaimsAdjCode Max = 1. These are the cancelled claims. 
	   These rows will not be loaded, so the Latest adikey and ClaimId will be 0 */
    MERGE ast.Claim_03_Header_LatestEffective TRG
    USING(    SELECT stg.clmSKey
			 FROM (    SELECT Stg.clmSKey, MAX(stg.ClaimAdjCode) MaxAdjCode
					   FROM ast.Claim_03_Header_LatestEffective stg
					   WHERE stg.SrcClaimType = 'INST'
					   GROUP BY stg.clmSKey
				    ) stg
			 WHERE stg.MaxAdjCode = 1
			 ) SRC
    ON TRG.clmSkey = SRC.clmSKey 
    WHEN MATCHED THEN
	   UPDATE SET TRG.LatestClaimAdiKey = 0
		  ,TRG.LatestClaimID = 0
    ;

    
    /* TRANSFORM:  Set the Latest Adikey and ClaimID to the lastest calcd values */
    MERGE ast.Claim_03_Header_LatestEffective  TRG
    USING ( SELECT stg.clmSKey, stg.LatestClaimAdiKey, stg.LatestClaimID
		  FROM ast.Claim_03_Header_LatestEffective  stg
		  WHERE stg.LatestClaimAdiKey <> 0 -- Cancelled claims Removed from UPDATE SET in previous transform 
			 AND stg.LatestClaimRankNum = 1
			 --AND stg.SrcClaimType = 'INST'
		  ) SRC
    ON TRG.clmsKey = SRC.clmsKey
	   and TRG.LatestClaimID <> SRC.LatestCLaimID
    WHEN MATCHED THEN
	   UPDATE SET TRG.LatestClaimAdiKey = SRC.LatestClaimAdiKey
		  , TRG.LatestClaimID = SRC.LatestCLaimID
    ;
    
    	
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
END -- inst Claims

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
BEGIN -- PROF Claims 
    -- declare @LatestDataDate date = '01/01/2021' ; 
    --declare @INpCnt int;
    SELECT @InpCnt =COUNT(*)         
    FROM (SELECT csk.CUR_CLM_UNIQ_ID ClmSKey, csk.srcAdiKey LatestClaimAdiKey
			, csk.srcAdiKey ReplacesAdiKey, csk.CUR_CLM_UNIQ_ID ReplacesClaimId, ch.CLM_ADJSMT_TYPE_CD, GETDATE() ProcessDate
			, ROW_NUMBER() OVER (PARTITION BY csk.CUR_CLM_UNIQ_ID ORDER BY ch.FILEDATE desc) LastClaimRank
			, 'PROF' srcClaimType
			, ROW_NUMBER() OVER(PARTITION BY ch.CUR_CLM_UNIQ_ID ORDER BY ch.clm_LINE_NUM) IsHeader
		FROM ast.pstDeDupClms_PartBPhys csk
		  JOIN adi.CCLF5 ch ON csk.srcAdiKey = ch.URN
		  JOIN ast.Claim_01_Header_Dedup ddH ON ch.URN = ddH.SrcAdiKey	   	
				and ddh.SrcClaimType = 'PROF'
		) src
	WHERE src.LastClaimRank = 1
		and src.IsHeader =1
	;


    set @SrcName = 'adi.CCLF5'     ;
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
    
    INSERT INTO [ast].Claim_03_Header_LatestEffective	  
           ([clmSKey],[LatestClaimAdiKey],[LatestClaimID],[ReplacesAdiKey],[ReplacesClaimID],[ProcessDate],[ClaimAdjCode],[LatestClaimRankNum],SrcClaimType)
    OUTPUT INSERTED.clmSKey, inserted.ReplacesAdiKey, inserted.SrcClaimType INTO #OutputTbl(ID, ReplacesAdiKey, srcClaimType)
   SELECT src.clmSKey, src.LatestClaimAdiKey, src.LatestClaimID
		  , src.ReplacesAdiKey, src.ReplacesClaimID
		  , src.ProcessDate, src.CLM_ADJSMT_TYPE_CD
	       , src.LastClaimRank
		  , src.srcClaimType
   FROM (SELECT csk.CUR_CLM_UNIQ_ID ClmSKey, csk.srcAdiKey LatestClaimAdiKey, csk.CUR_CLM_UNIQ_ID LatestClaimID
			, csk.srcAdiKey ReplacesAdiKey, csk.CUR_CLM_UNIQ_ID ReplacesClaimId, ch.CLM_ADJSMT_TYPE_CD, GETDATE() ProcessDate
			, ROW_NUMBER() OVER (PARTITION BY csk.CUR_CLM_UNIQ_ID ORDER BY ch.FILEDATE desc) LastClaimRank
			, 'PROF' srcClaimType
			, ROW_NUMBER() OVER(PARTITION BY ch.CUR_CLM_UNIQ_ID ORDER BY ch.clm_LINE_NUM) IsHeader
		FROM ast.pstDeDupClms_PartBPhys csk
		  JOIN adi.CCLF5 ch ON csk.srcAdiKey = ch.URN
		  JOIN ast.Claim_01_Header_Dedup ddH ON ch.URN = ddH.SrcAdiKey	   	
				and ddh.SrcClaimType = 'PROF'
		) src
	WHERE src.LastClaimRank = 1
		and src.IsHeader =1
	;

    /* TRANSFORM: Remove ClaimsAdjCode Max = 1. These are the cancelled claims. 
	   These rows will not be loaded, so the Latest adikey and ClaimId will be 0 */
    MERGE ast.Claim_03_Header_LatestEffective TRG
    USING(    SELECT stg.clmSKey
			 FROM (    SELECT Stg.clmSKey, MAX(stg.ClaimAdjCode) MaxAdjCode
					   FROM ast.Claim_03_Header_LatestEffective stg
					   WHERE stg.SrcClaimType = 'PROF'
					   GROUP BY stg.clmSKey
				    ) stg
			 WHERE stg.MaxAdjCode = 1
			 ) SRC
    ON TRG.clmSkey = SRC.clmSKey 
    WHEN MATCHED THEN
	   UPDATE SET TRG.LatestClaimAdiKey = 0
		  ,TRG.LatestClaimID = 0
    ;

    
    /* TRANSFORM:  Set the Latest Adikey and ClaimID to the lastest calcd values */
    MERGE ast.Claim_03_Header_LatestEffective  TRG
    USING ( SELECT stg.clmSKey, stg.LatestClaimAdiKey, stg.LatestClaimID
		  FROM ast.Claim_03_Header_LatestEffective  stg
		  WHERE stg.LatestClaimAdiKey <> 0 -- Cancelled claims Removed from UPDATE SET in previous transform 
			 AND stg.LatestClaimRankNum = 1
			 AND stg.SrcClaimType = 'PROF'
		  ) SRC
    ON TRG.clmsKey = SRC.clmsKey
	   and TRG.LatestClaimID <> SRC.LatestCLaimID
    WHEN MATCHED THEN
	   UPDATE SET TRG.LatestClaimAdiKey = SRC.LatestClaimAdiKey
		  , TRG.LatestClaimID = SRC.LatestCLaimID
    ;
    
    	
	SELECT @OutCnt = COUNT(*) FROM #OutputTbl otb WHERE otb.srcClaimType = 'PROF';
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
END -- inst Claims

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */

BEGIN -- RX Claims 
 	-- declare @LatestDataDate date = '01/01/2021' ; 
    --declare @INpCnt int;
    SELECT @InpCnt =COUNT(*)     
    FROM (SELECT csk.clmSKey, ch.adiCCLF7_SKey  
		  , ROW_NUMBER() OVER (PARTITION BY csk.clmSKey ORDER BY ch.FileDate desc) LastEffective
		FROM ast.Claim_02_HeaderSuperKey csk
		  JOIN adi.CCLF7 ch ON csk.clmSKey= ch.CUR_CLM_UNIQ_ID
		  JOIN ast.Claim_01_Header_Dedup ddH ON ch.adiCCLF7_SKey = ddH.SrcAdiKey	   	
		WHERE ddh.SrcClaimType = 'RX'
		) src
	WHERE src.LastEffective = 1;

    set @SrcName = 'adi.CCLF7'     ;
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
    
    INSERT INTO [ast].Claim_03_Header_LatestEffective	  
           ([clmSKey],[LatestClaimAdiKey],[LatestClaimID],[ReplacesAdiKey],[ReplacesClaimID],[ProcessDate],[ClaimAdjCode],[LatestClaimRankNum],SrcClaimType)
    OUTPUT INSERTED.clmSKey, inserted.ReplacesAdiKey, inserted.SrcClaimType INTO #OutputTbl(ID, ReplacesAdiKey, srcClaimType)
    SELECT csk.clmSKey, ch.adiCCLF7_SKey LatestClaimAdiKey, ch.CUR_CLM_UNIQ_ID AS LastestClaimID
		  , ch.adiCCLF7_SKey ReplacesClaimAdiKey, ch.CUR_CLM_UNIQ_ID AS ReplacesClaimID
		  , ch.FileDate, ch.CLM_ADJSMT_TYPE_CD AS AdjCode -- denied get removed
	       , ROW_NUMBER() OVER (PARTITION BY csk.clmSKey ORDER BY ch.fileDate desc) LastClaimRank
		  , ddh.SrcClaimType
    FROM ast.Claim_02_HeaderSuperKey csk	
		  JOIN adi.CCLF7 ch ON csk.clmSKey= ch.CUR_CLM_UNIQ_ID
		  JOIN ast.Claim_01_Header_Dedup ddH ON ch.adiCCLF7_SKey = ddH.SrcAdiKey	   	
	WHERE ddh.SrcClaimType = 'RX'
    ;

    /* TRANSFORM: Remove ClaimsAdjCode Max = 1. These are the cancelled claims. 
	   These rows will not be loaded, so the Latest adikey and ClaimId will be 0 */
    MERGE ast.Claim_03_Header_LatestEffective TRG
    USING(    SELECT stg.clmSKey
			 FROM (    SELECT Stg.clmSKey, MAX(stg.ClaimAdjCode) MaxAdjCode
					   FROM ast.Claim_03_Header_LatestEffective stg
					   WHERE stg.SrcClaimType = 'RX'
					   GROUP BY stg.clmSKey
				    ) stg
			 WHERE stg.MaxAdjCode = 3
			 ) SRC
    ON TRG.clmSkey = SRC.clmSKey 
    WHEN MATCHED THEN
	   UPDATE SET TRG.LatestClaimAdiKey = 0
		  ,TRG.LatestClaimID = 0
    ;

    
    /* TRANSFORM:  Set the Latest Adikey and ClaimID to the lastest calcd values */
    MERGE ast.Claim_03_Header_LatestEffective  TRG
    USING ( SELECT stg.clmSKey, stg.LatestClaimAdiKey, stg.LatestClaimID
		  FROM ast.Claim_03_Header_LatestEffective  stg
		  WHERE stg.LatestClaimAdiKey <> 0 -- Cancelled claims Removed from UPDATE SET in previous transform 
			 AND stg.LatestClaimRankNum = 1
			 AND stg.SrcClaimType = 'RX'
		  ) SRC
    ON TRG.clmsKey = SRC.clmsKey
	   and TRG.LatestClaimID <> SRC.LatestCLaimID
    WHEN MATCHED THEN
	   UPDATE SET TRG.LatestClaimAdiKey = SRC.LatestClaimAdiKey
		  , TRG.LatestClaimID = SRC.LatestCLaimID
    ;
    
    	
	SELECT @OutCnt = COUNT(*) FROM #OutputTbl otb WHERE otb.srcClaimType = 'RX';
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

END -- RX Claims

	   
