


CREATE FUNCTION [adw].[2020_tvf_Get_ClaimsPaidAmountByClaimID]
(
 @PrimSvcDate_Start DATE, 
 @PrimSvcDate_End   DATE
)

RETURNS TABLE
AS RETURN
(
SELECT 
	DISTINCT 
	B1.SUBSCRIBER_ID											as ClientMemberKey
	,YEAR(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE))	as PrimSvcYr
	,MONTH(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE))	as PrimSvcMth
	,CLAIM_TYPE													as ClaimType
	,B1.SEQ_CLAIM_ID											as Seq_ClaimID
	,B1.TOTAL_PAID_AMT										as TotPaidAmt
	,B1.TOTAL_BILLED_AMT										as TotBillAmt
	,CASE WHEN CLAIM_TYPE = '10' THEN B1.TOTAL_PAID_AMT ELSE 0 END																		AS HHAPaidAmt
	,CASE WHEN CLAIM_TYPE = '20' OR CLAIM_TYPE = '30' THEN B1.TOTAL_PAID_AMT ELSE 0 END											AS SNFPaidAmt
	,CASE WHEN CLAIM_TYPE = '40' THEN B1.TOTAL_PAID_AMT ELSE 0 END																		AS OPPaidAmt
	,CASE WHEN CLAIM_TYPE = '50' THEN B1.TOTAL_PAID_AMT ELSE 0 END																		AS HospicePaidAmt
	,CASE WHEN CLAIM_TYPE = '60' OR CLAIM_TYPE = '61' THEN B1.TOTAL_PAID_AMT ELSE 0 END											AS IPPaidAmt
	,CASE WHEN CLAIM_TYPE = '71' OR CLAIM_TYPE = '72' THEN B1.TOTAL_PAID_AMT ELSE 0 END											AS PhyPaidAmt
	,CASE WHEN CLAIM_TYPE IN ('01','02','03','04') OR CATEGORY_OF_SVC = 'PHARMACY' THEN B1.TOTAL_PAID_AMT ELSE 0 END	AS RxPaidAmt
	,CASE WHEN CLAIM_TYPE NOT IN ('10','20','30','40','50','60','61','71','72','01','02','03','04') THEN B1.TOTAL_PAID_AMT ELSE 0 END AS OtherPaidAmt
FROM adw.Claims_Headers B1
WHERE CONVERT(DATETIME, B1.PRIMARY_SVC_DATE) BETWEEN @PrimSvcDate_Start AND @PrimSvcDate_End
	AND B1.CLAIM_TYPE			IN ('10','20','30','40','50','60','61','71','72','01','02','03','04')
	AND B1.TOTAL_PAID_AMT <> 0
)

/***
Usage: 
SELECT PrimSvcYr, PrimSvcMth, ClientMemberKey, sum(TotPaidAmt) as TotalPaidAmt
	,sum(HHAPaidAmt) + sum(SNFPaidAmt) + sum(OPPaidAmt) + sum(HospicePaidAmt) + sum(IPPaidAmt) + sum(PhyPaidAmt) as TMEAmt
	,sum(RxPaidAmt) as RxPaidAmt
	,sum(PhyPaidAmt) as PhyPaidAmt
FROM [adw].[2020_tvf_Get_ClaimsPaidAmountByClaimID] ('2020-01-01','2020-05-31') a
GROUP BY   PrimSvcYr, PrimSvcMth, ClientMemberKey
ORDER BY   PrimSvcYr, PrimSvcMth, ClientMemberKey
***/


