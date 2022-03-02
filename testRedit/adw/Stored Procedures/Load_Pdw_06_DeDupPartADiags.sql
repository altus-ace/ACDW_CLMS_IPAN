

CREATE PROCEDURE [adw].[Load_Pdw_06_DeDupPartADiags]( @LatestDataDate DATE = '12/31/2099')
AS 

     /* -- 6. de dup diags

	   get diags sets by claim and line and adj and ???
	   deduplicate for cases:
		  1. deal with duplicates: all relavant details are the same
		  2. deal with adjustments: if details sub line code is different
		  3. deal with???? will determin as we move forward

	   sort by file date or???
	   
	   insert into ast claims dedup diags urns table [pstcDgDeDupUrns]
    */

    DECLARE @DataDate DATE;
   

    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 9	  -- 9: Ast Load, 10: Ast Transform, 11:Ast Validation	
    DECLARE @ClientKey INT	 = 25; -- ipan
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF4'
    DECLARE @DestName VARCHAR(100) = 'ast.pstcDgDeDupUrns'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	

	 -- Inst Claims
    IF @LatestDataDate = '12/31/2099'
	   BEGIN
	   SELECT @DataDate = MAX(ch.FileDate)	   
		  FROM [adi].CCLF4 ch		  
	   END
	   ELSE SET @DataDate = @LatestDataDate;  

	   
    CREATE TABLE #OutputTbl (srcAdikey INT NOT NULL, srcClaimType CHAR(5), PRIMARY KEY(srcAdiKey, srcClaimType));	
    TRUNCATE table ast.Claim_06_Diag_Dedup;


