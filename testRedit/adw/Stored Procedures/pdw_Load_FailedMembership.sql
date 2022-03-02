

CREATE PROCEDURE [adw].[pdw_Load_FailedMembership]
				@EffectiveDate DATE
				

AS

BEGIN

BEGIN TRY 
BEGIN TRAN
					--Log on transaction
					DECLARE @AuditId INT;    
					DECLARE @JobStatus tinyInt = 1    
					DECLARE @JobType SmallInt = 9	  
					DECLARE @ClientKey INT	 = (SELECT ClientKey 
													FROM lst.List_Client); 
					DECLARE @JobName VARCHAR(100) = 'adw.pdw_Load_FailedMembership';
					DECLARE @ActionStart DATETIME2 = GETDATE();
					DECLARE @SrcName VARCHAR(100) = '[ast].[ast.MbrStg2_MbrData]'
					DECLARE @DestName VARCHAR(100) = '[adw].[FailedMembership]'
					DECLARE @ErrorName VARCHAR(100) = 'NA';
					DECLARE @InpCnt INT = -1;
					DECLARE @OutCnt INT = -1;
					DECLARE @ErrCnt INT = -1;
					
					
					SELECT	@InpCnt = COUNT(stg.mbrStg2_MbrDataUrn)    
					FROM	ast.MbrStg2_MbrData stg
					WHERE	ClientKey = @ClientKey 
					AND		EffectiveDate = @EffectiveDate
					AND		stgRowStatus <> 'Exported'
					-- AND		MbrNPIFlg = 0 /*To add Failed Plans*/
								
					

		EXEC		amd.sp_AceEtlAudit_Open 
					@AuditID = @AuditID OUTPUT
					, @AuditStatus = @JobStatus
					, @JobType = @JobType
					, @ClientKey = @ClientKey
					, @JobName = @JobName
					, @ActionStartTime = @ActionStart
					, @InputSourceName = @SrcName
					, @DestinationName = @DestName
					, @ErrorName = @ErrorName

		/*Insert into Target Table from Source Table the required fields*/
		INSERT INTO [adw].[FailedMembership]
		           ([LoadDate]
		           ,[DataDate]
		           ,[ClientKey]
		           ,[EffectiveDate]
		           ,[AdiKey]
		           ,[StagingKey]
		           ,[ClientMemberKey]
		           ,[AceID]
		           ,[NPI]
		           ,[AttribTIN]
		           ,[PlanName]
		           ,[PlanID]
		           ,[MbrNPIFlg]
		           ,[MbrPlnFlg]
		           ,[MbrFlgCount]
				   ,[NPIName]
		           )
		     SELECT
		           stg.LoadDate							AS LoadDate
		           ,stg.DataDate						AS DataDate
		           ,stg.ClientKey						AS ClientKey
		           ,stg.EffectiveDate					AS EffectiveDate
		           ,stg.AdiKey							AS AdiKey
		           ,stg.mbrStg2_MbrDataUrn				AS StagingKey
		           ,stg.ClientSubscriberId				AS ClientMemberKey
		           ,stg.MstrMrnKey						AS AceID
		           ,stg.srcNPI							AS NPI
		           ,stg.srcTIN							AS AttribTIN
		           ,stg.srcPln							AS PlanName
		           ,stg.plnProductSubPlan				AS PlanID
		           ,stg.[MbrNPIFlg]						AS NPIFlgCnt
		           ,stg.[MbrPlnFlg]						AS PlnFlgCnt
		           ,stg.[MbrFlgCount]					AS PlnFlgCnt 
				   ,stg.[ProviderFullName]				AS [ProviderFullName] ---- SELECT *
			FROM	ast.MbrStg2_MbrData stg
			WHERE	ClientKey =  @ClientKey
			AND		EffectiveDate = @EffectiveDate
			AND		stgRowStatus <> 'Exported'
			-- AND		MbrNPIFlg = 0  /*Requirement to add Failed Plans into the Failed Log Table*/
		

					 SET				@ActionStart  = GETDATE();
					 SET				@JobStatus =2  
					    				
					 EXEC				amd.sp_AceEtlAudit_Close 
										@Audit_Id = @AuditID
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
USAGE : EXECUTE adw.pdw_Load_FailedMembership '2022-01-01'
**/

