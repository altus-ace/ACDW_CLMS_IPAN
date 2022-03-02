



CREATE  FUNCTION [adw].[tvf_Get_ProviderEngagementData]
(
	@MbrEffectiveDate		DATE,
	@PrimSvcDate_Start	DATE, 
	@PrimSvcDate_End		DATE,
	@CodesetEffDate		DATE
)
RETURNS TABLE
AS RETURN
(
SELECT m.ClientKey, m.ClientMemberKey, m.LOB, m.PlanID, m.PlanName, t.SumTotPaidAmt as SumTME
	,CASE WHEN a.CntVisit IS NULL THEN 0 ELSE a.CntVisit END			as AWVVisit
	,CASE WHEN p.CntVisit IS NULL THEN 0 ELSE p.CntVisit END			as PCPVisit
	,CASE WHEN f.CntFollowUpVisit IS NULL THEN 0 ELSE CntFollowUpVisit END			as FollowUpVisit
FROM [adw].[2020_tvf_Get_ActiveMembersFull] (@MbrEffectiveDate) m
JOIN (SELECT ClientMemberKey, SUM(TotPaidAmt) as SumTotPaidAmt FROM [adw].[2020_tvf_Get_ClaimsTMEByMember] (@PrimSvcDate_Start,@PrimSvcDate_End) GROUP BY ClientMemberKey) t
ON m.ClientMemberKey	= t.ClientMemberKey
LEFT JOIN (SELECT SUBSCRIBER_ID as ClientMemberKey, COUNT(DISTINCT PRIMARY_SVC_DATE) as CntVisit FROM [adw].[2020_tvf_Get_AWVisits] (@PrimSvcDate_Start,@PrimSvcDate_End,@CodesetEffDate) GROUP BY SUBSCRIBER_ID) a
ON m.ClientMemberKey	= a.ClientMemberKey
LEFT JOIN (SELECT SUBSCRIBER_ID as ClientMemberKey, COUNT(DISTINCT PRIMARY_SVC_DATE) as CntVisit FROM [adw].[2020_tvf_Get_PhyVisits] (@PrimSvcDate_Start,@PrimSvcDate_End) 
	WHERE PROV_SPEC_TYPE = 'P' GROUP BY SUBSCRIBER_ID) p
ON m.ClientMemberKey	= p.ClientMemberKey
LEFT JOIN (
	SELECT ClientMemberKey, COUNT(FollowUpVisit) as CntFollowUpVisit
	FROM (
		SELECT DISTINCT i.SUBSCRIBER_ID as ClientMemberKey, i.PRIMARY_SVC_DATE as AdmitDate, i.SVC_TO_DATE as DischDate, p.PRIMARY_SVC_DATE as OffVisit
			,DATEDIFF(dd,p.PRIMARY_SVC_DATE, i.SVC_TO_DATE) as FollowUPVisit
		FROM [adw].[2020_tvf_Get_IPVisits] (@PrimSvcDate_Start,@PrimSvcDate_End) i
		JOIN [adw].[2020_tvf_Get_PhyVisits] (@PrimSvcDate_Start,@PrimSvcDate_End) p
		ON i.SUBSCRIBER_ID	= p.SUBSCRIBER_ID
		AND DATEDIFF(dd,p.PRIMARY_SVC_DATE, i.SVC_TO_DATE) > 0
		AND DATEDIFF(dd,p.PRIMARY_SVC_DATE, i.SVC_TO_DATE) <= 30
	) m
	GROUP BY ClientMemberKey
	) f
ON m.ClientMemberKey	= f.ClientMemberKey
)


/***
Usage: 
SELECT *
FROM [adw].[tvf_Get_ProviderEngagementData] ('09/30/2020','01/01/2019','12/31/2019','04/30/2020')
***/



