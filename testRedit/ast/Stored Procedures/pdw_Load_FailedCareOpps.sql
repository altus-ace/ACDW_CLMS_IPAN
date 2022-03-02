




CREATE PROCEDURE [ast].[pdw_Load_FailedCareOpps]--'2021-11-15',21 
    @QMDate DATE
    , @ClientKey INT
AS
 
      /* Log Export to adw.FailedCareOpps */    
    DECLARE @AuditID INT 
    DECLARE @AuditStatus SmallInt= 1 
    DECLARE @JobType SmallInt     ;
    DECLARE @JobStatus tinyInt = 1	;
    DECLARE @JobName VARCHAR(200) ;
    DECLARE @ActionStartTime DATETIME = getdate();
    DECLARE @ActionStopTime DATETIME = getdate()
    DECLARE @InputSourceName VARCHAR(200) = 'No Name given';	   
    DECLARE @DestinationName VARCHAR(200) = 'No Name given';	   
    DECLARE @ErrorName VARCHAR(200)	  = 'No Name given';	   
    DECLARE @SourceCount int = 0;         
    DECLARE @DestinationCount int = 0;    
    DECLARE @ErrorCount int = 0;    
	DECLARE @EffectiveDate DATE = (SELECT DATEADD(month, DATEDIFF(month, 0, @QMDate), 0)) 
    
    /* Log FailedCareOpps Insert */
    SET @AuditID = null;
    SET @AuditStatus = 1 
    SET @JobType	= 8	 
    SET @JobName = 'pstCopExportStagingToAdw';
    SET @ActionStartTime = getdate();
    SELECT @InputSourceName = DB_NAME() + '.ast.QM_ResultByMember_History';
    SELECT @DestinationName = DB_NAME() + '.[ast].[pdw_Load_FailedCareOpps]';    
    SELECT @ErrorName	   = DB_NAME() + '.ast.QM_ResultByMember_History';        
            	
    EXEC AceMetaData.amd.sp_AceEtlAudit_Open 
        @AuditID = @AuditID OUTPUT
        , @AuditStatus = @AuditStatus
        , @JobType = @JobType
        , @ClientKey = @ClientKey
        , @JobName = @JobName
        , @ActionStartTime = @ActionStartTime
        , @InputSourceName = @InputSourceName
        , @DestinationName = @DestinationName
        , @ErrorName = @ErrorName
        ;

    SELECT @SourceCount = COUNT(*)
	   FROM ast.QM_ResultByMember_History ast
	   WHERE ast.ClientKey = @ClientKey 
		  AND ast.QMDate = @QMDate;

		    IF OBJECT_ID('tempdb..#Cop') IS NOT NULL DROP TABLE #Cop

		  /*Creating Dataset for the 3 DHTX adi tables into a single DataSet*/
			/*  ...*/
			


		  /*Inserting into Failed Careopps for MbrCareOpps to Mbr Plans - MbrCareOpToPlnFlg*/
		  DECLARE @AdwExportOutput TABLE (adiKey INT, ClientKey INT, adwKey INT);
    INSERT INTO [adw].[FailedCareOpps]
           ([LoadDate]
		   ,[QMDate]
           ,[ClientKey]
           ,[EffectiveDate]
           ,[AdiKey]
           ,[StagingKey]
           ,[ClientMemberKey]
           ,[AceID]
           ,[MeasureID]
           ,[srcMeasureName]
           ,[MbrPlanName]
           ,[MbrCareOpToPlnFlg]
           ,[MbrActiveFlg]
           ,[MbrCOPInContractFlg]
           ,[Exported]
           ,[ExportedDate]) -- DECLARE @QMDATE DATE = '2021-11-15' DECLARE @ClientKey INT = 21 DECLARE @EffectiveDate DATE = '2021-11-01'
     SELECT	DISTINCT
           qm.LoadDate
           ,qm.QMDate
           ,qm.ClientKey
           ,@EffectiveDate
           ,qm.AdiKey
           ,qm.pstQM_ResultByMbr_HistoryKey
           ,qm.ClientMemberKey
           ,active.Ace_ID
           ,qm.QmMsrId
           ,qm.srcQmDescription
           ,active.PLAN_CODE
           ,qm.MbrCareOpToPlnFlg
           ,qm.MbrActiveFlg
           ,qm.[MbrCOPInContractFlg]
           ,0					AS Exported
           ,'1900-01-01'		AS ExportedDate 
	FROM	ast.QM_ResultByMember_History qm
	LEFT JOIN	(SELECT PLAN_CODE,Ace_ID,CLIENT_SUBSCRIBER_ID
				 FROM ACECAREDW.dbo.vw_ActiveMembers
					WHERE ClientKey = @ClientKey)active
	ON		active.CLIENT_SUBSCRIBER_ID = qm.ClientMemberKey
	WHERE	qm.QMDate = @QMDate
	AND		qm.ClientKey = @ClientKey
	AND		qm.MbrCareOpToPlnFlg = 0
	
	 /*Inserting into Failed Careopps for Inactive Members - MbrActiveFlg*/
	 UNION   
	 SELECT	DISTINCT
           qm.LoadDate
           ,qm.QMDate
           ,qm.ClientKey
           ,@EffectiveDate
           ,qm.AdiKey
           ,qm.pstQM_ResultByMbr_HistoryKey
           ,qm.ClientMemberKey
           ,0			AS    Ace_ID
           ,qm.QmMsrId
           ,qm.srcQmDescription
           ,''    AS  PLAN_CODE
           ,qm.MbrCareOpToPlnFlg
           ,qm.MbrActiveFlg
           ,qm.[MbrCOPInContractFlg]
           ,0					AS Exported
           ,'1900-01-01'		AS ExportedDate 
	FROM	[ast].[QM_ResultByMember_History] qm
	WHERE	qm.QMDate = @QMDate
	AND		qm.ClientKey = @ClientKey
	AND		qm.MbrActiveFlg = 0

	 /*Inserting into Failed Careopps for MbrCareOpps not in the contract CareOpps Plan -  MbrCOPInContractFlg*/
	UNION   -- 
	 SELECT	DISTINCT
           qm.LoadDate
           ,qm.QMDate
           ,qm.ClientKey
           ,@EffectiveDate
           ,qm.AdiKey
           ,qm.pstQM_ResultByMbr_HistoryKey
           ,qm.ClientMemberKey
           ,active.Ace_ID
           ,qm.QmMsrId
           ,qm.srcQmDescription
           ,active.PLAN_CODE
           ,qm.MbrCareOpToPlnFlg
           ,qm.MbrActiveFlg
           ,qm.[MbrCOPInContractFlg]
           ,0					AS Exported
           ,'1900-01-01'		AS ExportedDate 
	FROM	[ast].[QM_ResultByMember_History] qm
	LEFT JOIN	(SELECT PLAN_CODE,Ace_ID,CLIENT_SUBSCRIBER_ID
				 FROM ACECAREDW.dbo.vw_ActiveMembers
					WHERE ClientKey = @ClientKey)active
	ON		active.CLIENT_SUBSCRIBER_ID = qm.ClientMemberKey
	WHERE	qm.QMDate = @QMDate
	AND		qm.ClientKey = @ClientKey
	AND		qm.MbrCOPInContractFlg = 0


	
    /* close auditl log */    
    SET @ActionStopTime = getdate();    
    SELECT @DestinationCount= COUNT(adwKey) FROM @AdwExportOutput
    SET @ErrorCount = 0
    SET @JobStatus = 2

    EXEC AceMetaData.amd.sp_AceEtlAudit_Close 
        @AuditId = @AuditID
        , @ActionStopTime = @ActionStopTime
        , @SourceCount = @SourceCount		  
        , @DestinationCount = @DestinationCount
        , @ErrorCount = @ErrorCount
        , @JobStatus = @JobStatus
	   ;
    
    SELECT @DestinationCount;
