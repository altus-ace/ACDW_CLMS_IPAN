



CREATE VIEW [adw].[vw_Dashboard_ME_KPIByNPI]
AS 
    -- Purpose: creates a Persiste
    SELECT [FctFctMEKpiNPIKey]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[LastUpdatedDate]
      ,[LastUpdatedBy]
      ,[AdiKey]
      ,[SrcFileName]
      ,[AdwTableName]
      ,[LoadDate]
      ,[DataDate]
      ,[EffectiveAsOfDate]
      ,[KPI_ID]
	  ,[KPI]
	  ,substring([KPI],PATINDEX('%-%',[KPI])+1, len([KPI])) as KPIShort
      ,[KPIEffYear]
      ,[KPIEffMth]
      ,[AttribNPI]
      ,[AttribNPIName]
      ,[AttribTIN]
      ,[AttribTINName]
      ,[KPIValue]
      ,[KPIValue2]
	  ,AttribPOD as NPIChapter 
FROM [adw].[FctMEKPIByNPI]
WHERE EffectiveAsOfDate = (select max(EffectiveAsOfDate) from  [adw].[FctMEKPIByNPI])
--AND AttribNPI <> 0