BEGIN -- INst claims 
    SELECT @InpCnt = COUNT(*)     	
	FROM (SELECT c4.URN AS SrcAdiKey, c4.CUR_CLM_UNIQ_ID, c4.CLM_VAL_SQNC_NUM DiagNum, ChdrLatest.SrcClaimType
			   	  , ROW_NUMBER() OVER (PARTITION BY c4.CUR_CLM_UNIQ_ID, c4.CLM_VAL_SQNC_NUM ORDER BY c4.FileDate DESC, c4.originalFileName ASC) aDupID
			FROM ast.Claim_03_Header_LatestEffective ChdrLatest
				JOIN adi.CCLF4  c4 
				ON ChdrLatest.LatestClaimID = c4.CUR_CLM_UNIQ_ID
			WHERE CHdrLatest.SrcClaimType = 'INST'
			) s
	WHERE s.aDupID = 1;

    SET @SrcName = '[adi].CCLF4';
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

    INSERT INTO ast.Claim_06_Diag_Dedup(DiagAdiKey, DiagNum, SrcClaimType)
    OUTPUT inserted.ClaimDiagDedupKey, inserted.SrcClaimType INTO #OutputTbl(srcAdikey, srcClaimType)
    SELECT s.SrcAdiKey, s.DiagNum, s.SrcClaimType
    FROM (SELECT c4.URN AS SrcAdiKey, c4.CUR_CLM_UNIQ_ID, c4.CLM_VAL_SQNC_NUM DiagNum, ChdrLatest.SrcClaimType
			   	  , ROW_NUMBER() OVER (PARTITION BY c4.CUR_CLM_UNIQ_ID, c4.CLM_VAL_SQNC_NUM ORDER BY c4.FileDate DESC, c4.originalFileName ASC) aDupID
			FROM ast.Claim_03_Header_LatestEffective ChdrLatest
				JOIN adi.CCLF4  c4 
				ON ChdrLatest.LatestClaimID = c4.CUR_CLM_UNIQ_ID
			WHERE CHdrLatest.SrcClaimType = 'INST'
			) s
	WHERE s.aDupID = 1;	

	SELECT @OutCnt = COUNT(*) FROM #OutputTbl Otb WHERE Otb.srcClaimType = 'INST'
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
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
BEGIN -- Prof claims 
    --declare @datadate date = '01/01/2021'
    
	/* get a working table */
	/* drop table ast.ClaimDiag_UnPivot 
		CREATE TABLE ast.ClaimDiag_UnPivot (SrcAdiKey INT NOT NULL
			, CLM_LINE_NUM INT NOT NULL
			, DiagCD VARCHAR(20) NOT NULL
			, DiagNum	INT NOT NULL
			, srcClaimType VARCHAR(10)
			) 
	*/
	TRUNCATE TABLE ast.ClaimDiag_UnPivot ;
	
	INSERT INTO ast.claimDiag_UnPivot(SrcAdiKey, CLM_LINE_NUM, DiagCD, DiagNum, srcClaimType )
	SELECT s.SrcAdiKey, s.CLM_LINE_NUM, s.DiagCD, s.DiagNum	, s.srcClaimType	
	FROM (
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_1_CD DiagCD, 1 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_1_CD <> '~' 
			and CHdrLatest.SrcClaimType = 'PROF'
		UNION
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_2_CD DiagCD, 2 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_2_CD <> '~'
			and CHdrLatest.SrcClaimType = 'PROF'
		UNION
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_3_CD DiagCD, 3 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_3_CD <> '~'
			and CHdrLatest.SrcClaimType = 'PROF'
		UNION 
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_4_CD DiagCD, 4 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_4_CD <> '~'
			and CHdrLatest.SrcClaimType = 'PROF'
		UNION
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_5_CD DiagCD, 5 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_5_CD <> '~'
			and CHdrLatest.SrcClaimType = 'PROF'
		UNION
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_6_CD DiagCD, 6 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_6_CD <> '~'
			and CHdrLatest.SrcClaimType = 'PROF'
		UNION
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_7_CD DiagCD, 7 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_7_CD <> '~'
			and CHdrLatest.SrcClaimType = 'PROF'
		UNION
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_8_CD DiagCD, 8 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_8_CD <> '~'
			and CHdrLatest.SrcClaimType = 'PROF'
		UNION
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_9_CD DiagCD, 9 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_9_CD <> '~'
			and CHdrLatest.SrcClaimType = 'PROF'
		UNION
		SELECT s.CUR_CLM_UNIQ_ID, s.URN SrcAdiKey, CLM_LINE_NUM, CHdrLatest.SrcClaimType
			, s.CLM_DGNS_10_CD DiagCD, 10 DiagNum			
			, ROW_NUMBER() OVER (PARTITION BY s.CUR_CLM_UNIQ_ID ORDER BY s.FileDate DESC, s.CLM_LINE_NUM , s.originalFileName ASC) aRN
		FROM ast.Claim_03_Header_LatestEffective CHdrLatest
			JOIN adi.cclf5 s 
			ON CHdrLatest.LatestClaimAdiKey = s.urn
		WHERE s.CLM_DGNS_10_CD <> '~'		
			and CHdrLatest.SrcClaimType = 'PROF'
		) s
	WHERE s.aRN = 1

	


	SELECT @InpCnt = COUNT(*)	
	FROM  ast.ClaimDiag_UnPivot t
	
    SET @SrcName =' [adi].CCLF5';
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

	
	--SrcAdiKey , CLM_LINE_NUM , DiagCD , DiagNum	, srcClaimType 
    INSERT INTO ast.Claim_06_Diag_Dedup(DiagAdiKey, DiagNum, SrcClaimType)
    OUTPUT inserted.ClaimDiagDedupKey, inserted.SrcClaimType INTO #OutputTbl(srcAdikey, srcClaimType)
    SELECT t.SrcAdiKey, t.DiagNum, t.srcClaimType
    FROM ast.ClaimDiag_UnPivot t
    

	SELECT @OutCnt = COUNT(*) FROM #OutputTbl Otb WHERE Otb.srcClaimType = 'PROF'
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
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
-- no rx diags
