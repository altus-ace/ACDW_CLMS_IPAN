

CREATE PROCEDURE [ast].[FailedLogMbrEmail]

AS

BEGIN

BEGIN TRY 
BEGIN TRAN
				
					DECLARE @AuditId INT;    
					DECLARE @JobStatus tinyInt = 1    
					DECLARE @JobType SmallInt = 9	  
					DECLARE @ClientKey INT	 = 0; 
					DECLARE @JobName VARCHAR(100) = 'FailedLogMbrEmail';
					DECLARE @ActionStart DATETIME2 = GETDATE();
					DECLARE @SrcName VARCHAR(100) = 'adi.Steward_BCBS_Membership'
					DECLARE @DestName VARCHAR(100) = 'AceMetaData.amd.AceBusinessRuleLog'
					DECLARE @ErrorName VARCHAR(100) = 'Check table, AceEtlAuditErrorLog';
					DECLARE @InpCnt INT = -1;
					DECLARE @OutCnt INT = -1;
					DECLARE @ErrCnt INT = -1;
					

					CREATE TABLE		#OutputTbl (ID INT NOT NULL );
					
					
					SELECT				 @InpCnt = COUNT(ID)    
					FROM				 #OutputTbl
					 

	EXEC			amd.sp_AceEtlAudit_Open 
					@AuditID = @AuditID OUTPUT
					, @AuditStatus = @JobStatus
					, @JobType = @JobType
					, @ClientKey = @ClientKey
					, @JobName = @JobName
					, @ActionStartTime = @ActionStart
					, @InputSourceName = @SrcName
					, @DestinationName = @DestName
					, @ErrorName = @ErrorName

	
	INSERT INTO			AceMetaData.[amd].[AceBusinessRuleLog](
						[lBusinessRuleKey]
						,RuleOutCome
						,AdiTableName
						,AdiKey
						,astTableName
						,astTableKey)
	OUTPUT				inserted.adiKey INTO #OutputTbl(ID)
	SELECT				(Select lBusinessRuleKey From AceMetaData.[lst].[lstBusinessRules] Where lBusinessRuleKey = 1)
						,'Failed'
						,'adi.Steward_BCBS_Membership' 
						, MembershipKey
						,'ast.MbrStg2_MbrData'
						,0
		
	FROM		
						( 
									SELECT		PatientID,DataDate
												, MembershipKey
												,CreateDate
									FROM		[adi].[Steward_BCBS_Membership]
				
						)a
	
	LEFT JOIN
						(
	
									SELECT		 ClientSubscriberId,DataDate
												,ClientKey
												, AdiKey
									FROM		ast.MbrStg2_MbrData 
									WHERE		AdiTableName = '[adi].[Steward_BCBS_Membership]'
									AND			DataDate = (Select MAX(DataDate) From ast.MbrStg2_MbrData Where ClientKey = 20 )
								  
						)b
	
	ON					a.PatientID = b.ClientSubscriberId
	WHERE				b.ClientSubscriberId IS NULL 
			
	
	
	
	SET					@ActionStart  = GETDATE();
	SET					@JobStatus =2  
			    				
	EXEC				amd.sp_AceEtlAudit_Close 
						@AuditId = @AuditID
						, @ActionStopTime = @ActionStart
						, @SourceCount = @InpCnt		  
						, @DestinationCount = @OutCnt
						, @ErrorCount = @ErrCnt
						, @JobStatus = @JobStatus


		
	DROP TABLE #OutputTbl						


					
COMMIT
END TRY
BEGIN CATCH
EXECUTE				[dbo].[usp_QM_Error_handler]
END CATCH
END						







