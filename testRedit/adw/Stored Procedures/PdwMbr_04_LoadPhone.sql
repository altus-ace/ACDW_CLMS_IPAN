



CREATE PROCEDURE [adw].[PdwMbr_04_LoadPhone]		(@DataDate DATE
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
					DECLARE @JobName VARCHAR(100) = 'IPAN MbrPhone';
					DECLARE @ActionStart DATETIME2 = GETDATE();
					DECLARE @SrcName VARCHAR(100) = '[ast].[MbrStg2_PhoneAddEmail] '
					DECLARE @DestName VARCHAR(100) = '[adw].[MbrPhone]'
					DECLARE @ErrorName VARCHAR(100) = 'NA';
					DECLARE @InpCnt INT = -1;
					DECLARE @OutCnt INT = -1;
					DECLARE @ErrCnt INT = -1;
					DECLARE @OutputTbl TABLE (ID INT);
	SELECT			@InpCnt = COUNT(a.mbrStg2_PhoneAddEmailUrn)    
	FROM			ast.[MbrStg2_PhoneAddEmail] a
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
									,adiKey
									,adiTableName
									,LoadDate
									,DataDate
									,EffectiveDate
									,ExpirationDate
									,PhoneNumber,CellPhone,HomePhone
					FROM			adw.MbrPhone
					WHERE			DataDate = @DataDate
					)
	INSERT INTO				[adw].[MbrPhone](
							[ClientMemberKey]
							, [adiKey]
							, [adiTableName]
							, [EffectiveDate]
							, [ExpirationDate]
							, [PhoneType]
							, [CarrierType]
							, [PhoneNumber]
							, [IsPrimary]
							, [LoadDate]
							, [DataDate]
							, [ClientKey]
							, [CellPhone]
							, [HomePhone])
	OUTPUT inserted.adiKey INTO @OutputTbl(ID)
	SELECT					[ClientMemberKey]
							, [AdiKey]
							, [AdiTableName]
							, EffectiveDate
							, [ExpirationDate]
							, [lstPhoneTypeKey]
							, [PhoneCarrierType]
							, [PhoneNumber] 
							, [PhoneIsPrimary]
							, [LoadDate]
							, [DataDate]
							, [ClientKey]
							, [CellPhone]
							, [HomePhone]
	FROM					(
								SELECT DISTINCT
														stg. [AdiKey]
														,stg.[AdiTableName]
														,mbr.[ClientMemberKey]
														,mbr.EffectiveDate
														,mbr.ExpirationDate
														,stg.[lstPhoneTypeKey]
														,stg.[PhoneCarrierType]
														,stg.[PhoneNumber]
														,stg.[PhoneIsPrimary]
														,stg.LoadDate
														,stg.DataDate
														,stg.ClientKey
														,stg.[CellPhone]
														,stg.[HomePhone]
								FROM					ast.[MbrStg2_PhoneAddEmail]  stg
								JOIN					(	SELECT		DISTINCT  ClientMemberKey
																		,a.EffectiveDate
																		,ExpirationDate,a.AdiKey
																		,a.DataDate,a.ClientKey,stgRowStatus
															FROM		adw.MbrMember a 
															JOIN		ast.[MbrStg2_MbrData] b 
															ON			a.ClientMemberKey = b.ClientSubscriberID 
															AND			a.DataDate =b.DataDate
															AND			a.AdiKey = b.Adikey
															WHERE		b.DataDate = @DataDate --
														)mbr
								ON						mbr.ClientMemberKey = stg.ClientMemberKey
								AND						stg.AdiKey = mbr.AdiKey
								AND						stg.DataDate = mbr.DataDate
								WHERE					stg.DataDate =   @DataDate  
								AND						mbr.ClientKey =   @ClientID  
								AND						mbr.stgRowStatus = 'Valid'
								AND						stg.stgRowStatus = 'Valid'
														) AS Src
								
	
	BEGIN
	UPDATE			adw.MbrPhone
	SET				IsCurrent = 'N'		
	---- SELECT * FROM adw.MbrPhone
	WHERE			DataDate <>  @DataDate 
	AND				IsCurrent <> 'N'

	UPDATE			adw.MbrPhone
	SET				ExpirationDate = (SELECT CONVERT(DATE,DATEADD(d,-1,DATEADD(mm, DATEDIFF(m,0,CONVERT(DATE,GETDATE())),0))))
	--	SELECT * FROM adw.MbrPhone --  ORDER BY LoadDate DESC
	WHERE			DataDate <>  @DataDate
	AND				ExpirationDate = '2099-12-31'

	END
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
[adw].[PdwMbr_04_LoadPhone]
	@DataDate ='2021-04-15'
	,@ClientID =21
*/

--Validation
	/*
	 SELECT		COUNT(*), DataDate 
	 FROM		adw.MbrPhone
	 GROUP BY	DataDate
	 ORDER BY	DataDate DESC
	 */

	
