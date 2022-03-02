

CREATE PROCEDURE [adw].[Load_AHRPopulationHistory]
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate		DATE
	)
AS    
BEGIN
    SET NOCOUNT ON;

INSERT INTO [adw].[AHR_Population_History]
           (
           [SrcFileName]
           ,[AdiTableName]
		   ,[AdiKey]
           ,[LoadDate]
           ,[DataDate]
           ,[ClientKey]
		   ,[ACE_ID]
           ,[ClientMemberKey]
			  ,[HICN]
			  ,[MBI]
           ,[EffectiveAsOfDate]
           ,[FirstName]
           ,[LastName]
           ,[Sex]
           ,[DOB]
           --,[CurrentRS]
           --,[CurrentDisplayGaps]
           --,[CurrentGaps]
           ,[Age]
           ,[TIN]
           ,[TIN_NAME]
           ,[NPI]
           ,[NPI_NAME]
		   ,[PRIM_SPECIALTY]
           ,[RUN_DATE]
           ,[RUN_YEAR]
           ,[RUN_MTH]
           ,[ToSend]
           ,[SentDate])
	SELECT 
			'[adw].[Load_AHRPopulationHistory]'
			,'[dbo].[tmp_AHR_HL7_Population]'
			,p.ID
			,GETDATE()
			,p.LOADDATE					AS DataDate
			,@ClientKeyID							
			,p.[ACE_ID]							
			,p.[SUBSCRIBER_ID]
			,p.[SUBSCRIBER_ID]
			,p.[SUBSCRIBER_ID]
			,@RunDate
			,p.[FIRSTNAME]						
			,p.[LASTNAME]					
			,p.[GENDER]	
			,p.[DOB]
			--,0						AS [CurrentRS]
			--,0						AS [CurrentDisplayGaps]
			--,0						AS [CurrentGaps]
			,DATEDIFF(yy,p.DOB, getdate())			AS [Age]
			,p.AttribTIN
			,pcp.AttribTINName
			,p.AttribNPI
			,CONCAT(pcp.FirstName,' ',pcp.LastName)
			,PCP.ProviderSpecialty						AS [PRIM_SPECIALTY]
			,@RunDate
			,DATEPART(yy, @RunDate) AS [RUN_YEAR]
			,DATEPART(mm, @RunDate) AS [RUN_MTH]
			,'Y'					AS [ToSend]
			,GETDATE()				AS [SentDate]						
	FROM [dbo].[tmp_AHR_HL7_Population] p
	LEFT JOIN adw.tvf_AllClient_ProviderRoster_TinRank (@ClientKeyID,@RunDate,1) pcp
		ON p.AttribNPI = pcp.NPI
END;												

/***
EXEC [adw].[Load_AHRPopulationHistory] 25,'07-15-2021'

SELECT *
FROM [adw].[AHR_Population_History]
***/

