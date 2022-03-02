CREATE PROCEDURE [adw].[zz_AMG_Load_Pdw_02_ClaimsSuperKey]( 
    @LatestDataDate DATE = '12/31/2099'
    )
/* PURPOSE:  Create a ClaimNumber. : list of business key fields and the calculated seq_claim_id 
		  We also do filtering for "ace valid cliams" here

		  THIS IS AT THE GRAIN OF THE DETAIL
    */
AS 
BEGIN
    --declare @latestDataDate date = '12/31/2099'
	DECLARE @lLoadDate Date;
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
    
    CREATE TABLE #OutputTbl (SrcAdiKey  VARCHAR(50) NOT NULL, SrcClaimType CHAR(5) NOT NULL, PRIMARY KEY(SrcAdiKey, SrcClaimType));	
    TRUNCATE TABLE ast.Claim_02_HeaderSuperKey;
BEGIN -- Inst Claims
    SELECT @InpCnt = COUNT(distinct s.ClaimID) 	       
    FROM (SELECT ch.MedClaimHdrKey ClaimSKey, ch.ClaimNbr ClaimID, ch.OriginalFileName, DataDate, 
	           ROW_NUMBER() OVER(PARTITION BY ch.ClaimNbr ORDER BY ch.DataDate DESC, ch.OriginalFileName ASC) arn
		  FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimHdr] Ch
			JOIN ast.Claim_01_Header_Dedup ddH ON ch.MedClaimHdrKey = ddH.SrcAdiKey  
		  WHERE ch.PG_ID = 'TX000425'
			AND Ch.InstitutionalIndicator = 'Y'
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
    
    /* create list of clmSkeys: these are all related claims grouped on the cms defined relation criteria 
        and bound under varchar(50) key made from concatenation of all the 4 component parts */
    INSERT INTO ast.Claim_02_HeaderSuperKey(
	   clmSKey
	   , PRVDR_OSCAR_NUM  -- facility
	   , BENE_EQTBL_BIC_HICN_NUM
	   , CLM_FROM_DT
	   , CLM_THRU_DT
	   , ClaimTypeCode
	   , LoadDate
	   , SrcClaimType)
    OUTPUT Inserted.clmsKey, inserted.srcClaimType INTO #OutputTbl(SrcAdiKey, SrcClaimType)
    SELECT DISTINCT 
	   --s.BillingProviderNPI + CONVERT(VARCHAR(25),CONVERT(bigint, s.PatientID))+ CONVERT(VARCHAR(10),SvcFrom.dateKey) + CONVERT(VARCHAR(10), SvcTo.dateKey) AS ClmBigKey	   
	   ClaimNbr AS ClmBigKey  -- use claim id for now, no big key found
	   , Ch.BillingProviderNPI
	   , Ch.MasterConsumerID
	   , ch.FromDate
	   , ch.ToDate
	   , 'UB-INST' ClaimType--Literal from mapping
	   , Ch.datadate
	   , ddh.SrcClaimType
    FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimHdr] Ch
			JOIN ast.Claim_01_Header_Dedup ddH ON ch.MedClaimHdrKey = ddH.SrcAdiKey  
		  WHERE ch.PG_ID = 'TX000425'
			AND Ch.InstitutionalIndicator = 'Y'
			AND  ch.DataDate <= @lLoadDate 
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
BEGIN -- Prof Claims

    --declare @lLoadDate date = '01/01/2021'
	 SELECT @InpCnt = COUNT(distinct s.ClaimID) 	       
    FROM (SELECT ch.MedClaimHdrKey ClaimSKey, ch.ClaimNbr ClaimID, ch.OriginalFileName, DataDate, 
	           ROW_NUMBER() OVER(PARTITION BY ch.ClaimNbr ORDER BY ch.DataDate DESC, ch.OriginalFileName ASC) arn
		  FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimHdr] Ch
			JOIN ast.Claim_01_Header_Dedup ddH ON ch.MedClaimHdrKey = ddH.SrcAdiKey  
		  WHERE ch.PG_ID = 'TX000425'
			AND Ch.InstitutionalIndicator = 'Y'
			AND  ch.DataDate <= @lLoadDate 
		) s
	WHERE s.arn = 1

    SELECT @InpCnt = COUNT(distinct s.ClaimID) 	           
     FROM (SELECT ch.MedClaimHdrKey ClaimSKey, ch.ClaimNbr ClaimID, ch.OriginalFileName, DataDate, 
	           ROW_NUMBER() OVER(PARTITION BY ch.ClaimNbr ORDER BY ch.DataDate DESC, ch.OriginalFileName ASC) arn
			   FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimHdr] Ch
					JOIN ast.Claim_01_Header_Dedup ddH ON ch.MedClaimHdrKey = ddH.SrcAdiKey  
				WHERE ch.PG_ID = 'TX000425'
					AND Ch.ProfessionalIndicator = 'Y'
					AND  ch.DataDate <= @lLoadDate 
			)s
	WHERE s.arn = 1
    set @SrcName =  'adi.Amerigroup_MedClaimHdr';
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
	   , ClaimTypeCode
	   , LoadDate
	   , srcClaimType)
    OUTPUT Inserted.clmsKey, inserted.srcClaimType INTO #OutputTbl(SrcAdiKey, SrcClaimType)
    
    SELECT DISTINCT 
	   --s.BillingProviderNPI + CONVERT(VARCHAR(25),CONVERT(bigint, s.PatientID))+ CONVERT(VARCHAR(10),SvcFrom.dateKey) + CONVERT(VARCHAR(10), SvcTo.dateKey) AS ClmBigKey	   
	   ClaimNbr AS ClmBigKey  -- use claim id for now, no big key found
	   , Ch.BillingProviderNPI
	   , Ch.MasterConsumerID
	   , ch.FromDate
	   , ch.ToDate
	   , 'PROF' ClaimType--Literal from mapping
	   , Ch.datadate
	   , ddh.SrcClaimType
    FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimHdr] Ch
			JOIN ast.Claim_01_Header_Dedup ddH ON ch.MedClaimHdrKey = ddH.SrcAdiKey  
		  WHERE ch.PG_ID = 'TX000425'
			AND Ch.ProfessionalIndicator = 'Y'
			AND  ch.DataDate <= @lLoadDate 
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
END;
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/*
BEGIN -- rx Claims

    --declare @lLoadDate date = '01/01/2021'
    SELECT @InpCnt = COUNT(distinct s.ClaimID) 	              
    FROM adi.Steward_BCBS_RXClaim s
		JOIN ast.Claim_01_Header_Dedup ddH ON s.RXClaimKey = ddH.SrcAdiKey  -- 375849
    WHERE s.DataDate <= @lLoadDate 	   
	   and ddH.SrcClaimType = 'RX';    

    set @SrcName =  'adi.Steward_BCBS_RXClaim';
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
	   , ClaimTypeCode
	   , LoadDate
	   , srcClaimType)
    OUTPUT Inserted.clmsKey, inserted.srcClaimType INTO #OutputTbl(SrcAdiKey, SrcClaimType)
    
    SELECT DISTINCT 
	   --s.BillingProviderNPI + CONVERT(VARCHAR(25),CONVERT(bigint, s.PatientID))+ CONVERT(VARCHAR(10),SvcFrom.dateKey) + CONVERT(VARCHAR(10), SvcTo.dateKey) AS ClmBigKey	   
	   s.ClaimID AS ClmBigKey  -- use claim id for now, no big key found
	   , s.ProviderNPI	   
	   , s.PatientID
	   , s.ServiceDATE
	   , s.ServiceDATE
	   , 'PROF' ClaimType--Literal from mapping
	   ,s.datadate
	   , ddh.SrcClaimType
     FROM adi.Steward_BCBS_RXClaim s
		JOIN ast.Claim_01_Header_Dedup ddH ON s.RXClaimKey = ddH.SrcAdiKey  -- 375849
    WHERE s.DataDate <= @lLoadDate 
	   --and ClaimRecordID = 'CLM'
	   and ddH.SrcClaimType = 'RX';    
    
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
*/

END;
