




CREATE PROCEDURE [amd].[sp_AceEtlAudit_Close]
	@AuditId int
    , @ActionStopTime DATETIME 
    , @SourceCount int = 0
    , @DestinationCount int = 0
    , @ErrorCount int = 0    
    , @JobStatus tinyInt = 2
AS
BEGIN
     
   DECLARE @STOPTIME DATETIME 
    IF @AuditId IS NULL or @AuditId < 0
    BEGIN
	   
	   INSERT INTO [amd].[AceEtlAuditErrorLog] (ParamValues) 
		  VALUES ('Audit_id: '		+ ISNULL(CONVERT(VARCHAR(25), @AuditId), 'NULL') + 
			 ' ActionStopTime: '	+ ISNULL(CONVERT(VARCHAR(25), @actionStopTime), 'NULL') + 
			 ' SourceCount: '		+ ISNULL(CONVERT(VARCHAR(10), @sourceCount) , 'NULL')+ 
			 ' DestinationCount: '	+ ISNULL(convert(VARCHAR(10), @DestinationCount), 'NULL') +
			 ' ErrorCount: '		+ ISNULL(Convert(VARCHAR(10), @ErrorCount), 'NULL'));

	   RAISERROR ('This procedure must be passed an AuditID',16, 1);
	   RETURN;

    END

	IF (LEN(@ActionStopTime) < 10)
	BEGIN 
    SET  @STOPTIME = GETDATE()	
	END
	ELSE
	BEGIN
	SET @STOPTIME = CONVERT(datetime2, @ActionStopTime)
	END


    UPDATE amd.AceEtlAudit
	   	SET ActionStopTime =  CASE WHEN (@ActionStopTime = '')
		                         THEN  CURRENT_TIMESTAMP
		                         ELSE CONVERT(datetime2, @ActionStopTime) 
		                         END   
	   , InputCount = @SourceCount
	   , DestinationCount = @DestinationCount
	   , ErrorCount = @ErrorCount    
	   , EtlJobStatus = @JobStatus
    where [EtlAuditPkey] = @AuditId;

END

