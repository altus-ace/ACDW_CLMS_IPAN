
CREATE PROCEDURE [adw].[p_Pdw_Master_ProcessFctMembership]
    (  @AsOfDate DATE, @ClientKey INT, @DataDate DATE,@LoadDate DATE, @RwExpirationDate DATE)
AS 
BEGIN
    
    /* Objective: load the keys into the stg.tasks
    0. open a log
    1. capture keys of rows loaded
    2. close log.
    2. capture errors and roll back and log

    */ 
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    
    DECLARE @JobType SmallInt = 9	  -- ast load    
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'ast.FctMembership'
    DECLARE @DestName VARCHAR(100) = 'ast.FctMembership'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;

    SELECT	@InpCnt = 0;	   
     
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
    CREATE TABLE #Output (StagingKey INT);

    BEGIN TRY 
	   BEGIN TRAN   
		---- WARNING!!!!!!!!!!!
		-- For every table truncate, please run the 0RowsKey Code before you running below scripts

	   -- DECLARE @AsOfDate DATE = GETDATE();
	   -- DECLARE @ClientKey INT = 21;    
	   -- load to stag, then Transform, then Validate, then Export to adw fct table
	   EXEC [ast].[p_Pdw_LoadToStgFctMembership] @AsOfDate, @ClientKey,@DataDate;
	   EXEC [ast].[p_Pdw_TransformFctMembership] @ClientKey,@RwExpirationDate;
	   EXEC [ast].[p_Pdw_ValidateFctMembership] @ClientKey
	   EXEC [ast].[p_Pdw_ExportToAdwFctMembership]@AsOfDate, @ClientKey;	
	   EXEC [ast].[pdw_LoadIntoFctMembership]@LoadDate,@ClientKey;

	  
		/*Process Data Date in fctMembership to the source adi DataDate*/
		BEGIN
			EXEC [ast].[pupdateForDataDates]
		END
	   /*Load into tmpAllMemberMonths*/
		EXECUTE ast.pdwMbr_31_Load_MemberMonth_Consolidation @LoadDate,@ClientKey
	 

	   END TRY
        BEGIN CATCH
	      
	      EXEC aceMetaData.amd.TCT_DbErrorWrite;          
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
    COMMIT TRAN;
        
    SET	@ActionStart  = GETDATE();
    SET	@JobStatus =2  
	    				
    EXEC	  amd.sp_AceEtlAudit_Close 
		@AuditId = @AuditID
		, @ActionStopTime = @ActionStart
		, @SourceCount = @InpCnt		  
		, @DestinationCount = @OutCnt
		, @ErrorCount = @ErrCnt
		, @JobStatus = @JobStatus

end;

