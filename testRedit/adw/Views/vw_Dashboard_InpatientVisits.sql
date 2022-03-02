







CREATE VIEW [adw].[vw_Dashboard_InpatientVisits]
AS 
    -- Purpose: creates a Persiste
SELECT [FctInpatientVisitsSkey]
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
      ,[AdmissionDate]
      ,[DischargeDate]
      ,[DischargeDisposition]
      ,[DrgCode]
      ,[PrimaryDiagnosis]
      ,[VendorID]
      ,[VendorName]
      ,[SVCProviderID]
      ,[SVCProviderFullName]
      ,[AttProviderID]
      ,[AttProviderFullName]
      ,[SNFPreferredFlag]
      ,[FacilityPrefferedFlag]
      ,[LOS]
      ,[ClaimType]
      ,[BillType]
      ,[AttribNPI]
      ,[AttribTIN]
      ,[InstType]
	   ,[ERToIPFlag]
      ,[ObvFlag]
      ,[SvcNPISpecialty]
      ,[AttNPISpecialty]
FROM [adw].[FctInpatientVisits]
WHERE EffectiveAsOfDate = (select max(EffectiveAsOfDate) from  adw.FctInpatientVisits);



