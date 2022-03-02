
CREATE  FUNCTION [adw].[2020_tvf_Get_AWVisits]
(
	@PrimSvcDate_Start	DATE, 
	@PrimSvcDate_End	DATE,
	@CodesetEffDate		DATE
)
RETURNS TABLE
AS RETURN
(
		SELECT B1.[SEQ_CLAIM_ID]
			  ,B1.[SUBSCRIBER_ID]
			  ,B1.[CATEGORY_OF_SVC]
			  ,B1.[PRIMARY_SVC_DATE]
			  ,B1.[SVC_TO_DATE]
			  ,B1.[VEND_FULL_NAME]
			  ,B1.[IRS_TAX_ID]
			  ,B1.[DRG_CODE]
			  ,B1.[BILL_TYPE]		-- three-digit codes located on the UB-04 claim form that describe the type of bill a provider is submitting to a payer, such as Medicaid or an insurance company
			  ,B1.[ADMISSION_DATE]
			  ,B1.[CLAIM_TYPE]
			  ,B1.[PROV_TYPE]
			  ,B1.[PROV_SPEC]
			  ,B1.[TOTAL_BILLED_AMT]
			  ,B1.[TOTAL_PAID_AMT]
			  ,CASE WHEN D.ValueCode = 'G0438' THEN 'Initial'
					WHEN D.ValueCode = 'G0439' THEN 'Subsequent'
					WHEN D.ValueCode = 'G0402' THEN 'Welcome'
					WHEN D.ValueCode = 'G0468' THEN 'FQHC AWV'
					ELSE 'Other' END AS AWV_TYPE
			  ,d.ValueCode AS AWV_CODE
			  ,CASE WHEN DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) END AS LOS
			  ,DATEDIFF(dd, PRIMARY_SVC_DATE, GETDATE())		AS DaysSincePrimarySvcDate
			  ,B1.SVC_PROV_NPI
		  FROM [adw].[Claims_Headers] B1
		  INNER JOIN 
				(
				SELECT	DISTINCT SUBSCRIBER_ID, SEQ_CLAIM_ID, ValueCode
				FROM 	[adw].[2020_tvf_Get_ClaimsByValueCode] ('G0438','G0439','G0402','G0468',@PrimSvcDate_Start,@PrimSvcDate_End,@CodesetEffDate)
				) AS D
		  ON D.SEQ_CLAIM_ID = B1.SEQ_CLAIM_ID
			AND B1.SUBSCRIBER_ID = D.SUBSCRIBER_ID
		  WHERE B1.SEQ_CLAIM_ID IS NOT NULL
			--AND [CATEGORY_OF_SVC]		IN ('PHYSICIAN','71','72')
			--AND [CLAIM_STATUS]			= @ClaimStatus
			--AND [PROCESSING_STATUS]		= @ProcessingStatus
			AND [CLAIM_TYPE]				IN ('PHYSICIAN','71','72')
			AND CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)	>=  @PrimSvcDate_Start
			AND CONVERT(DATETIME, B1.SVC_TO_DATE)			<=  @PrimSvcDate_End

)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_AWVisits] ('01/01/2019','12/31/2019','04/30/2020')
ORDER BY SUBSCRIBER_ID
WHERE SUBSCRIBER_ID = '113510880'
***/



