
/*  Validate Mbrs	   */

CREATE PROCEDURE [ast].[p_Pdw_ValidateFctMembership]
    (  @ClientKey INT)
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
	DECLARE @Valid VARCHAR(10) = 'Valid';
	DECLARE @NotValid VARCHAR(10) = 'Not Valid';

    SELECT	@InpCnt = COUNT(src.mbrMemberKey)    
    FROM	ast.FctMembership src
    WHERE src.ClientKey = @ClientKey
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
	   -- WHAT TO VALIDATE
	   -- 1. has MRN value, 
	   -- 2. has values for all keys
	   -- 3. has non-zero key for Mbr,Dem, plan, csPlan
	   -- 4. has row dates.		
		--5. npi and tin must have either a real value or 11111111111, 		--    
		-- Process: Test the set for each, if a row is invalid, set it as such, then at end set balance to valid.
	   
	   UPDATE ast SET ast.stgRowStatus = @NotValid	   
		FROM ast.FctMembership ast
			JOIN (		
				SELECT ast.FctMembershipSkey 
					,Case WHEN (ast.Ace_ID <> 0) THEN 1 ELSE 0 END AS IsAceIDValid       
				FROM ast.FctMembership ast
				WHERE ast.stgRowStatus in ('Valid', 'Loaded')
				    and ast.ClientKey = @ClientKey
	   		) IsMrnValid ON ast.FctMembershipSkey = IsMrnValid.FctMembershipSkey
				AND IsMrnValid.IsAceIDValid = 0
				AND ast.ClientKey = @ClientKey;
	
		UPDATE ast SET ast.stgRowStatus = @NotValid				
		FROM ast.FctMembership ast
			JOIN (
				SELECT ast.FctMembershipSkey 
					, CASE WHEN ((CASE WHEN (ISNULL(ast.MbrMemberKey, 0) <> 0) THEN  1 ELSE -1 END) +
							(CASE WHEN (ISNULL(ast.MbrDemographicKey, 0) <> 0) THEN  1 ELSE -1 END) +
							(CASE WHEN (ISNULL(ast.MbrPlanKey, 0) <> 0) THEN  1 ELSE -1 END) +
							(CASE WHEN (ISNULL(ast.MbrCsPlanKey, 0) <> 0) THEN  1 ELSE -1	END) +
							(CASE WHEN (ISNULL(ast.MbrPCPKey, 0) <> 0) THEN  1 ELSE -1	END ) <> 5) 
						THEN 0 ELSE 1  END AS IsNonZeroKeysValid
				FROM ast.FctMembership ast
				WHERE ast.stgRowStatus in ('Valid', 'Loaded')
				    and ast.ClientKey = @ClientKey
			) IsNonZeroKeyValid ON ast.FctMembershipSkey = IsNonZeroKeyValid.FctMembershipSkey
				AND IsNonZeroKeyValid.IsNonZeroKeysValid = 0
				AND ast.ClientKey = @ClientKey;
	  
		UPDATE ast SET ast.stgRowStatus = @NotValid				
		FROM ast.FctMembership ast
		    JOIN ( 
		    SELECT ast.FctMembershipSkey 
			   , CASE WHEN (CASE WHEN (ast.RowEffectiveDate <> '1900/01/01') THEN 1 ELSE 0 END +
					  CASE WHEN (ast.RowExpirationDate <> '1900/01/01')THEN 1 ELSE 0 END = 2) THEN 1 ELSE 0 END AS IsRwEffExpDateValid
		    FROM ast.FctMembership ast
		    WHERE ast.stgRowStatus in ('Valid', 'Loaded')
			 and ast.ClientKey = @ClientKey
		    ) IsRowEffExpDatesValid ON ast.FctMembershipSkey = IsRowEffExpDatesValid.FctMembershipSkey
			 AND IsRowEffExpDatesValid.IsRwEffExpDateValid = 0
			 AND ast.ClientKey = @ClientKey;

		--UPDATE ast SET ast.stgRowStatus = @NotValid		
		--FROM ast.FctMembership ast
		--    JOIN (declare @ClientKey int =20
		--    SELECT ast.FctMembershipSkey 
		--	   , CASE WHEN (CASE WHEN (ISNULL(pcp.Npi ,'0') = 0) THEN 0 ELSE 1 END +
		--				CASE WHEN (ISNULL(pcp.TIN ,'0') = 0) THEN 0 ELSE 1 END) = 2 THEN 1 ELSE 0 END AS IsNpiTinValid
		--    FROM ast.FctMembership ast
		--	   JOIN adw.MbrPcp Pcp ON ast.MbrPCPKey = pcp.mbrPcpKey 
		--    WHERE ast.stgRowStatus in ('Valid', 'Loaded')
		--	 and ast.ClientKey = @ClientKey
		--    ) IsNpiTinValid ON ast.FctMembershipSkey = IsNpiTinValid.FctMembershipSkey
		--	 AND IsNpiTinValid.IsNpiTinValid = 0
		--	 and ast.ClientKey = @ClientKey;
		
		/* set all not set to INVALID to valid */
		UPDATE ast SET ast.stgRowStatus = @Valid
		FROM ast.FctMembership ast
		WHERE ast.stgRowStatus = 'Loaded'
		  AND ast.ClientKey = @ClientKey;
		
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

SELECT *
--Update m set m.stgRowStatus = 'Loaded'
FROM ast.FctMembership m
where m.stgRowStatus = 'Not Valid'
