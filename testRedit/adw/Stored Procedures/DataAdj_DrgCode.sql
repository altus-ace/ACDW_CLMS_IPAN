CREATE PROCEDURE [adw].[DataAdj_DrgCode]
AS 

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
	FROM adw.Claims_Headers ClmsHdrs		
    WHERE not clmsHdrs.DRG_CODE IS NULL
	   and TRY_CONVERT(int, clmsHdrs.DRG_CODE) is not null
	   and Len(clmsHdrs.DRG_CODE) > 3;

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

    UPDATE ClmsHdrs SET DRG_CODE = SUBSTRING(DRG_CODE, 2,4) 
    --SELECT clmsHdrs.drg_code, SUBSTRING(clmsHdrs.DRG_CODE, 2,4) 
    FROM adw.Claims_Headers ClmsHdrs		
    WHERE not clmsHdrs.DRG_CODE IS NULL
	   and TRY_CONVERT(int, clmsHdrs.DRG_CODE) is not null
	   and Len(clmsHdrs.DRG_CODE) > 3
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
