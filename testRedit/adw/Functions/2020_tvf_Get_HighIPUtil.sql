





CREATE  FUNCTION [adw].[2020_tvf_Get_HighIPUtil]
(
 @DaysElapse	      INT,			-- Days Apart from each visit
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
		SELECT a.*
			,b.PRIMARY_SVC_DATE AS AssocPrimarySvcDate
		FROM adw.[2020_tvf_Get_IPVisits](@PrimSvcDate_Start, @PrimSvcDate_End) a
		INNER JOIN adw.[2020_tvf_Get_IPVisits](@PrimSvcDate_Start, @PrimSvcDate_End) b
		ON a.SEQ_CLAIM_ID <> b.SEQ_CLAIM_ID
			AND a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
			AND ABS(DATEDIFF(day, a.SVC_TO_DATE, b.PRIMARY_SVC_DATE)) <= @DaysElapse
			AND a.SVC_TO_DATE <= b.PRIMARY_SVC_DATE

)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_HighIPUtil] (180,'01/01/2018','12/31/2019')

4 IP visits within 12 month period AND Total Paid Amt > 75K

SELECT DISTINCT SUBSCRIBER_ID, COUNT(DISTINCT PRIMARY_SVC_DATE) as IPVisits, SUM(TOTAL_PAID_AMT) as PaidAmt
	FROM [adw].[2020_tvf_Get_HighIPUtil] (180,'01/01/2018','12/31/2019')
GROUP BY SUBSCRIBER_ID
HAVING COUNT(DISTINCT PRIMARY_SVC_DATE) >= 4 AND SUM(TOTAL_PAID_AMT) >= 75000

***/
