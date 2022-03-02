

CREATE  FUNCTION [adw].[2020_tvf_Get_HHAVisits]
(
 @PrimSvcDate_Start	DATE, 
 @PrimSvcDate_End		DATE
)
RETURNS TABLE
AS RETURN
(

SELECT i.SUBSCRIBER_ID 
	,i.[SEQ_CLAIM_ID]		
	,i.[CATEGORY_OF_SVC]
	,i.[PRIMARY_SVC_DATE]
	,i.[SVC_TO_DATE]
	,i.[CLAIM_THRU_DATE]
	,CASE WHEN DATEDIFF(dd, i.PRIMARY_SVC_DATE, i.SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, i.PRIMARY_SVC_DATE, i.SVC_TO_DATE) END AS LOS
	,i.[DRG_CODE]
	,i.[BILL_TYPE]		
	,i.[ADMISSION_DATE]
	,i.[CLAIM_TYPE]
	,i.[VENDOR_ID]
	,b.DETAIL_SVC_DATE, b.CPT_CODE, b.REVENUE_CODE
FROM [adw].[Claims_Headers] i 
JOIN [adw].[2020_tvf_Get_ClaimsByCPTCode] (@PrimSvcDate_Start,@PrimSvcDate_End)  b	
	ON i.SUBSCRIBER_ID = b.SUBSCRIBER_ID
	AND i.SEQ_CLAIM_ID = b.SEQ_CLAIM_ID	--
	AND (b.cpt_code IN ('G0300','G0299','G0151','G0152','G0153','G0155','G0156','G0157','G0158','G0159','G0160','G0161','G0162','G0493','G0494','G0495','G0496','G2168','G2169','Q5001','Q5002','Q5009')
	AND LEFT(b.REVENUE_CODE,2) IN ('42','43','44','55','56','57')
	OR b.REVENUE_CODE = '23')
WHERE  i.PRIMARY_SVC_DATE >= @PrimSvcDate_Start 
AND i.PRIMARY_SVC_DATE <= @PrimSvcDate_End
	AND i.CLAIM_TYPE in ('10')

)

/***
Usage: 

SELECT *
FROM [adw].[2020_tvf_Get_HHAVisits] ('2020-01-01','2020-06-30')
WHERE SUBSCRIBER_ID = '7dc8jr5tp21'
AND YEAR(PRIMARY_SVC_DATE) = 2020 AND MONTH(PRIMARY_SVC_DATE) = 6

Revenue Code = 23
Home Health services paid under PPS submitted as TOB 32X and 33X, effective 10/00.  
This code may appear multiple times on a claim to identify different HIPPS/Home Health Resource Groups (HRG).
http://www.mhha.org/wp-content/uploads/Committees/Regulatory/HH-Billing-Basics.pdf
***/

