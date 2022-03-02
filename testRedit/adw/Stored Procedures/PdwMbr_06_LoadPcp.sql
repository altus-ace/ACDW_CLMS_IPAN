





CREATE PROCEDURE [adw].[PdwMbr_06_LoadPcp]			(@DataDate DATE
													,@ClientID INT
													)
AS

BEGIN

BEGIN TRY 
BEGIN TRAN
				
					DECLARE @AuditId INT;    
					DECLARE @JobStatus tinyInt = 1    
					DECLARE @JobType SmallInt = 9	  
					DECLARE @ClientKey INT	 = @ClientID; 
					DECLARE @JobName VARCHAR(100) = 'IPAN MbrPcp';
					DECLARE @ActionStart DATETIME2 = GETDATE();
					DECLARE @SrcName VARCHAR(100) = 'ast.[MbrStg2_MbrData]'
					DECLARE @DestName VARCHAR(100) = '[adw].[MbrPcp]'
					DECLARE @ErrorName VARCHAR(100) = 'NA';
					DECLARE @InpCnt INT = -1;
					DECLARE @OutCnt INT = -1;
					DECLARE @ErrCnt INT = -1;
					DECLARE @OutputTbl TABLE (ID INT);
	SELECT			@InpCnt = COUNT(a.mbrStg2_MbrDataUrn)    
	FROM			ast.MbrStg2_MbrData a
	WHERE			stgRowStatus = 'Valid'
	AND				DataDate = @DataDate

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


	IF NOT EXISTS ( SELECT			ClientMemberKey
									,ClientKey
									,NPI,TIN
									,adiKey
									,adiTableName
									,LoadDate
									,DataDate
									,EffectiveDate
									,ExpirationDate
					FROM			adw.MbrPcp
					WHERE			DataDate = @DataDate
				  )
	INSERT INTO				adw.MbrPcp(
							[ClientMemberKey]
							, [adiKey]
							, [adiTableName]
							, [EffectiveDate]
							, [ExpirationDate]
							, [NPI]
							, [TIN]
							, [ClientEffective]
							, [ClientExpiration]
							, [AutoAssigned]
							, [LoadDate]
							, [DataDate]
							, [ClientKey]
							, [ProviderChapter])
	OUTPUT inserted.adiKey INTO @OutputTbl(ID)
	SELECT					[ClientSubscriberId]
							,[AdiKey]
							,[AdiTableName]
							,EffectiveDate
							,[ExpirationDate]
							,[NPI]
							,[TIN]
							,[ClientEffective]
							,[ClientExpiration]
							,[AutoAssigned]
							,[LoadDate]
							,[DataDate]
							,[ClientKey]
							,[ProviderChapter]
	FROM					(
														SELECT
														stg.ClientSubscriberID
														,stg.[adikey]
														,stg.[adiTableName]
														,stg.[prvNPI]				AS NPI
														,stg.[prvTIN]				AS TIN
														,stg.[EffectiveDate]		  AS EffectiveDate
														,'2099-12-31'				AS ExpirationDate
														,stg.[prvClientEffective]		AS [ClientEffective]
														,stg.[prvClientExpiration]		AS [ClientExpiration]
														,stg.[prvAutoAssign]		AS AutoAssigned
														,stg.LoadDate
														,stg.DataDate
														,stg.ClientKey
														,stg.[ProviderChapter]
								FROM					[ast].[MbrStg2_MbrData]  stg
								JOIN					adw.MbrMember mbr
								ON						stg.ClientSubscriberID = mbr.ClientMemberKey
								AND						stg.AdiKey = mbr.AdiKey
								AND						stg.AdiTableName = mbr.AdiTableName
								AND						stg.DataDate = mbr.DataDate
								WHERE					mbr.DataDate =  @DataDate--  '2020-12-20' --
								AND						mbr.ClientKey = @ClientID  -- 16 --- 
								AND						stg.stgRowStatus = 'Valid'   
							) AS Src
								
	

	UPDATE			adw.MbrPcp
	SET				IsCurrent = 'N'		
	---- SELECT * FROM adw.MbrPcp
	WHERE			DataDate <>  @DataDate 
	AND				IsCurrent <> 'N'

	UPDATE			adw.MbrPcp
	SET				ExpirationDate = (SELECT CONVERT(DATE,DATEADD(d,-1,DATEADD(mm, DATEDIFF(m,0,CONVERT(DATE,GETDATE())),0))))
	--	SELECT * FROM adw.MbrPcp --  ORDER BY LoadDate DESC
	WHERE			DataDate <>  @DataDate
	AND				ExpirationDate = '2099-12-31'

SELECT				@OutCnt = COUNT(*) FROM @OutputTbl;
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
[adw].[PdwMbr_06_LoadPcp]
	@DataDate ='2021-04-15'
	,@ClientID =21
*/

--Validation
	/*
	 SELECT		COUNT(*), DataDate 
	 FROM		adw.MbrPcp 
	 GROUP BY	DataDate
	 ORDER BY	DataDate DESC
	 */
	
	
