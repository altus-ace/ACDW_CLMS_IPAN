
CREATE PROCEDURE  [adw].[Load_Pdw_24_ClmsDiagsPartBPhys]
AS -- insert claims diags for Steward_MSSPPartBPhysicianClaimLineItem
	/* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 8	  -- AST load
    DECLARE @ClientKey INT	 = 16; -- mssp
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF5'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Diags'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
	SELECT @InpCnt = COUNT(*) 
	FROM ast.ClaimDiag_UnPivot p
	WHERE p.SrcClaimType = 'PROF'
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

	INSERT INTO adw.Claims_Diags
     (	-- URN         loaded by default
		 SEQ_CLAIM_ID  
		,SUBSCRIBER_ID
		,ICD_FLAG 			
		,diagNumber
		,diagCode 
		,diagPoa  
		,LoadDate				
		,SrcAdiTableName
		,SrcAdiKey     
     )					
    OUTPUT inserted.URN INTO #OutputTbl(ID)    
    SELECT	   c5.CUR_CLM_UNIQ_ID	AS SEQ_CLAIM_ID   
			 , c5.BENE_MBI_ID		AS SUBSCRIBER_ID
			 , ''					AS ICD_FLAG   
			 , ast.DiagNum	  		AS diagNumber     			
			 , ast.DiagCD			AS DiagCode
			 , ''				    AS DiagPoa
			 , getDate()			AS LoadDate
			 , @SrcName				AS SrcAdiTableName
			 , ast.SrcAdiKey		as SrcAdiKey			 
    FROM ast.ClaimDiag_UnPivot ast	
		JOIN adi.cclf5 C5 
			ON ast.SrcAdiKey = c5.URN
	WHERE ast.srcClaimType = 'PROF'
	;


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
