
CREATE  FUNCTION [adw].[2020_tvf_Get_ClaimsByEndOfLife]
(  
 @PrimSvcDate_Start DATE, 
 @PrimSvcDate_End   DATE,
 @CodesetEffDate	DATE
)
RETURNS TABLE
AS RETURN
(
		SELECT B1.[SEQ_CLAIM_ID]
			  ,B1.[SUBSCRIBER_ID]
			  ,B1.[CATEGORY_OF_SVC]
			  ,B1.[PRIMARY_SVC_DATE]
			  ,B1.[SVC_TO_DATE]
			  ,B1.[CLAIM_THRU_DATE]
			  ,B1.[VEND_FULL_NAME]
			  ,B1.[PROV_SPEC]
			  ,B1.[IRS_TAX_ID]
			  ,B1.[DRG_CODE]
			  ,B1.[BILL_TYPE]		
			  ,B1.[ADMISSION_DATE]
			  ,B1.[CLAIM_TYPE]
			  ,B1.[TOTAL_BILLED_AMT]
			  ,B1.[TOTAL_PAID_AMT]
			  ,D.ValueCode
			  ,D.ValueSetName
			  ,B1.PRIMARY_SVC_DATE AS VC_SVC_DATE
			  ,CASE WHEN DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) END AS LOS
			  ,DATEDIFF(dd,B1.PRIMARY_SVC_DATE, GETDATE())			AS DaysSincePrimarySvcDate
		  FROM [adw].[Claims_Headers] B1
		  INNER JOIN
			(
				SELECT DISTINCT C3.SEQ_CLAIM_ID, C3.diagCode AS ValueCode, L33.ValueSetName
				FROM adw.Claims_Diags C3
				INNER JOIN
				(
					SELECT DISTINCT ValueCode, ValueSetName
					FROM [adw].[2020_tvf_Get_ClaimsByValueSet] ('Hospice','ESRD','','',@PrimSvcDate_Start,@PrimSvcDate_End,@CodesetEffDate) L3
				) L33 ON L33.ValueCode = C3.diagCode
				UNION
				SELECT DISTINCT C4.SEQ_CLAIM_ID, L34.vc as VALUE_CODE, L34.VALUE_SET_NAME
				FROM adw.Claims_Diags C4
				INNER JOIN
				(
					SELECT DISTINCT VALUE_CODE_WithoutDot as VC, VALUE_SET_NAME, VALUE_CODE_SYSTEM, VALUE_SET_OID
					FROM lst.LIST_HEDIS_CODE L3
					WHERE L3.VALUE_SET_NAME LIKE ('%cancer%')
					AND L3.ACTIVE = 'Y'
					AND VALUE_CODE_SYSTEM IN('ICD9CM', 'ICD10CM')
					AND @CodesetEffDate BETWEEN L3.EffectiveDate AND L3.ExpirationDate
				) L34 ON L34.VC = C4.diagCodeWithoutDot
			) AS D 
		ON D.SEQ_CLAIM_ID = B1.SEQ_CLAIM_ID
		WHERE B1.SEQ_CLAIM_ID IS NOT NULL
		--AND B1.PROCESSING_STATUS	= 'P'
		--AND B1.CLAIM_STATUS			= 'P'
		AND CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)	>=  @PrimSvcDate_Start
		AND CONVERT(DATETIME, B1.SVC_TO_DATE)			<=  @PrimSvcDate_End
)
