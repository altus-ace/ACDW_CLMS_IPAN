CREATE PROCEDURE [adw].[zz_AMG_Load_Pdw_03_LatestEffectiveClmsHeader]( 
    @LatestDataDate DATE = '12/31/2099'
    )
AS 
	/* PURPOSE: Get Latest Claims Header Seq_claims_id 
			 1. Use the super key to find duplicated cliams: BCBS CLAIM ID IS SUPERKEY the only dups will be month over month
			 2. order by activity_date desc 
			 
			 */

   
    ;DECLARE @lLoadDate Date;
	IF @LatestDataDate = '12/31/2099'
	   BEGIN 
		  SELECT @lLoadDate = Max(ch.datadate)		  		  
		  FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimHdr] ch
		  WHERE ch.PG_ID = 'TX000425'  
			and ch.InstitutionalIndicator = 'Y'
	   END
    ELSE SET @lLoadDate = @LatestDataDate;

    /* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 9	  -- AST load
    DECLARE @ClientKey INT	 = 16; -- mssp
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.Amerigroup_MedClaimHdr'
    DECLARE @DestName VARCHAR(100) = 'ast.Claim_02_HeaderSuperKey'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;

    CREATE TABLE #OutputTbl (ID VARCHAR(50) NOT NULL, ReplacesAdiKey VARCHAR(50) NOT NULL, srcClaimType CHAR(4), PRIMARY KEY (ID, ReplacesAdiKey, srcClaimType) );	
    TRUNCATE TABLE ast.Claim_03_Header_LatestEffective;
BEGIN -- inst Claims 
    SELECT --@InpCnt =
    COUNT(*) 
		FROM (SELECT ch.MedClaimHdrKey ClaimSKey, ch.ClaimNbr ClaimID, ch.OriginalFileName, DataDate,
	           ROW_NUMBER() OVER(PARTITION BY ch.ClaimNbr ORDER BY ch.DataDate DESC, ch.OriginalFileName ASC) arn
		  FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimHdr] Ch
			JOIN ast.Claim_01_Header_Dedup ddH ON ch.MedClaimHdrKey = ddH.SrcAdiKey  
		  WHERE ch.PG_ID = 'TX000425'
			AND (Ch.InstitutionalIndicator = 'Y' or ch.ProfessionalIndicator = 'Y')
			AND  ch.DataDate <= @lLoadDate 
			) s
			WHERE s.arn = 1
          
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
    SELECT csk.clmSKey
			, ch.MedClaimHdrKey LatestClaimAdiKey
			, ch.ClaimNbr AS LastestClaimID
		  , ch.MedClaimHdrKey ReplacesClaimAdiKey
		  , ch.ClaimNbr AS ReplacesClaimID
		  , ch.DataDate
		  , 0 as AdjCode
		  --, CASE WHEN (ch.ClaimHeaderStatusCode = 1) THEN 0 ELSE 1 END AS AdjCode -- denied get removed
	       ,  ROW_NUMBER() OVER (PARTITION BY ch.ClaimNbr ORDER BY ch.DataDate DESC, ch.OriginalFileName ) LastClaimRank 
		  , ddh.SrcClaimType
    FROM ast.Claim_02_HeaderSuperKey csk
	   JOIN  [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimHdr] Ch  ON csk.clmSKey= ch.ClaimNbr	   			
	   JOIN ast.Claim_01_Header_Dedup ddH ON ch.MedClaimHdrKey = ddH.SrcAdiKey	  
    WHERE ch.DataDate <= @LatestDataDate	
    --AND ddH.SrcClaimType = 'INST' I removed thes as we are loading both INST and PROF into this table
    ;
	

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
/*
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
BEGIN -- PROF Claims 
    -- declare @LatestDataDate date = '01/01/2021' ; 
    --declare @INpCnt int;
    SELECT @InpCnt =COUNT(*)     
    FROM (SELECT csk.clmSKey, ch.ProfessionalClaimKey	    
		  , ROW_NUMBER() OVER (PARTITION BY csk.clmSKey ORDER BY ch.DataDate desc) LastEffective
		FROM ast.Claim_02_HeaderSuperKey csk
		  JOIN adi.Steward_BCBS_ProfessionallClaim ch ON csk.clmSKey= ch.ClaimID	   			
		  JOIN ast.Claim_01_Header_Dedup ddH ON ch.ProfessionalClaimKey = ddH.SrcAdiKey	   	
		WHERE ch.DataDate <= @LatestDataDate		 
		  and ddh.SrcClaimType = 'PROF'
		) src
	WHERE src.LastEffective = 1;

    set @SrcName = 'adi.Steward_BCBS_ProfessionallClaim'     ;
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
    SELECT csk.clmSKey, ch.ProfessionalClaimKey LatestClaimAdiKey, ch.ClaimID AS LastestClaimID
		  , ch.ProfessionalClaimKey ReplacesClaimAdiKey, ch.ClaimID AS ReplacesClaimID
		  , ch.DataDate, CASE WHEN (ch.ClaimHeaderStatusCode = 1) THEN 0 ELSE 1 END AS AdjCode -- denied get removed
	       , ROW_NUMBER() OVER (PARTITION BY csk.clmSKey ORDER BY ch.DataDate desc) LastClaimRank
		  , ddh.SrcClaimType
    FROM ast.Claim_02_HeaderSuperKey csk
	   JOIN adi.Steward_BCBS_ProfessionallClaim ch ON csk.clmSKey= ch.ClaimID	   			
	   JOIN ast.Claim_01_Header_Dedup ddH ON ch.ProfessionalClaimKey = ddH.SrcAdiKey	  
    WHERE ch.DataDate <= @LatestDataDate	AND ddH.SrcClaimType = 'PROF'
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
    FROM (SELECT csk.clmSKey, ch.RXClaimKey	    
		  , ROW_NUMBER() OVER (PARTITION BY csk.clmSKey ORDER BY ch.DataDate desc) LastEffective
		FROM ast.Claim_02_HeaderSuperKey csk
		  JOIN adi.Steward_BCBS_RXClaim ch ON csk.clmSKey= ch.ClaimID	   			
		  JOIN ast.Claim_01_Header_Dedup ddH ON ch.RXClaimKey = ddH.SrcAdiKey	   	
		WHERE ch.DataDate <= @LatestDataDate		 
		  and ddh.SrcClaimType = 'RX'
		) src
	WHERE src.LastEffective = 1;

    set @SrcName = 'adi.Steward_BCBS_RXClaim'     ;
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
    SELECT csk.clmSKey, ch.RXClaimKey LatestClaimAdiKey, ch.ClaimID AS LastestClaimID
		  , ch.RXClaimKey ReplacesClaimAdiKey, ch.ClaimID AS ReplacesClaimID
		  , ch.DataDate, CASE WHEN (ch.ClaimStatusCode = 'N1') THEN 0 ELSE 1 END AS AdjCode -- denied get removed
	       , ROW_NUMBER() OVER (PARTITION BY csk.clmSKey ORDER BY ch.DataDate desc) LastClaimRank
		  , ddh.SrcClaimType
    FROM ast.Claim_02_HeaderSuperKey csk
	   JOIN adi.Steward_BCBS_RXClaim ch ON csk.clmSKey= ch.ClaimID	   			
	   JOIN ast.Claim_01_Header_Dedup ddH ON ch.RXClaimKey = ddH.SrcAdiKey	  
    WHERE ch.DataDate <= @LatestDataDate	
    AND ddH.SrcClaimType = 'RX';

    /* TRANSFORM: Remove ClaimsAdjCode Max = 1. These are the cancelled claims. 
	   These rows will not be loaded, so the Latest adikey and ClaimId will be 0 */
    MERGE ast.Claim_03_Header_LatestEffective TRG
    USING(    SELECT stg.clmSKey
			 FROM (    SELECT Stg.clmSKey, MAX(stg.ClaimAdjCode) MaxAdjCode
					   FROM ast.Claim_03_Header_LatestEffective stg
					   WHERE stg.SrcClaimType = 'RX'
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
*/
