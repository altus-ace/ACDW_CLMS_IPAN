CREATE PROCEDURE [adw].[p_LoadDimDate]
	@Year int 
	
AS
BEGIN	
	/* Objective: add a year of dates to the date dim
    0. open a log
    1. write rows
    2. close log.
    3. capture errors and roll back and log    */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    
    DECLARE @JobType SmallInt = 8	  -- adw load    
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'LoadDimDate'
    DECLARE @DestName VARCHAR(100) = 'adw.DimDate'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;

    /* local var for procedure */    
    declare @dFirst DATE = DATEFROMPARTS(@Year, 1,1);
    declare @dLast DATE = DATEFROMPARTS(@Year,12,31);
    declare @dCur DATE = @dFirst;
    declare @d INT	= 0;
    declare @m INT	= 0;
    declare @y INT = 0;
    declare @iDate INT = 0;

	SELECT	@InpCnt = DATEDIFF(day, DATEADD(day, -1, @dFirst), @dLast);
	
	EXEC amd.sp_AceEtlAudit_Open 
		@AuditID = @AuditID OUTPUT
		, @AuditStatus = @JobStatus
		, @JobType = @JobType
		, @ClientKey = 0		-- no client = all clients
		, @JobName = @JobName
		, @ActionStartTime = @ActionStart
		, @InputSourceName = @SrcName
		, @DestinationName = @DestName
		, @ErrorName = @ErrorName
		;  
    CREATE TABLE #Output (StagingKey INT);   
    BEGIN TRY 
		BEGIN TRAN InsertDates
		WHILE @dCur <= @dLast
		BEGIN
			  SET @d = DAY(@dCur);
			  SET @m = Month(@dCur);
			  SET @y = Year(@dCur);		  
			  set @iDate = (@y * 10000) + (@m * 100) + (@d) ;

			INSERT INTO adw.dimDate (dateKey, LoadDate, dDate, dDay, dMonth, dYear) 
			OUTPUT Inserted.dateKey INTO #Output	   
			VALUES (@iDate, GETDATE(), @dCur, @d,@m, @y);
			--select @iDate, GETDATE(), @dCur, @d,@m, @y	 
			SET @dCur = DATEADD(day, 1, @dCur);
		END
		
		COMMIT TRAN InsertDates;
	END TRY
	BEGIN CATCH
	EXEC AceMetaData.amd.TCT_DbErrorWrite;          
	      IF (XACT_STATE()) = -1      
	   	  BEGIN      
	   	  ROLLBACK TRANSACTION          
	   	  END    	   
	      IF (XACT_STATE()) = 1      
	   	  BEGIN      
	   	  COMMIT TRANSACTION    ;         
	      END       
	      /* write error log close */          
		  SET @ActionStart = getdate();              		      
		  SELECT @OutCnt= 0;      
		  SET @ErrCnt = @InpCnt;      
		  SET @JobStatus = 3 -- error      
		  EXEC amd.sp_AceEtlAudit_Close       
		    @AuditId = @AuditID      
		    , @ActionStopTime = @ActionStart      
		    , @SourceCount = @InpCnt          
		    , @DestinationCount = @OutCnt      
		    , @ErrorCount = @ErrCnt      
		    , @JobStatus = @JobStatus      
		    ;      
		  ;THROW      	      

    END CATCH;    
        
    SET	@ActionStart  = GETDATE();
    SET	@JobStatus =2  
    SELECT @OutCnt = COUNT(StagingKey) FROM #Output  
	    				
    EXEC	  amd.sp_AceEtlAudit_Close 
		@AuditId = @AuditID
		, @ActionStopTime = @ActionStart
		, @SourceCount = @InpCnt		  
		, @DestinationCount = @OutCnt
		, @ErrorCount = @ErrCnt
		, @JobStatus = @JobStatus;
END;      


