/***
Get the latest specialty code for the Svc Provider
***/

CREATE FUNCTION [adw].[2020_tvf_Get_ProvSpecialtyFromPhyVisits]
(@EffDate		DATE
)
RETURNS TABLE
AS
RETURN

( 
SELECT * FROM (
SELECT DISTINCT [SVCProviderNPI]	as NPI
	,[SVCProviderName]				as NPIName
	,[SVCProviderSpecialty]			as SpecCode
	,lst.CodeDesc					as SpecDesc
	,ROW_NUMBER() OVER (PARTITION BY SVCProviderNPI ORDER BY PrimaryServiceDate DESC) rno
FROM [adw].[FctPhysicianVisits] pcp
LEFT JOIN [lst].[LIST_PROV_SPECIALTY_CODES] lst
	ON pcp.[SVCProviderSpecialty] = lst.Code
WHERE @EffDate BETWEEN lst.EffectiveDate AND lst.ExpirationDate
AND pcp.EffectiveAsOfDate = (SELECT MAX(EffectiveAsOfDate) FROM [adw].[FctPhysicianVisits])
AND lst.ACTIVE = 'Y') a
WHERE a.rno = 1

)
/***
Usage: 
SELECT npi, count(distinct speccode)
FROM [adw].[2020_tvf_Get_ProvSpecialtyFromPhyVisits] ('07/01/2020') 
group BY NPI

select *
FROM [adw].[2020_tvf_Get_ProvSpecialtyFromPhyVisits] ('07/01/2020') 
where npi = '1063402717'
***/
