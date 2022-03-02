


CREATE FUNCTION [adw].[2020_tvf_Get_ClaimsTMEByMember]
(
 @PrimSvcDate_Start DATE, 
 @PrimSvcDate_End   DATE
)

RETURNS TABLE
AS RETURN
(
SELECT --DISTINCT-- @PrimSvcDate_Start as PrimSvcDate_Start,@PrimSvcDate_End as PrimSvcDate_End
	a.ClientMemberKey 
	,a.PrimSvcYr
	,a.PrimSvcMth
	,COUNT(DISTINCT Seq_ClaimID)	AS CntClaims
	,SUM(TotPaidAmt)				AS TotPaidAmt
	,SUM(HHAPaidAmt)				AS HHAPaidAmt
	,SUM(SNFPaidAmt)				AS SNFPaidAmt
	,SUM(OPPaidAmt)					AS OPPaidAmt
	,SUM(HospicePaidAmt)			AS HospicePaidAmt
	,SUM(IPPaidAmt)					AS IPPaidAmt
	,SUM(PhyPaidAmt)				AS PhyPaidAmt
	,SUM(OtherPaidAmt)				AS OtherPaidAmt		
	,CASE WHEN PrefFacFlg = 1 OR PrefSvcFlg = 1 OR PrefAttFlg = 1 THEN COUNT(DISTINCT Seq_ClaimID)	ELSE 0 END	AS PrefCntClaims
	,CASE WHEN PrefFacFlg = 1 OR PrefSvcFlg = 1 OR PrefAttFlg = 1 THEN SUM(TotPaidAmt)				ELSE 0 END	AS PrefTotPaidAmt
	,CASE WHEN PrefFacFlg = 1 OR PrefSvcFlg = 1 OR PrefAttFlg = 1 THEN SUM(HHAPaidAmt)				ELSE 0 END	AS PrefHHAPaidAmt
	,CASE WHEN PrefFacFlg = 1 OR PrefSvcFlg = 1 OR PrefAttFlg = 1 THEN SUM(SNFPaidAmt)				ELSE 0 END	AS PrefSNFPaidAmt
	,CASE WHEN PrefFacFlg = 1 OR PrefSvcFlg = 1 OR PrefAttFlg = 1 THEN SUM(OPPaidAmt)				ELSE 0 END	AS PrefOPPaidAmt
	,CASE WHEN PrefFacFlg = 1 OR PrefSvcFlg = 1 OR PrefAttFlg = 1 THEN SUM(HospicePaidAmt)			ELSE 0 END	AS PrefHospicePaidAmt
	,CASE WHEN PrefFacFlg = 1 OR PrefSvcFlg = 1 OR PrefAttFlg = 1 THEN SUM(IPPaidAmt)				ELSE 0 END	AS PrefIPPaidAmt
	,CASE WHEN PrefFacFlg = 1 OR PrefSvcFlg = 1 OR PrefAttFlg = 1 THEN SUM(PhyPaidAmt)				ELSE 0 END	AS PrefPhyPaidAmt
	,CASE WHEN PrefFacFlg = 1 OR PrefSvcFlg = 1 OR PrefAttFlg = 1 THEN SUM(OtherPaidAmt)			ELSE 0 END	AS PrefOtherPaidAmt		
FROM [adw].[2020_tvf_Get_ClaimsTMEByMemberClaimID] (@PrimSvcDate_Start,@PrimSvcDate_End) a
GROUP BY ClientMemberKey
	,PrimSvcYr
	,PrimSvcMth
	,PrefFacFlg
	,PrefSvcFlg
	,PrefAttFlg
)
/***
Usage: 
SELECT * --PrimSvcYr, PrimSvcmth, Sum(TotPaidAmt)
FROM [adw].[2020_tvf_Get_ClaimsTMEByMember] ('2020-01-01','2020-03-01') a
where primsvcyr = 2020 and primsvcmth = 5 and oppaidamt <> 0
group BY  PrimSvcYr, PrimSvcmth
ORDER BY  PrimSvcYr, PrimSvcmth

***/


