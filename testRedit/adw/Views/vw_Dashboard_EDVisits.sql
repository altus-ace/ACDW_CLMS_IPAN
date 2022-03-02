








CREATE VIEW [adw].[vw_Dashboard_EDVisits]
AS 
    -- Purpose: creates a Persiste
SELECT [FctEDVisitsSkey]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[LastUpdatedDate]
      ,[LastUpdatedBy]
      ,[AdiKey]
      ,[adiTableName]
      ,[SrcFileName]
      ,[LoadDate]
      ,[DataDate]
      ,[ClientKey]
      ,[ClientMemberKey]
      ,[EffectiveAsOfDate]
      ,[SEQ_ClaimID]
      ,[PrimaryServiceDate]
      ,[PrimaryDiagnosis]
      ,[RevCode]
      ,[VendorID]
      ,[VendorName]
      ,[SVCProviderID]
      ,[SVCProviderFullName]
      ,[AttProviderID]
      ,[AttProviderFullName]
      ,[LOS]
      ,[ClaimType]
      ,[BillType]
      ,[AttribNPI]
      ,[AttribTIN]
      ,[FacilityPrefferedFlag]
	   ,[ERToIPFlag]
      ,[ObvFlag]
      ,[SvcNPISpecialty]
      ,[AttNPISpecialty]
FROM [adw].[FctEDVisits]
WHERE EffectiveAsOfDate = (select max(EffectiveAsOfDate) from  [adw].[FctEDVisits]);




