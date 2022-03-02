



CREATE  FUNCTION [adw].[2020_tvf_Get_OPVisits]
(
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
		SELECT DISTINCT B1.[SEQ_CLAIM_ID]
			  ,B1.[SUBSCRIBER_ID]
			  ,B1.[CATEGORY_OF_SVC]
			  ,B1.[ICD_PRIM_DIAG]
			  ,B1.[PRIMARY_SVC_DATE]
			  ,B1.[SVC_TO_DATE]
			  ,B1.[VENDOR_ID]
			  ,B1.[VEND_FULL_NAME]
			  ,B1.[IRS_TAX_ID]
			  ,B1.[DRG_CODE]
			  ,B1.[BILL_TYPE]		-- three-digit codes located on the UB-04 claim form that describe the type of bill a provider is submitting to a payer, such as Medicaid or an insurance company
			  ,B1.[ADMISSION_DATE]
			  ,B1.[CLAIM_TYPE]
			  ,B1.[TOTAL_BILLED_AMT]
			  ,B1.[TOTAL_PAID_AMT]
			  ,B1.[DISCHARGE_DISPO]
			  ,B1.[SVC_PROV_NPI]
			  ,B1.ATT_PROV_NPI
			  ,B1.[CMS_CertificationNumber]
			  ,CASE WHEN DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) END AS LOS
			  ,DATEDIFF(dd, PRIMARY_SVC_DATE, GETDATE())		AS DaysSincePrimarySvcDate
		FROM [adw].[Claims_Headers] B1
		WHERE CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)	>=  @PrimSvcDate_Start
		AND CONVERT(DATETIME, B1.SVC_TO_DATE)			<=  @PrimSvcDate_End
		AND CLAIM_TYPE IN ('40')
)

/***
Usage: 
SELECT a.*
FROM [adw].[2020_tvf_Get_OPVisits] ('01/01/2019','12/31/2019') a
***/


