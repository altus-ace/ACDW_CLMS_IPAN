CREATE PROCEDURE [adw].[Load_Pdw_02_ClaimsSuperKey]( 
    @LatestDataDate DATE = '12/31/2099'
    )
/* PURPOSE:  Create a ClaimNumber. : list of business key fields and the calculated seq_claim_id 
		  We also do filtering for "ace valid cliams" here

		  THIS IS AT THE GRAIN OF THE DETAIL
    */
AS 
BEGIN    	

	/* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 9	  -- AST load
    DECLARE @ClientKey INT	 = 25; -- ipan
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCL1'
    DECLARE @DestName VARCHAR(100) = 'ast.Claim_02_HeaderSuperKey'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
    
    CREATE TABLE #OutputTbl (SrcAdiKey  VARCHAR(50) NOT NULL, SrcClaimType CHAR(5) NOT NULL, PRIMARY KEY(SrcAdiKey, SrcClaimType));	
    TRUNCATE TABLE ast.Claim_02_HeaderSuperKey;
BEGIN -- Inst Claims
    SELECT @InpCnt = COUNT(distinct ch.clmBigKey) 	       
    FROM (SELECT S.PRVDR_OSCAR_NUM +'.'+S.SubscriberId+'.'+convert(varchar(10), S.CLM_FROM_DT,101)+'.'+CONVERT(varchar(10), S.CLM_THRU_DT,101) AS clmBigKey
				,S.PRVDR_OSCAR_NUM ,S.SubscriberId, S.CLM_FROM_DT,S.CLM_THRU_DT, S.SrcClaimType, S.FileDate
			FROM (SELECT 
					DISTINCT  PRVDR_OSCAR_NUM, CLM_FROM_DT,	 CLM_THRU_DT,	  ch.BENE_MBI_ID SubscriberId
						,ddH.SrcClaimType , ch.FileDate
					FROM adi.CCLF1 ch
						JOIN ast.Claim_01_Header_Dedup ddH ON ch.urn = ddH.SrcAdiKey
							AND ddh.SrcClaimType = 'INST'
						) S
		) ch
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
    
    /* create list of clmSkeys: these are all related claims grouped on the cms defined relation criteria 
        and bound under varchar(50) key made from concatenation of all the 4 component parts */
    INSERT INTO ast.Claim_02_HeaderSuperKey(
	   clmSKey
	   , PRVDR_OSCAR_NUM  -- facility
	   , BENE_EQTBL_BIC_HICN_NUM
	   , CLM_FROM_DT
	   , CLM_THRU_DT	   
	   , LoadDate
	   , SrcClaimType)
    OUTPUT Inserted.clmsKey, inserted.srcClaimType INTO #OutputTbl(SrcAdiKey, SrcClaimType)
    SELECT DISTINCT 
		 ch.clmBigKey 
	   , ch.PRVDR_OSCAR_NUM
	   , ch.SubscriberId
	   , ch.CLM_FROM_DT
	   , ch.CLM_THRU_DT
	   , ch.FileDate
	   , ch.SrcClaimType
     FROM (SELECT S.PRVDR_OSCAR_NUM +'.'+S.SubscriberId+'.'+convert(varchar(10), S.CLM_FROM_DT,101)+'.'+CONVERT(varchar(10), S.CLM_THRU_DT,101) AS clmBigKey
				,S.PRVDR_OSCAR_NUM ,S.SubscriberId, S.CLM_FROM_DT,S.CLM_THRU_DT, S.SrcClaimType, S.FileDate
			FROM (SELECT 
					DISTINCT  PRVDR_OSCAR_NUM, CLM_FROM_DT,	 CLM_THRU_DT,	  ch.BENE_MBI_ID SubscriberId
						,ddH.SrcClaimType , ch.FileDate
					FROM adi.CCLF1 ch
						JOIN ast.Claim_01_Header_Dedup ddH ON ch.urn = ddH.SrcAdiKey
							AND ddh.SrcClaimType = 'INST'
						) S
		) ch
	;    
    SELECT @OutCnt = COUNT(*) FROM #OutputTbl otb WHERE otb.srcClaimType = 'INST'; 
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
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
-- professional claims loaded with 07 sp
/*
BEGIN -- Prof Claims
    
	SELECT @InpCnt = COUNT(distinct ch.clmBigKey) 	       	
	-- RNDRG_PRVDR_NPI_NUM + BENE_MBI_ID + CLM_FROM_DT_ + CLM_THRU_DT
    FROM (select CONVERT(VARCHAR(13), c5.CUR_CLM_UNIQ_ID)+'.'+c5.RNDRG_PRVDR_NPI_NUM +'.'+c5.BENE_MBI_ID+'.'+convert(varchar(10), c5.CLM_FROM_DT,101)+'.'+CONVERT(varchar(10), c5.CLM_THRU_DT,101) AS clmBigKey 
			  ,c5.RNDRG_PRVDR_NPI_NUM, c5.BENE_MBI_ID, CLM_FROM_DT, CLM_THRU_DT 
    		  , fileDate, srcfileName , ddh.SrcClaimType   
			  , ROW_NUMBER() OVER (partition by CUR_CLM_UNIQ_ID ORDER BY FileDate Desc , clm_line_num ASC) arn
           FROM adi.cclf5	c5
			JOIN ast.Claim_01_Header_Dedup ddh 
				ON c5.URN = ddh.SrcAdiKey and ddh.SrcClaimType = 'PROF'
		) ch
		WHERE ch.arn = 1;	

    set @SrcName =  'adi.CCLF5';
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
    
    /* create list of clmSkeys: these are all related claims grouped on the cms defined relation criteria 
        and bound under varchar(50) key made from concatenation of all the 4 component parts */
    INSERT INTO ast.Claim_02_HeaderSuperKey(
	   clmSKey
	   , PRVDR_OSCAR_NUM  -- facility
	   , BENE_EQTBL_BIC_HICN_NUM
	   , CLM_FROM_DT
	   , CLM_THRU_DT
	   , LoadDate
	   , srcClaimType)
    OUTPUT Inserted.clmsKey, inserted.srcClaimType INTO #OutputTbl(SrcAdiKey, SrcClaimType)    
	SELECT ch.clmBigKey, ch.RndrgProvID, ch.BENE_MBI_ID, ch.CLM_FROM_DT, ch.CLM_THRU_DT, ch.FileDate, ch.srcClaimType
	FROM (select CONVERT(VARCHAR(13), c5.CUR_CLM_UNIQ_ID)+'.'+c5.RNDRG_PRVDR_NPI_NUM +'.'+c5.BENE_MBI_ID+'.'+convert(varchar(10), c5.CLM_FROM_DT,101)+'.'+CONVERT(varchar(10), c5.CLM_THRU_DT,101) AS clmBigKey 
			  ,c5.RNDRG_PRVDR_NPI_NUM RndrgProvId, c5.BENE_MBI_ID, CLM_FROM_DT, CLM_THRU_DT 
    		  , fileDate, srcfileName , ddh.SrcClaimType   
			  , ROW_NUMBER() OVER (partition by CUR_CLM_UNIQ_ID ORDER BY FileDate Desc , clm_line_num ASC) arn
           FROM adi.cclf5	c5
			JOIN ast.Claim_01_Header_Dedup ddh 
				ON c5.URN = ddh.SrcAdiKey and ddh.SrcClaimType = 'PROF'
		) ch
	WHERE ch.arn = 1;	
	
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
END;
*/

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */

