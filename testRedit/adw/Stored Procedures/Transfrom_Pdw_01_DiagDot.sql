CREATE PROCEDURE [adw].[Transfrom_Pdw_01_DiagDot]
AS 
	/* prepare logging */
	DECLARE @AuditId INT;    
	DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
	DECLARE @JobType SmallInt = 12	  -- AST load
	DECLARE @ClientKey INT	 = 25; -- iPAN
	DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.Claims_Diags'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Diags'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
    SELECT @InpCnt = COUNT(*) 
	FROM adw.Claims_Diags d
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
	CREATE TABLE #OutputTbl (ID INT PRIMARY KEY NOT NULL);	

    --ALTER TABLE adw.Claims_Diags DISABLE TRIGGER [ClaimsDiags_AfterUpdate];
	    
	UPDATE diags 
		SET diags.diagCodeWithoutDot = REPLACE(diags.diagCode, '.','') 
	OUTPUT inserted.URN INTO #OutputTbl(ID)
	FROM adw.Claims_Diags diags
	;

    --ALTER TABLE adw.Claims_Diags ENABLE TRIGGER [ClaimsDiags_AfterUpdate];

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
