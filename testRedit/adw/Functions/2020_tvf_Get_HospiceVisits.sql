
CREATE  FUNCTION [adw].[2020_tvf_Get_HospiceVisits]
(
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
		SELECT	DISTINCT a.SUBSCRIBER_ID
				,a.SEQ_CLAIM_ID
				--,a.SVC_PROV_NPI
				--,a.PRIMARY_SVC_DATE
				--,a.PROV_SPEC
				--,a.PROV_TYPE
				,b.PROCEDURE_CODE AS CPT_CODE
				,b.DETAIL_SVC_DATE
				,COUNT(concat(b.PROCEDURE_CODE, b.DETAIL_SVC_DATE)) as CntProcCode
		FROM adw.Claims_Headers a
		JOIN adw.Claims_Details b
			ON a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
			AND a.SEQ_CLAIM_ID = b.SEQ_CLAIM_ID
		WHERE	a.CLAIM_TYPE IN ('50')
		AND b.DETAIL_SVC_DATE BETWEEN @PrimSvcDate_Start AND @PrimSvcDate_End
				--and b.PROCEDURE_CODE IN ('S9126','Q5001','Q5002','Q5003','Q5004','Q5005','Q5006','Q5007','Q5008','Q5009','Q5010')
				--and b.PROCEDURE_CODE IN ('T2042','T2043','T2044','T2045','T2046')
				and b.PROCEDURE_CODE IN ('G0151','G0152','G0153','G0154','G0155','G0156')
				--and b.PROCEDURE_CODE IN ('G0152','G0299','G0155','G0156') 
				--and LEFT(b.REVENUE_CODE,2) IN ('55','56','57')
		GROUP BY a.SUBSCRIBER_ID
				,a.SEQ_CLAIM_ID
				,b.PROCEDURE_CODE
				,b.DETAIL_SVC_DATE
)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_HospiceVisits] ('01/01/2020','05/31/2020')

Q5004	Hospice care provided in SNF
Q5005	Hospice care provided in inpatient hospital
Q5007	Hospice care provided in long term care hospital (LTCH)
Q5008	Hospice care provided in inpatient psychiatric facility
***/


