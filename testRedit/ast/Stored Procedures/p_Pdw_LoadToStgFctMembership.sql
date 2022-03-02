/*  Load TO STG Members from dims for FctLoad*/

CREATE PROCEDURE [ast].[p_Pdw_LoadToStgFctMembership]
    ( @AsOfDate DATE
    , @ClientKey INT
	,@DataDate DATE)
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
    DECLARE @SrcName VARCHAR(100) = 'adw.tvf_Get_ActiveMbrFromDim'
    DECLARE @DestName VARCHAR(100) = 'ast.FctMembership'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;

    SELECT	@InpCnt = COUNT(src.mbrMemberKey)    
	   FROM	ast.tvf_Get_ActiveMbrFromDim(@AsOfDate, @ClientKey) src;
     
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
	   
						
	   --DECLARE @AsOfDate DATE = GETDATE();
	   --DECLARE @ClientKey INT = 20;    
	   INSERT INTO ast.FctMembership (--d.FctMembershipSkey, 
	      d.LoadDate, 
	      d.stgRowStatus, 
	      d.MbrMemberKey, 
	      d.MbrDemographicKey, 
	      d.MbrPlanKey, 
	      d.MbrCsPlanKey, 
	      d.MbrPCPKey, 
	      d.MbrPhoneKey_Home, 
	      d.MbrPhoneKey_Mobile, 
	      d.MbrPhoneKey_Work, 
	      d.MbrAddressKey_Home, 
	      d.MbrAddressKey_Work, 
	      --d.MbrEmailKey, 
	      --d.MbrRespPartyKey, 
	      d.RowEffectiveDate, 
	      d.RowExpirationDate, 
	      d.Ace_ID, 
	      d.ClientMemberKey, 
	      d.ClientKey,        
	      d.Active,
		  d.DataDate --Brit added Column for Data Lineage
		  ,MemberCurrentEffectiveDate
		  ,MemberCurrentExpirationDate
	     )
	   OUTPUT Inserted.FctMembershipSkey INTO #Output	   
	   SELECT @AsOfDate , 
	      'Loaded',
	      src.mbrMemberKey, 
	      src.mbrDemographicKey, 
	       src.mbrPlanKey,                  
	       src.mbrCsPlanKey, 
	      src.mbrPcpKey, 
	       src.MbrPhoneKey_Home, 
	       src.MbrPhoneKey_Mobile, 
	       src.MbrPHoneKeyType_Work, 
	       src.MbrAddressKeyHome, 
	       src.MbrAddressKeyMail, 
	      src.EffectiveDate, 
	       src.ExpirationDate,
	       src.Ace_ID, 
	      src.MEMBER_ID, 
	       src.ClientKey, 
	       1 ,
		   @DataDate,
		   MemberOriginalEffectiveDate,
		   MemberTermDateDate
	   FROM ast.tvf_Get_ActiveMbrFromDim(@AsOfDate, @ClientKey) src;

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

