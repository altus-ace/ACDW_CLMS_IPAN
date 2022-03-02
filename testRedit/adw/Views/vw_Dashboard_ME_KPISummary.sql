









CREATE VIEW [adw].[vw_Dashboard_ME_KPISummary]
AS 
    -- Purpose: creates a Persiste
    SELECT 
		[FctFctMEKpiSumKey]
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
      ,[KPIEffYear]
      ,[KPIEffMth]
      ,[Numerator]
      ,[Denominator]
      ,[Value]
FROM [adw].[FctMEKPISummary]
WHERE EffectiveAsOfDate = (select max(EffectiveAsOfDate) from  [adw].[FctMEKPISummary])
--AND AttribNPI <> 0




