
--add @qmdate, @codeeffectivedate

CREATE PROCEDURE [adw].[sp_2020_Calc_QM_All](@QMDATE DATE,@MbrEffectiveDate DATE)
AS 
  /* 
  **Set Logging Parameters
  */
    --Declare @batchDate Date	= '2019-03-17'; 
	DECLARE @RUNDATE1 DATE					
	DECLARE @InsertCount INT;
	DECLARE	@SourceCount INT;
	DECLARE @QueryCount INT					= 0;    
	DECLARE @Audit_ID INT					= 0;
	DECLARE @ClientKey INT					= (SELECT ClientKey FROM Lst.List_client);					
	DECLARE @CodeEffectiveDate DATE			= '2020-01-01'
	DECLARE @qmFx VARCHAR(100);
	DECLARE @Destination VARCHAR(100)		= 'adw.QM_ResultByMember_History';
	DECLARE @JobName VARCHAR(100)			= '[AceMasterQMCalc]sp_Calc_QM_All';
	DECLARE @StartTime DATETIME2;
	DECLARE @MeasurementYear INT			= 2021
	DECLARE @srcQMDATE DATE;
	DECLARE @trgQMDATE DATE;
	DECLARE @LoadDateAthena DATE;
	DECLARE @LoadDateAthena_AWV DATE;
	DECLARE @LoadDate DATE;
	DECLARE @OutputTbl Table (ID INT);
	--INSERT INTO @OutputTbl (ID)
	--SELECT urn FROM [adw].[QM_ResultByMember_TESTING] 
	--SELECT @SourceCount = COUNT(*) FROM @OutputTbl 
   
   -- Audit Status     1	In process,     2	Success,    3	Fail-- Job Type        4	Move File,    5	ETL Data,     6	Export Data
   /*
   ***The logging calls is called inside the QM Procedure 
   ***Set Open logging
   ***Set Close logging
   */
   	

	SET @StartTime = GETDATE();	   
	SET @qmFx = 'sp_2020_Calc_QM_ACE_CMS_BCS'; 
	EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID = @Audit_ID OUTPUT,   @AuditStatus = 1, @JobType = 5, @ClientKey = @ClientKey,@JobName = @JobName,
	                   @ActionStartTime = @StartTime, @InputSourceName = @qmFx, @DestinationName = @Destination, @ErrorName = 'Check table , AceEtlAuditErrorLog' 
	EXEC [adw].[sp_2020_Calc_QM_ACE_CMS_BCS] '[adw].[QM_ResultByMember_History]',@QMDATE,@CodeEffectiveDate,@MeasurementYear,@ClientKey,@MbrEffectiveDate;
	SET @StartTime = GETDATE();	   
	EXEC AceMetaData.amd.sp_AceEtlAudit_Close @auditid = @Audit_ID, @ActionStopTime = @StartTime, @SourceCount = @SourceCount, @DestinationCount = @SourceCount,@ErrorCount = @@ERROR;  

	
	SET @StartTime = GETDATE();	   
	SET @qmFx = 'sp_2020_Calc_QM_ACE_HEDIS_ACO_CDC_9'; 
	EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID = @Audit_ID OUTPUT,   @AuditStatus = 1, @JobType = 5, @ClientKey = @ClientKey,@JobName = @JobName,
	                   @ActionStartTime = @StartTime, @InputSourceName = @qmFx, @DestinationName = @Destination, @ErrorName = 'Check table , AceEtlAuditErrorLog' 
	EXEC [adw].[sp_2020_Calc_QM_ACE_HEDIS_ACO_CDC_9] '[adw].[QM_ResultByMember_History]',@QMDATE,@CodeEffectiveDate,@MeasurementYear,@ClientKey,@MbrEffectiveDate;
	SET @StartTime = GETDATE();	   
	EXEC AceMetaData.amd.sp_AceEtlAudit_Close @auditid = @Audit_ID, @ActionStopTime = @StartTime, @SourceCount = @SourceCount, @DestinationCount = @SourceCount,@ErrorCount = @@ERROR;  
		 

	SET @StartTime = GETDATE();	   
	SET @qmFx = 'sp_2020_Calc_QM_ACE_PREV_AWV'; 
	EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID = @Audit_ID OUTPUT,   @AuditStatus = 1, @JobType = 5, @ClientKey = @ClientKey,@JobName = @JobName,
	                   @ActionStartTime = @StartTime, @InputSourceName = @qmFx, @DestinationName = @Destination, @ErrorName = 'Check table , AceEtlAuditErrorLog' 
	EXEC [adw].[sp_2020_Calc_QM_ACE_PREV_AWV] '[adw].[QM_ResultByMember_History]',@QMDATE,@CodeEffectiveDate,@MeasurementYear,@ClientKey,@MbrEffectiveDate;
	SET @StartTime = GETDATE();	   
	EXEC AceMetaData.amd.sp_AceEtlAudit_Close @auditid = @Audit_ID, @ActionStopTime = @StartTime, @SourceCount = @SourceCount, @DestinationCount = @SourceCount,@ErrorCount = @@ERROR;  

	SET @StartTime = GETDATE();	   
	SET @qmFx = 'sp_2020_Calc_QM_ACE_MIPS_ACO_CDC_9'; 
	EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID = @Audit_ID OUTPUT,   @AuditStatus = 1, @JobType = 5, @ClientKey = @ClientKey,@JobName = @JobName,
	                   @ActionStartTime = @StartTime, @InputSourceName = @qmFx, @DestinationName = @Destination, @ErrorName = 'Check table , AceEtlAuditErrorLog' 
	EXEC [adw].[sp_2020_Calc_QM_ACE_MIPS_CDC_9]  '[adw].[QM_ResultByMember_History]',@QMDATE,@CodeEffectiveDate,@MeasurementYear,@ClientKey,@MbrEffectiveDate;
	SET @StartTime = GETDATE();	   
	EXEC AceMetaData.amd.sp_AceEtlAudit_Close @auditid = @Audit_ID, @ActionStopTime = @StartTime, @SourceCount = @SourceCount, @DestinationCount = @SourceCount,@ErrorCount = @@ERROR;  

	SET @StartTime = GETDATE();	   
	SET @qmFx = 'sp_2020_Calc_QM_ACE_ACO_SCD'; 
	EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID = @Audit_ID OUTPUT,   @AuditStatus = 1, @JobType = 5, @ClientKey = @ClientKey,@JobName = @JobName,
	                   @ActionStartTime = @StartTime, @InputSourceName = @qmFx, @DestinationName = @Destination, @ErrorName = 'Check table , AceEtlAuditErrorLog' 
	EXEC [adw].[sp_2020_Calc_QM_ACE_ACO_SCD]  '[adw].[QM_ResultByMember_History]',@QMDATE,@CodeEffectiveDate,@MeasurementYear,@ClientKey,@MbrEffectiveDate;
	SET @StartTime = GETDATE();	   
	EXEC AceMetaData.amd.sp_AceEtlAudit_Close @auditid = @Audit_ID, @ActionStopTime = @StartTime, @SourceCount = @SourceCount, @DestinationCount = @SourceCount,@ErrorCount = @@ERROR;  

	SET @StartTime = GETDATE();	   
	SET @qmFx = 'sp_2020_Calc_QM_ACE_CMS_SPC'; 
	EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID = @Audit_ID OUTPUT,   @AuditStatus = 1, @JobType = 5, @ClientKey = @ClientKey,@JobName = @JobName,
	                   @ActionStartTime = @StartTime, @InputSourceName = @qmFx, @DestinationName = @Destination, @ErrorName = 'Check table , AceEtlAuditErrorLog' 
	EXEC [adw].[sp_2020_Calc_QM_ACE_CMS_SPC]  '[adw].[QM_ResultByMember_History]',@QMDATE,@CodeEffectiveDate,@MeasurementYear,@ClientKey,@MbrEffectiveDate;
	SET @StartTime = GETDATE();	   
	EXEC AceMetaData.amd.sp_AceEtlAudit_Close @auditid = @Audit_ID, @ActionStopTime = @StartTime, @SourceCount = @SourceCount, @DestinationCount = @SourceCount,@ErrorCount = @@ERROR;  

	SET @StartTime = GETDATE();	   
	SET @qmFx = 'sp_2020_Calc_QM_ACE_CMS_TSC'; 
	EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID = @Audit_ID OUTPUT,   @AuditStatus = 1, @JobType = 5, @ClientKey = @ClientKey,@JobName = @JobName,
	                   @ActionStartTime = @StartTime, @InputSourceName = @qmFx, @DestinationName = @Destination, @ErrorName = 'Check table , AceEtlAuditErrorLog' 
	EXEC [adw].[sp_2020_Calc_QM_ACE_CMS_TSC]  '[adw].[QM_ResultByMember_History]',@QMDATE,@CodeEffectiveDate,@MeasurementYear,@ClientKey,@MbrEffectiveDate;
	SET @StartTime = GETDATE();	   
	EXEC AceMetaData.amd.sp_AceEtlAudit_Close @auditid = @Audit_ID, @ActionStopTime = @StartTime, @SourceCount = @SourceCount, @DestinationCount = @SourceCount,@ErrorCount = @@ERROR;  

	SET @StartTime = GETDATE();	   
	SET @qmFx = 'sp_2020_Calc_QM_ACE_MIPS_CBP'; 
	EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID = @Audit_ID OUTPUT,   @AuditStatus = 1, @JobType = 5, @ClientKey = @ClientKey,@JobName = @JobName,
	                   @ActionStartTime = @StartTime, @InputSourceName = @qmFx, @DestinationName = @Destination, @ErrorName = 'Check table , AceEtlAuditErrorLog' 
	EXEC [adw].[sp_2020_Calc_QM_ACE_MIPS_CBP]  '[adw].[QM_ResultByMember_History]',@QMDATE,@CodeEffectiveDate,@MeasurementYear,@ClientKey,@MbrEffectiveDate;
	SET @StartTime = GETDATE();	   
	EXEC AceMetaData.amd.sp_AceEtlAudit_Close @auditid = @Audit_ID, @ActionStopTime = @StartTime, @SourceCount = @SourceCount, @DestinationCount = @SourceCount,@ErrorCount = @@ERROR;  


	/*
	Not In Scope for now
	EXECUTE [adw].[Load_MasterJob_QM_Addressed]		  @DataDate
													  ,@ClientKey
													  ,@srcQMDATE
													  ,@trgQMDATE
													  ,@LoadDateAthena
													  ,@LoadDateAthena_AWV
													  ,@LoadDate */
