
CREATE FUNCTION [adw].[2020_tvf_Get_SurgVisits]
(
 @PrimSvcDate_Start DATE, 
 @PrimSvcDate_End   DATE
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
			  ,B1.[CLAIM_THRU_DATE]
			  ,B1.[VENDOR_ID]
			  ,B1.[PROV_SPEC]
			  ,B1.[IRS_TAX_ID]
			  ,B1.[DRG_CODE]
			  ,B1.[BILL_TYPE]		
			  ,B1.[ADMISSION_DATE]
			  ,B1.[CLAIM_TYPE]
			  ,B1.[TOTAL_BILLED_AMT]
			  ,B1.[TOTAL_PAID_AMT]
			  ,B1.SVC_PROV_NPI
			  ,B1.ATT_PROV_NPI
			  --,D.ProcCode AS PROC_CODE
			  ,drg.MedMorSurgP as DRGType
			  ,CASE WHEN DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) END AS LOS
			  ,DATEDIFF(dd,B1.PRIMARY_SVC_DATE, GETDATE())			AS DaysSincePrimarySvcDate
		FROM [adw].[Claims_Headers] B1
		--INNER JOIN
		--	(
		--	SELECT DISTINCT 
		--		C1.SUBSCRIBER_ID, C1.SEQ_CLAIM_ID, C1.ProcCode as ProcCode, C1.ProcDate AS ProcDate
		--		FROM adw.Claims_Procs C1
		--		WHERE LEFT(ProcCode,1) = '0'
		--	) AS D 
		--ON D.SUBSCRIBER_ID = B1.SUBSCRIBER_ID
		--AND D.[SEQ_CLAIM_ID]  = B1.[SEQ_CLAIM_ID] 
		LEFT JOIN lst.List_DRG drg
		ON B1.DRG_CODE = drg.DRG_CODE
		AND @PrimSvcDate_Start BETWEEN drg.EffectiveDate AND drg.ExpirationDate
		AND drg.ACTIVE = 'Y'
		--B1.PROCESSING_STATUS			= 'P'
		--AND B1.CLAIM_STATUS			= 'P'
		WHERE CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)	>=  @PrimSvcDate_Start
		AND CONVERT(DATETIME, B1.SVC_TO_DATE)			<=  @PrimSvcDate_End
		AND drg.MedMorSurgP = 'P'
		AND B1.CLAIM_TYPE IN ('40','60')


)

/***
Usage: 
SELECT a.*
FROM [adw].[2020_tvf_Get_SurgVisits] ('01/01/2020','03/31/2020') a
WHERE SUBSCRIBER_ID IN ('3AK5K25NJ54')
***/


