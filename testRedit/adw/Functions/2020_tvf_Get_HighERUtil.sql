




CREATE  FUNCTION [adw].[2020_tvf_Get_HighERUtil]
(
 @DaysElapse	      INT,			-- Days Apart from each visit
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
		
		
		SELECT DISTINCT a.SUBSCRIBER_ID, a.PRIMARY_SVC_DATE, a.TOTAL_PAID_AMT
			,b.PRIMARY_SVC_DATE AS AssocPrimarySvcDate
		FROM adw.[2020_tvf_Get_ERVisits](@PrimSvcDate_Start, @PrimSvcDate_End) a
		INNER JOIN adw.[2020_tvf_Get_ERVisits](@PrimSvcDate_Start, @PrimSvcDate_End) b
		ON a.SEQ_CLAIM_ID <> b.SEQ_CLAIM_ID
			AND a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
			AND ABS(DATEDIFF(day, a.SVC_TO_DATE, b.PRIMARY_SVC_DATE)) <= @DaysElapse
			AND a.SVC_TO_DATE <= b.PRIMARY_SVC_DATE

)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_HighERUtil] (180,'01/01/2019','12/31/2019')

6 Emergency Room visits within 12 month period AND Total Paid Amt > 75K

SELECT DISTINCT SUBSCRIBER_ID, COUNT(DISTINCT PRIMARY_SVC_DATE) as ERVisits, SUM(TOTAL_PAID_AMT) as PaidAmt
	FROM [adw].[2020_tvf_Get_HighERUtil] (180,'01/01/2019','12/31/2019')
GROUP BY SUBSCRIBER_ID
HAVING COUNT(DISTINCT PRIMARY_SVC_DATE) >= 6 AND SUM(TOTAL_PAID_AMT) >= 75000
***/
