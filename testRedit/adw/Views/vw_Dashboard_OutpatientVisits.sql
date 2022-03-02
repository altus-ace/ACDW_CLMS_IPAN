






CREATE VIEW [adw].[vw_Dashboard_OutpatientVisits]
AS 
    -- Purpose: creates a Persiste
SELECT [FctOutpatientVisitskey]
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
      ,[PrimaryDiagnosis]
      ,[VendorID]
      ,[VendorName]
      ,[VendorType]
      ,[SVCProviderID]
      ,[SVCProviderFullName]
      ,[AttProviderID]
      ,[AttProviderFullName]
      ,[SVCProviderParFlag]
      ,[FacilityPrefferedFlag]
      ,[LOS]
      ,[ClaimType]
      ,[BillType]
      ,[AttribNPI]
      ,[AttribTIN]
      ,[InstType]
	   ,[SvcNPISpecialty]
      ,[AttNPISpecialty]
FROM [adw].[FctOutpatientVisits]
WHERE EffectiveAsOfDate = (select max(EffectiveAsOfDate) from  adw.FctOutpatientVisits);


