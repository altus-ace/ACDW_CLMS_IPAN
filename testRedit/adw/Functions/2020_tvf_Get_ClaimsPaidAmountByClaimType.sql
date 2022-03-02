

CREATE  FUNCTION [adw].[2020_tvf_Get_ClaimsPaidAmountByClaimType]
(
 @PrimSvcDate_Start DATE, 
 @PrimSvcDate_End   DATE,
 @EffDate			DATE
)

RETURNS TABLE
AS RETURN
(
--WITH CTE AS (
		SELECT DISTINCT B1.CLAIM_TYPE as ClaimType
			,YEAR(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)) as PrimSvcYr
			,MONTH(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)) as PrimSvcMth
			,COUNT(DISTINCT B1.SEQ_CLAIM_ID) AS CntClaims
			,COUNT(DISTINCT B1.SUBSCRIBER_ID) AS CntMbrs
			,SUM(B1.[TOTAL_PAID_AMT]) AS SumPaidAmt
		FROM [adw].[Claims_Headers] B1
		--JOIN [adw].[2020_tvf_Get_ActiveMembersFull] (@EffDate) a
		--ON B1.SUBSCRIBER_ID = a.ClientMemberKey
		WHERE YEAR(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)) >= YEAR(@PrimSvcDate_Start)-2 
			AND YEAR(CONVERT(DATETIME, B1.SVC_TO_DATE))		<= YEAR(@PrimSvcDate_Start)
			--AND CLAIM_TYPE			IN ('10','20','30','40','50','60','61','71','72')
			--AND CATEGORY_OF_SVC <> 'PHARMACY'
			--AND B1.PROCESSING_STATUS			= 'P'
			--AND B1.CLAIM_STATUS				= 'P'
		GROUP BY B1.CLAIM_TYPE
			,YEAR(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE))
			,MONTH(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE))
	--SELECT DISTINCT @PrimSvcDate_Start as PrimSvcDate_Start,@PrimSvcDate_End as PrimSvcDate_End
	--	,YEAR(@PrimSvcDate_End) as CY
	--	,MONTH(@PrimSvcDate_End) as CM
	--	,YEAR(@PrimSvcDate_End)-1 as PY
	--	,CASE WHEN MONTH(@PrimSvcDate_End)=1 THEN 12 ELSE MONTH(@PrimSvcDate_End)-1 END as PM
	--	,CLAIM_TYPE
	--	--,(SELECT ISNULL(SumPaidAmt,0) FROM CTE WHERE PrimSvcYr = YEAR(@PrimSvcDate_Start)) AS CY_TotalPaid
	--	,SUM(CASE WHEN PrimSvcYr = YEAR(@PrimSvcDate_End) THEN SumPaidAmt ELSE 0 END) AS CCY_TotalPaid
	--	,SUM(CASE WHEN PrimSvcYr = YEAR(@PrimSvcDate_End)-1 THEN SumPaidAmt ELSE 0 END) AS CPY_TotalPaid
	--	,SUM(CASE WHEN PrimSvcYr = YEAR(@PrimSvcDate_End)-1 AND  THEN SumPaidAmt ELSE 0 END) AS CCY_TotalPaid
	--FROM CTE
	--GROUP BY CLAIM_TYPE
)
/***
Usage: 
SELECT a.*
FROM [adw].[2020_tvf_Get_ClaimsPaidAmountByClaimType] ('01/01/2020','1/31/2020','2020-05-15') a
ORDER BY SUBSCRIBER_ID
***/

