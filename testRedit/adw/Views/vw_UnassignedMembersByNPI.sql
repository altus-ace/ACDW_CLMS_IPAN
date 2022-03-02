
CREATE VIEW [adw].[vw_UnassignedMembersByNPI]
AS 

WITH CTE AS (
SELECT EffectiveDate, ClientKey, MAX(LoadDate) as MaxLoadDate
FROM [adw].[FailedMembership]
WHERE EffectiveDate     = (SELECT MAX(EffectiveDate) FROM [adw].[FailedMembership])
GROUP BY EffectiveDate , ClientKey
)
,
CTETIN AS (
SELECT AttribTIN, 
                AltNPIs = STUFF((SELECT ', '+ CONCAT(NPI,'(',LastName,')') FROM adw.tvf_AllClient_ProviderRoster (1,getdate(),1) t1
                WHERE t1.AttribTIN = t2.AttribTIN
                FOR XML PATH('')),1,1,'') FROM adw.tvf_AllClient_ProviderRoster (1,getdate(),1) t2
)

SELECT m.ClientKey, c.ClientName, m.LoadDate, m.NPI, m.NPIName, m.PRTin as AttribTIN, m.AttribTINName, COUNT(DISTINCT ClientMemberKey) as CntMbrs, t.AltNPIs 
FROM (
                SELECT f.*, r.AttribTIN as PRTin, r.AttribTINName, CONCAT(r.LastName,',',r.FirstName) as NPIName
                FROM [adw].[FailedMembership] f
					 LEFT JOIN adw.tvf_AllClient_ProviderRoster (1,getdate(),0) r
                ON  f.NPI       = r.NPI
                JOIN CTE l
                   ON  f.EffectiveDate                                         = l.EffectiveDate                                             
                   AND f.ClientKey                                             = l.ClientKey                                                                            
                   AND f.LoadDate                                              = l.MaxLoadDate                                                                                     
                WHERE   MbrNPIFlg = 0 
) m
LEFT JOIN CTETIN t
   ON m.PRTin  = t.AttribTIN
JOIN [lst].[List_Client] c
	ON m.ClientKey = c.ClientKey
GROUP BY m.ClientKey, c.ClientName, m.LoadDate, m.NPI, m.NPIName, m.PRTin, m.AttribTINName, t.AltNPIs 
--ORDER BY m.ClientKey, c.ClientName, m.LoadDate, m.NPI, m.NPIName, m.PRTin, m.AttribTINName, t.AltNPIs 

