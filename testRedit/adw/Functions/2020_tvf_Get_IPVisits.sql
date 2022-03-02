


CREATE  FUNCTION [adw].[2020_tvf_Get_IPVisits]
(
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
		SELECT [SEQ_CLAIM_ID]
			  ,[SUBSCRIBER_ID]
			  ,[CATEGORY_OF_SVC]
			  ,[ICD_PRIM_DIAG]
			  ,[PRIMARY_SVC_DATE]
			  ,[SVC_TO_DATE]
			  ,[VENDOR_ID]
			  ,[VEND_FULL_NAME]
			  ,[IRS_TAX_ID]
			  ,[DRG_CODE]
			  ,[BILL_TYPE]		-- three-digit codes located on the UB-04 claim form that describe the type of bill a provider is submitting to a payer, such as Medicaid or an insurance company
			  ,[ADMISSION_DATE]
			  ,[CLAIM_TYPE]
			  ,[TOTAL_BILLED_AMT]
			  ,[TOTAL_PAID_AMT]
			  ,[DISCHARGE_DISPO]
			  ,[SVC_PROV_NPI]
			  ,[ATT_PROV_NPI]
			  ,'560000' as [CMS_CertificationNumber]
			  ,CASE WHEN DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) END AS LOS
			  ,DATEDIFF(dd, PRIMARY_SVC_DATE, GETDATE())		AS DaysSincePrimarySvcDate
			  ,ROW_NUMBER () OVER (PARTITION BY SUBSCRIBER_ID ORDER BY PRIMARY_SVC_DATE )  AS tRowNum
		FROM [adw].[Claims_Headers]
		  WHERE [CLAIM_TYPE]		IN ('10','20','30','50','60','61')
			--AND [CLAIM_STATUS]		= @ClaimStatus
			--AND [PROCESSING_STATUS]	= @ProcessingStatus
			--OR  [CLAIM_TYPE]			IN ('MED-UB','60')
			--AND LEFT(BILL_TYPE,1)		= ('1')						--Hospital Only
			AND CONVERT(DATETIME, PRIMARY_SVC_DATE)	>= 	@PrimSvcDate_Start
			AND CONVERT(DATETIME, PRIMARY_SVC_DATE)	<=		@PrimSvcDate_End
)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_IPVisits] ('01/01/2020','12/31/2020')
WHERE CLAIM_TYPE = '60'

***/


