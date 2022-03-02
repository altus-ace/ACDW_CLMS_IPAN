
/*  Trans Members	   */

CREATE PROCEDURE [ast].[p_Pdw_TransformFctMembership]
    (  @ClientKey INT, @RwExpirationDate DATE)
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

    SELECT	@InpCnt = COUNT(src.mbrMemberKey)    
	   FROM	ast.FctMembership src
	   where src.ClientKey = @ClientKey
		AND src.stgRowStatus in ('Loaded', 'Valid');
     
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
	   
						
	   -- DECLARE @AsOfDate DATE = GETDATE();
	   -- DECLARE @ClientKey INT = 16;    
	   -- what to Tranform
	   -- 1. calc row dates
	   -- 2. calc active member value
	   -- 3. add other as they are defined
		/* update row effective and and row Expiration dates */

	    /* SET RowEffectiveDates, RowExpirationDates, Active, CurrentAge */
		UPDATE ast SET  ast.RowEffectiveDate = dates.MinDateInMonth
			, ast.RowExpirationDate = dates.MaxDateInMonth
			, ast.Active = 1 -- temp value untill we fix the Excluded file use
			, ast.CurrentAge = DATEDIFF(Year, Demo.DOB, ast.RowEffectiveDate) 
		OUTPUT inserted.FctMembershipSkey into #Output
		FROM ast.FctMembership ast			
		    JOIN (SELECT Dd.dDate, dd.dYear, dd.dMonth
				  FROM adw.dimDate Dd) DimDate
				  ON ast.LoadDate = DimDate.dDate 
		    JOIN (SELECT dimDate.dDate, min(DateInMonth.dDate) MinDateInMonth, Max(DateInMonth.dDate) MaxDateInMonth
				  FROM adw.dimDate dimDate
					 JOIN adw.dimDate DateInMonth 
						ON dimDate.dYear = DateInMonth.dYear
						and dimDate.dMonth = DateInMonth.dMonth
				  GROUP BY dimDate.dDate
						) dates ON dates.dDate =  ast.LoadDate
		  JOIN adw.MbrDemographic Demo ON demo.mbrDemographicKey = ast.MbrDemographicKey
		WHERE ast.stgRowStatus = 'Loaded'	
		
		---Update RwExpirationDate
		UPDATE	ast.FctMembership
		SET	RowExpirationDate = @RwExpirationDate
		WHERE	stgRowStatus = 'Loaded';

		UPDATE ast.FctMembership
		SET	CurrentAge = DATEDIFF(YY,dm.DOB,stg.RowEffectiveDate)
			--   select CurrentAge,DATEDIFF(YY,dm.DOB,stg.RowEffectiveDate),dm.DOB,dm.ClientMemberKey,mbr.ClientMemberKey ,* 
		FROM	ast.FctMembership stg
		JOIN	adw.MbrDemographic dm
		ON		stg.MbrDemographicKey = dm.mbrDemographicKey
		AND		stg.RowEffectiveDate = dm.EffectiveDate
		JOIN	adw.MbrMember mbr
		ON		dm.ClientMemberKey = mbr.ClientMemberKey
		AND		dm.EffectiveDate = mbr.EffectiveDate
		AND		stg.stgRowStatus = 'Loaded';
		

		/* do secondary transforms Calc Age Bands */ 
		/* how to log this. How to error protect it */
		UPDATE ast
		  SET   ast.AgeGroup20Years = CASE WHEN ast.CurrentAge < 21 THEN 1 ELSE 0 END
			 , ast.AgeGroup10Years = CASE WHEN ast.CurrentAge < 11 THEN 1 ELSE 0 END
			 , ast.AgeGroup5Years =  CASE WHEN ast.CurrentAge < 6 THEN 1 ELSE 0 END	 
			 , ast.MbrMonth = MONTH(ast.RowEffectiveDate)
			 , ast.MbrYear	 = YEAR(ast.RowEffectiveDate)		  
		  FROM ast.FctMembership ast	
		  WHERE ast.stgRowStatus = 'Loaded';


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

