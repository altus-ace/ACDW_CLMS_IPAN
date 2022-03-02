




CREATE  FUNCTION [adw].[2020_tvf_Get_PhyVisits]
(
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
		SELECT DISTINCT [SEQ_CLAIM_ID]
				,[SUBSCRIBER_ID]
				,[CATEGORY_OF_SVC]
				,[PRIMARY_SVC_DATE]
				,[SVC_TO_DATE]
				,[VEND_FULL_NAME]
				,[IRS_TAX_ID]
				,[DRG_CODE]
				,[BILL_TYPE]		-- three-digit codes located on the UB-04 claim form that describe the type of bill a provider is submitting to a payer, such as Medicaid or an insurance company
				,[ADMISSION_DATE]
				,[CLAIM_TYPE]
				,[PROV_TYPE]
				,[PROV_SPEC]
				,[SVC_PROV_NPI]
				,CASE WHEN PROV_SPEC IN ('01','1','General Practice','08','8','Family Practice') THEN 'P'
						WHEN PROV_SPEC IN ('11','Internal Medicine','16','Obstetrics/Gynecology') THEN 'P'
						WHEN PROV_SPEC IN ('38','Geriatric Medicine','70','Multi-specialty clinic or group practice') THEN 'P'
						WHEN PROV_SPEC IN ('84','Preventive medicine') THEN 'P'
						WHEN PROV_SPEC IN ('26','Psychiatry','27','Geriatric Psychiatry') THEN 'B'
						WHEN PROV_SPEC = '' THEN 'U'
						ELSE 'S' END AS [PROV_SPEC_TYPE]
				,[TOTAL_BILLED_AMT]
				,[TOTAL_PAID_AMT]
				,CASE WHEN DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) END AS LOS
				,DATEDIFF(dd, PRIMARY_SVC_DATE, GETDATE())		AS DaysSincePrimarySvcDate
		FROM [adw].[Claims_Headers]
		WHERE 
				[CATEGORY_OF_SVC]		IN ('PHYSICIAN','71','72')
				--AND [CLAIM_STATUS]			= @ClaimStatus
				--AND [PROCESSING_STATUS]		= @ProcessingStatus
				--AND [CLAIM_TYPE]			= @ClaimType
				AND CONVERT(DATETIME, PRIMARY_SVC_DATE)	BETWEEN	@PrimSvcDate_Start AND @PrimSvcDate_End
)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_PhyVisits] ('01/01/2019','12/31/2019')
WHERE SUBSCRIBER_ID = '113510880'
***/
