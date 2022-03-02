

CREATE PROCEDURE [amd].[sp_AceEtlAudit_Open](
    @AuditID INT output
	, @AuditStatus SmallInt= 0
	, @JobType SmallInt = 2
	, @ClientKey INT 
	, @JobName VARCHAR(200) = 'No Job Name'
	, @ActionStartTime DATETIME2 
	, @InputSourceName VARCHAR(200) = 'No Input Source Name Provided'	
	, @DestinationName VARCHAR(200) = 'No Destination Name Provided'	
	, @ErrorName VARCHAR(200) = 'No Error Name Provided'	
	)
AS 
    -- Add handeling for checking input param values 

    INSERT INTO [amd].[AceEtlAudit]
           ([EtlJobStatus]
           ,[EltJobType]
		   ,ClientKey
		   ,JobName
           ,[ActionStartTime]           
           ,[InputSourceName]           
           ,[DestinationName]           
           ,[ErrorDestinationName]           
           )
     VALUES
           (@AuditStatus
           ,@JobType
		  ,@ClientKey
		  ,@JobName
		  , CASE WHEN (@ActionStartTime = '')
		   THEN  CURRENT_TIMESTAMP
		   ELSE CONVERT(datetime2, @ActionStartTime) 
		   END       
           ,@InputSourceName
           ,@DestinationName           
           ,@ErrorName           
           );
    
    SELECT @AuditID = @@IDENTITY;
  
    IF @AuditID IS NULL
    BEGIN
	   INSERT INTO [amd].[AceEtlAuditErrorLog] (ParamValues) 
		  VALUES ('Audit_id: Was Null ' + 
			 ' AuditStatus: '		+ ISNULL(CONVERT(VARCHAR(25), @AuditStatus ), 'NULL') + 			
			 ' JobType: '			+ ISNULL(CONVERT(VARCHAR(10), @JobType), 'NULL') +
			 ' ClientKey: '		+ ISNULL(CONVERT(VARCHAR(10), @ClientKey), 'NULL') +
			 ' JobName: '			+ ISNULL(CONVERT(VARCHAR(255), @JobName ), 'NULL') +
			 ' ActionStartTime: '	+ ISNULL(CONVERT(VARCHAR(255), @ActionStartTime), 'NULL') +			 
			 ' InputSourceName: '	+ ISNULL(CONVERT(VARCHAR(10), @InputSourceName) , 'NULL')+ 
			 ' DestinationName: '	+ ISNULL(convert(VARCHAR(10), @DestinationName), 'NULL') +
			 ' ErrorName: '		+ ISNULL(Convert(VARCHAR(10), @ErrorName), 'NULL'));
	   RAISERROR ('Audit log entry open audit failed.',16, 1); 
    END    


