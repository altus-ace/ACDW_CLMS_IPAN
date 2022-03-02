

/***
Retrieves list Claims Header Info based on ValueCodes 
***/

CREATE  FUNCTION [adw].[2020_tvf_Get_ClaimsByICDCategory]
(@ValueCode1			VARCHAR(150), 
 @ValueCode2			VARCHAR(150), 
 @ValueCode3			VARCHAR(150), 
 @ValueCode4			VARCHAR(150),  
 @PrimSvcDate_Start		VARCHAR(20), 
 @PrimSvcDate_End		VARCHAR(20),
 @CodesetEffDate		VARCHAR(20)
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
			  ,D.ValueCodeSystem
			  --,D.ValueCodeSvcDate 
			  ,CASE WHEN DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) END AS LOS
			  ,DATEDIFF(dd,B1.PRIMARY_SVC_DATE, GETDATE())			AS DaysSincePrimarySvcDate
		  FROM [adw].[Claims_Headers] B1
		  INNER JOIN
			(

				SELECT DISTINCT C3.SEQ_CLAIM_ID,L33.VC AS ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem
				FROM adw.Claims_Diags C3
				INNER JOIN
				(
					SELECT DISTINCT VALUE_CODE_WithoutDot as VC, VALUE_CODE_SYSTEM
					FROM lst.LIST_HEDIS_CODE L3
					WHERE LEFT(L3.VALUE_CODE,3) IN (@ValueCode1,@ValueCode2,@ValueCode3,@ValueCode4)
					AND L3.ACTIVE = 'Y'
					AND VALUE_CODE_SYSTEM IN('ICD9CM', 'ICD10CM')
					AND @CodesetEffDate BETWEEN L3.EffectiveDate AND L3.ExpirationDate
				) L33 ON L33.VC = C3.diagCodeWithoutDot

			) AS D 
		ON D.SEQ_CLAIM_ID = B1.SEQ_CLAIM_ID
		WHERE B1.SEQ_CLAIM_ID IS NOT NULL
		--AND B1.PROCESSING_STATUS	= 'P'
		--AND B1.CLAIM_STATUS			= 'P'
		AND CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)	>=  @PrimSvcDate_Start
		AND CONVERT(DATETIME, B1.SVC_TO_DATE)			<=  @PrimSvcDate_End
)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_ClaimsByICDCategory] ('Z3A','','','','01/01/2019','12/31/2019','12/31/2019')
***/
