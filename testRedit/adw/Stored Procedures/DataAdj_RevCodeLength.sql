CREATE PROCEDURE [adw].[DataAdj_RevCodeLength]
AS -- check if CASE WHEN try_convert(int, c.RevenueCenterCD) > 999 THEN 'BOOM' else 'OK' End as aCheck before and error so we don't lose data.
    /* prepare logging */
	DECLARE @AuditId INT;    
	DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
	DECLARE @JobType SmallInt = 12	  -- AST load
	DECLARE @ClientKey INT	 = 16; -- mssp
	DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.Claims_Headers'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Headers'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
    SELECT @InpCnt = COUNT(*) 
	FROM adw.Claims_Details AS details
	WHERE details.REVENUE_CODE <> ''
		AND LEN(details.REVENUE_CODE) >3;

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
	CREATE TABLE #OutputTbl (ID INT PRIMARY KEY NOT NULL);	

	ALTER TABLE adw.Claims_Details DISABLE TRIGGER [ClaimsDetails_AfterUpdate];
	
	UPDATE details 		
		SET details.REVENUE_CODE = RIGHT(details.REVENUE_CODE,3)
	OUTPUT inserted.ClaimsDetailsKey INTO #OutputTbl(ID)
    FROM adw.Claims_Details AS details
	WHERE details.REVENUE_CODE <> ''
		AND LEN(details.REVENUE_CODE) >3;
    
	ALTER TABLE adw.Claims_Details ENABLE TRIGGER [ClaimsDetails_AfterUpdate];

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
