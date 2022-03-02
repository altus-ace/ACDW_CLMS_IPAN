





CREATE VIEW [adw].[vw_Dashboard_AWVVisits]
AS 
    -- Purpose: creates a Persiste
SELECT 
     (select max(EffectiveAsOfDate) from adw.FctAWVVisits) as EffectiveAsOfDate
	 ,mbr.[ClientKey]
     ,mbr.[ClientMemberKey]
	 ,mbr.Expired
     ,mbr.[AttribNPI]
     ,mbr.[AttribTIN]
	 ,CASE WHEN vis.CompliantStatus = 'C' THEN vis.CompliantStatus ELSE mbr.CompliantStatus END as CompliantStatus
	 ,vis.PrimaryServiceDate
	 ,CASE WHEN vis.PrimaryServiceDate IS NOT NULL THEN Year(vis.PrimaryServiceDate) ELSE Year(Getdate()) END as SvcYear
FROM (
	SELECT 
	      [ClientKey]
	      ,[ClientMemberKey]
	      ,[NPI] as AttribNPI
	      ,[PcpPracticeTIN] as AttribTIN
		  ,'N' as CompliantStatus
		  ,CASE WHEN DOD = '1900-01-01' THEN 'N' ELSE 'Y' END AS Expired
	FROM [adw].[FctMembership]
	WHERE (select max(EffectiveAsOfDate) from  adw.FctAWVVisits) BETWEEN RwEffectiveDate AND RwExpirationDate
	) mbr
LEFT JOIN (
	SELECT DISTINCT
	      [ClientKey]
	      ,[ClientMemberKey]
	      ,[AttribNPI]
	      ,[AttribTIN]
		  ,'C' as CompliantStatus
		  ,[PrimaryServiceDate]
	FROM adw.FctAWVVisits
	WHERE EffectiveAsOfDate = (select max(EffectiveAsOfDate) from  adw.FctAWVVisits)
	--AND Year(PrimaryServiceDate) = Year(GetDate())
	) vis
ON vis.ClientKey = mbr.ClientKey
AND vis.ClientMemberKey = mbr.ClientMemberKey

--SELECT *
--	FROM adw.FctAWVVisits
--	WHERE EffectiveAsOfDate = (select max(EffectiveAsOfDate) from  adw.FctAWVVisits)