BEGIN -- rx Claims

    --declare @lLoadDate date = '01/01/2021'
    SELECT @InpCnt = COUNT(distinct s.CUR_CLM_UNIQ_ID) 	                  
	FROM adi.CCLF7 s
		JOIN ast.Claim_01_Header_Dedup ddH ON s.adiCCLF7_SKey = ddH.SrcAdiKey  -- 375849
    WHERE ddH.SrcClaimType = 'RX';    

    set @SrcName =  'adi.CCLF7';
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
    
    /* create list of clmSkeys: these are all related claims grouped on the cms defined relation criteria 
        and bound under varchar(50) key made from concatenation of all the 4 component parts */
    INSERT INTO ast.Claim_02_HeaderSuperKey(
	   clmSKey
	   , PRVDR_OSCAR_NUM  -- facility
	   , BENE_EQTBL_BIC_HICN_NUM
	   , CLM_FROM_DT
	   , CLM_THRU_DT
	   , LoadDate
	   , srcClaimType)
    OUTPUT Inserted.clmsKey, inserted.srcClaimType INTO #OutputTbl(SrcAdiKey, SrcClaimType)
    
    SELECT DISTINCT 
	   --s.BillingProviderNPI + CONVERT(VARCHAR(25),CONVERT(bigint, s.PatientID))+ CONVERT(VARCHAR(10),SvcFrom.dateKey) + CONVERT(VARCHAR(10), SvcTo.dateKey) AS ClmBigKey	   
	   s.CUR_CLM_UNIQ_ID AS ClmBigKey  -- use claim id for now, no big key found
	   , s.CLM_SRVC_PRVDR_GNRC_ID_NUM
	   , s.BENE_MBI_ID
	   , s.CLM_LINE_FROM_DT
	   , s.CLM_LINE_FROM_DT	   
	   , s.FileDate
	   , ddh.SrcClaimType
     FROM adi.CCLF7 s
		JOIN ast.Claim_01_Header_Dedup ddH ON s.adiCCLF7_SKey = ddH.SrcAdiKey  
    WHERE ddH.SrcClaimType = 'RX';    
    
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
	   
END;


END;
