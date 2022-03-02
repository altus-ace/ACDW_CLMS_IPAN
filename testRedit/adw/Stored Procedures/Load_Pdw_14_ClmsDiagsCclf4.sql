
CREATE PROCEDURE [adw].[Load_Pdw_14_ClmsDiagsCclf4]
AS 
   
   /* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 8	  -- AST load
    DECLARE @ClientKey INT	 = 25  -- ipan
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF4'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Diags'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
    SELECT @InpCnt = COUNT(*)     
    FROM ast.Claim_06_Diag_Dedup ast 
	WHERE  ast.SrcClaimType = 'INST'
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
        , @ErrorName	   = @ErrorName
        ;
    CREATE TABLE #OutputTbl (ID INT NOT NULL PRIMARY KEY);	
    INSERT INTO  adw.Claims_Diags
           ([SEQ_CLAIM_ID]
           ,[SUBSCRIBER_ID]
           ,[ICD_FLAG]
           ,[diagNumber]
           ,[diagCode]
           ,[diagPoa]
		   ,LoadDate
		   ,SrcAdiTableName
		   ,SrcAdiKey)
    OUTPUT INSERTED.URN INTO #OutputTbl(ID)
   	SELECT	   cd.CUR_CLM_UNIQ_ID		AS SEQ_CLAIM_ID  
			 , cd.BENE_MBI_ID			AS SUBSCRIBER_ID
			 , ''						AS ICD_FLAG   
			 , cd.CLM_VAL_SQNC_NUM		AS diagNumber     			
			 , cd.CLM_DGNS_CD			AS DiagCode
			 , cd.CLM_POA_IND			AS DiagPoa
			 , getDate()			    AS LoadDate
			 ,  @SrcName				AS SrcAdiTableName
			 , cd.URN					AS adiKey			 
	FROM adi.CCLF4 cd
        JOIN ast.Claim_06_Diag_Dedup ast
			ON cd.URN = ast.DiagAdiKey
	WHERE ast.SrcClaimType = 'INST'		
	ORDER BY cd.CUR_CLM_UNIQ_ID , ast.DiagNum	
	;

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
