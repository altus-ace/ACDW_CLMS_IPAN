
/*  Exp TO Adw	 */

CREATE PROCEDURE [ast].[p_Pdw_ExportToAdwFctMembership]
    ( @AsOfDate DATE
    , @ClientKey INT)
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
    DECLARE @DestName VARCHAR(100) = 'adw.FctMembership'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;

    SELECT	@InpCnt = COUNT(ast.FctMembershipSkey)    
	   FROM	ast.fctMembership ast
	   WHERE ast.ClientKey = @ClientKey
		and ast.stgRowStatus = 'Valid';
     
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
    CREATE TABLE #Output (adwKey INT);

    BEGIN TRY 
	   BEGIN TRAN   					   
	   -- DECLARE @ClientKey INT = 16;    
	   INSERT INTO [adw].[FctMembership_dev]
           ([LoadDate]
           ,[DataDate]
           ,[MbrMemberKey]
           ,[MbrDemographicKey]
           ,[MbrPlanKey]
           ,[MbrCsPlanKey]
           ,[MbrPCPKey]
           ,[MbrPhoneKey_Home]
           ,[MbrPhoneKey_Mobile]
           ,[MbrPhoneKey_Work]
           ,[MbrAddressKey_Home]
           ,[MbrAddressKey_Work]
           ,[MbrEmailKey]
           ,[MbrRespPartyKey]
           ,[RowEffectiveDate]
           ,[RowExpirationDate]
           ,[Ace_ID]
           ,[ClientMemberKey]
           ,[ClientKey]
           ,[SubscriberIndicator]
           ,[MemberIndicator]
           ,[CurrentAge]
           ,[AgeGroup20Years]
           ,[AgeGroup10Years]
           ,[AgeGroup5Years]
           ,[MbrMonth]
           ,[MbrYear]
           ,[MemberStatus]
           ,[EnrollementStatus]
           ,[AceRiskScore]
           ,[AceRiskScoreLevel]
           ,[ClientRiskScore]
           ,[ClientRiskScoreLevel]
           ,[RiskScoreUtilization]
           ,[RiskScoreClinical]
           ,[RiskScoreHRA]
           ,[RiskScorePlaceHolder]
           ,[EnrollmentYear]
           ,[EnrollmentQuarter]
           ,[EnrollmentYearQuarter]
           ,[EnrollmentYearMonth]
           ,[EligibleYear]
           ,[EligibilityQuarter]
           ,[EligibilityYearQuarter]
           ,[EligibilityYearMonth]
           ,[MemberCount]
           ,[AvgMemberCount]
           ,[SubscriberCount]
           ,[AvgSubscriberCount]
           ,[PersonCreatedCount]
           ,[MemberMonths]
           ,[SubscriberMonths]
           ,[FamilyRatio]
           ,[AvgAge]
           ,[NoOfMonths]
           ,[MemberCurrentEffectiveDate]
           ,[MemberCurrentExpirationDate]
           ,[Active])
		--OUTPUT Inserted.FctMembershipSkey  INTO #Output	   
		SELECT fMbr.[LoadDate]				   
			,fMbr.[DataDate] 		-- Brit change it to DataDate to capture Data lineage	
			,fMbr.[MbrMemberKey]
			,fMbr.[MbrDemographicKey]
			,fMbr.[MbrPlanKey]
			,fMbr.[MbrCsPlanKey]
			,fMbr.[MbrPCPKey]
			,fMbr.[MbrPhoneKey_Home]
			,fMbr.[MbrPhoneKey_Mobile]
			,fMbr.[MbrPhoneKey_Work]
			,fMbr.[MbrAddressKey_Home]
			,fMbr.[MbrAddressKey_Work]
			,fMbr.[MbrEmailKey]
			,fMbr.[MbrRespPartyKey]
			,fMbr.[RowEffectiveDate]
			,fMbr.[RowExpirationDate]
			,fMbr.[Ace_ID]
			,fMbr.[ClientMemberKey]
			,fMbr.[ClientKey]
			,fMbr.[SubscriberIndicator]
			,fMbr.[MemberIndicator]
			,fMbr.[CurrentAge]
			,fMbr.[AgeGroup20Years]
			,fMbr.[AgeGroup10Years]
			,fMbr.[AgeGroup5Years]
			,fMbr.[MbrMonth]
			,fMbr.[MbrYear]
			,fMbr.[MemberStatus]
			,fMbr.[EnrollementStatus]
			,fMbr.[AceRiskScore]
			,fMbr.[AceRiskScoreLevel]
			,fMbr.[ClientRiskScore]
			,fMbr.[ClientRiskScoreLevel]
			,fMbr.[RiskScoreUtilization]
			,fMbr.[RiskScoreClinical]
			,fMbr.[RiskScoreHRA]
			,fMbr.[RiskScorePlaceHolder]
			,fMbr.[EnrollmentYear]
			,fMbr.[EnrollmentQuarter]
			,fMbr.[EnrollmentYearQuarter]
			,fMbr.[EnrollmentYearMonth]
			,fMbr.[EligibleYear]
			,fMbr.[EligibilityQuarter]
			,fMbr.[EligibilityYearQuarter]
			,fMbr.[EligibilityYearMonth]
			,fMbr.[MemberCount]
			,fMbr.[AvgMemberCount]
			,fMbr.[SubscriberCount]
			,fMbr.[AvgSubscriberCount]
			,fMbr.[PersonCreatedCount]
			,fMbr.[MemberMonths]
			,fMbr.[SubscriberMonths]
			,fMbr.[FamilyRatio]
			,fMbr.[AvgAge]
			,fMbr.[NoOfMonths]
			,fMbr.[MemberCurrentEffectiveDate]
			,fMbr.[MemberCurrentExpirationDate]
			,fMbr.[Active]
		FROM [ast].[FctMembership] fMbr
		WHERE fmbr.stgRowStatus = 'Valid'
			AND fMbr.ClientKey = @ClientKey
			AND fMbr.LoadDate = @AsOfDate
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

END;


