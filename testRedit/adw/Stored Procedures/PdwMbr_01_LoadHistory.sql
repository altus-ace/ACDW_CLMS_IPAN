



CREATE PROCEDURE [adw].[PdwMbr_01_LoadHistory]	(@DataDate DATE
											    ,@LoadType VARCHAR(1)
											    ,@ClientID INT)
AS

BEGIN

BEGIN TRY 
BEGIN TRAN
				
					DECLARE @AuditId INT;    
					DECLARE @JobStatus tinyInt = 1    
					DECLARE @JobType SmallInt = 9	  
					DECLARE @ClientKey INT	 = @ClientID; 
					DECLARE @JobName VARCHAR(100) = 'AMGTX_MA LoadHistory';
					DECLARE @ActionStart DATETIME2 = GETDATE();
					DECLARE @SrcName VARCHAR(100) = 'ast.[MbrStg2_MbrData]'
					DECLARE @DestName VARCHAR(100) = '[adw].[MbrLoadHistory]'
					DECLARE @ErrorName VARCHAR(100) = 'NA';
					DECLARE @InpCnt INT = -1;
					DECLARE @OutCnt INT = -1;
					DECLARE @ErrCnt INT = -1;
SELECT				@InpCnt = COUNT(mbrLoadHistoryKey)    
FROM				adw.[MbrLoadHistory]  
WHERE				DataDate = @DataDate  

SELECT				@InpCnt, @DataDate


EXEC				amd.sp_AceEtlAudit_Open 
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
					
CREATE TABLE		#OutputTbl (ID INT NOT NULL );

INSERT INTO			[adw].[MbrLoadHistory]
					([mbrMemberKey]
					,[AdiTableName]
					,[AdiKey]
					,[LoadType]
					,[LoadDate]
					,[DataDate]
					,[CreatedDate]
					,[CreatedBy]
					,[LastUpdatedDate]
					,[LastUpdatedBy])
OUTPUT				inserted.mbrLoadHistoryKey INTO #OutputTbl(ID)
SELECT	
					0
					,AdiTableName
					,AdiKey
					,'P'
					,LoadDate
					,DataDate
					,CreateDate
					,CreateBy
					,GETDATE()
					,SUSER_SNAME()
FROM				ast.MbrStg2_MbrData
WHERE				DataDate = @DataDate
AND					stgrowstatus = 'Valid'


SELECT				@OutCnt = COUNT(*) FROM #OutputTbl;
SET					@ActionStart  = GETDATE();
SET					@JobStatus =2  
    				
EXEC				amd.sp_AceEtlAudit_Close 
					@AuditId = @AuditID
					, @ActionStopTime = @ActionStart
					, @SourceCount = @InpCnt		  
					, @DestinationCount = @OutCnt
					, @ErrorCount = @ErrCnt
					, @JobStatus = @JobStatus

COMMIT
END TRY
BEGIN CATCH
EXECUTE				[dbo].[usp_QM_Error_handler]
END CATCH


END

/*
USUAGE
-- EXECUTE [adw].[PdwMbr_01_LoadHistory]'2021-01-21','P',20
*/
