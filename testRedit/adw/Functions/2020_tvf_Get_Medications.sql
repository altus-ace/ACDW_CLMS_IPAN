

CREATE  FUNCTION [adw].[2020_tvf_Get_Medications]
(
 @PrimSvcDate_Start DATE, 
 @PrimSvcDate_End   DATE,
 @CodeEffDate	DATE
)
RETURNS TABLE
AS RETURN
(
				SELECT DISTINCT C3.SUBSCRIBER_ID
					,C3.SEQ_CLAIM_ID
					,C3.DETAIL_SVC_DATE
					,C3.NDC_CODE AS NDC_CODE
					,C3.LINE_NUMBER 
					,C3.RX_DATE_PRESCRIPTION_FILLED
					,C3.PRESCRIBING_PROV_ID
					,C3.ClaimsDetailsKey AS DetailKey
					,C3.QUANTITY
					,C3.RX_SUPPLY_DAYS
					,C4.ClaimsNDC AS NDC
					,C4.Brand AS NDC_DESC
				FROM adw.Claims_Details C3 
				LEFT JOIN [adw].[2020_tvf_Get_NDCDesc] (@CodeEffDate) C4 
				ON C3.NDC_CODE = C4.ClaimsNDC
				--AND C3.DETAIL_SVC_DATE BETWEEN C4.EffectiveDate AND C4.ExpirationDate
				WHERE LEN(C3.NDC_CODE) >= 10
				AND C3.DETAIL_SVC_DATE BETWEEN	@PrimSvcDate_Start AND @PrimSvcDate_End
)
