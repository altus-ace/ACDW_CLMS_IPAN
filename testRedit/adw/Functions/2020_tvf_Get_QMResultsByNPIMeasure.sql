
CREATE  FUNCTION [adw].[2020_tvf_Get_QMResultsByNPIMeasure]
(
	@QMDate		DATE,
	@EffDate	DATE
)
RETURNS TABLE
AS RETURN
(
SELECT DISTINCT qm.QMDate
		,mbr.NPI as AttribNPI
		,qm.QmMsrID
		,SUM(CASE WHEN qm.QmCntCat = 'DEN' THEN 1 ELSE 0 END) AS Den
		,SUM(CASE WHEN qm.QmCntCat = 'NUM' THEN 1 ELSE 0 END) AS Num
		,SUM(CASE WHEN qm.QmCntCat = 'COP' THEN 1 ELSE 0 END) AS Gap
		,vis.SUBSCRIBER_ID 
		,SUM(CASE WHEN qm.QmCntCat = 'DEN' AND LEN(vis.SUBSCRIBER_ID) > 1 THEN 1 ELSE 0 END) AS ModDen
		,SUM(CASE WHEN qm.QmCntCat = 'NUM' AND LEN(vis.SUBSCRIBER_ID) > 1 THEN 1 ELSE 0 END) AS ModNum
		,SUM(CASE WHEN qm.QmCntCat = 'COP' AND LEN(vis.SUBSCRIBER_ID) > 1 THEN 1 ELSE 0 END) AS ModGap
FROM [adw].[QM_ResultByMember_History] qm
LEFT JOIN adw.vw_Dashboard_Membership mbr
	ON qm.ClientMemberKey = mbr.ClientMemberKey
LEFT JOIN [adw].[2020_tvf_Get_ActiveMembersWithPCPVisit] (dateadd(month,datediff(month,0,@EffDate)-15,0),dateadd(month,datediff(month,0,@EffDate)-3,0),@EffDate) vis
	ON qm.ClientMemberKey = vis.SUBSCRIBER_ID
WHERE qm.QMDate = @QMDate
AND @EffDate BETWEEN mbr.RwEffectiveDate AND mbr.RwExpirationDate
	--AND QmCntCat = 'COP'
GROUP BY qm.QmDate, mbr.NPI, qm.QmMsrID,vis.SUBSCRIBER_ID

)

/***
Usage: 
SELECT QmDate
	,AttribNPI
	,QmMsrID as Measure
	,Qm_Desc as Description
	,Sum(Den) as Den
	,Sum(Num) as Num
	,Sum(Gap) as Gaps
	,CAST(Sum(Num) as float) / Sum(Den) * 100 as CompliantRate
	,Sum(ModDen) as ModDen
	,Sum(ModNum) as ModNum
	,Sum(ModGap) as ModGaps
	,CAST ((CAST(Sum(ModNum) as float)/(Sum(ModDen)+0.000001) * 100) AS DECIMAL(5,2)) as ModCompRate
FROM [adw].[2020_tvf_Get_QMResultsByNPIMeasure] ('2021-03-15','2021-03-15')
LEFT JOIN [lst].[LIST_QM_Mapping]
ON [QM] = QmMsrID
GROUP BY QmDate
	,AttribNPI
	,QmMsrID
	,Qm_Desc
***/

