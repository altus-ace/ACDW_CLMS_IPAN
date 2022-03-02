CREATE  FUNCTION [adw].[2020_tvf_Get_ClaimsByValueSet]
(@ValueSet1				VARCHAR(150), 
 @ValueSet2				VARCHAR(150), 
 @ValueSet3				VARCHAR(150), 
 @ValueSet4				VARCHAR(150),  
 @PrimSvcDate_Start		VARCHAR(20), 
 @PrimSvcDate_End		VARCHAR(20),
 @CodesetEffDate		VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
SELECT		   B1.[SEQ_CLAIM_ID]
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
			  ,D.ValueSetName
			  ,B1.PRIMARY_SVC_DATE AS ValueCodeSvcDate
			  ,CASE WHEN DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, PRIMARY_SVC_DATE, SVC_TO_DATE) END AS LOS
			  ,DATEDIFF(dd,B1.PRIMARY_SVC_DATE, GETDATE())			AS DaysSincePrimarySvcDate
			  ,B1.SVC_PROV_NPI

FROM		  [adw].[Claims_Headers] B1
INNER JOIN
			  (
			  SELECT DISTINCT	C1.SEQ_CLAIM_ID, VALUE_CODE as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
			  FROM				adw.Claims_Procs C1
			  INNER JOIN
			  (
				  SELECT DISTINCT	VALUE_CODE, VALUE_CODE_SYSTEM, VALUE_SET_NAME 
				  FROM				lst.LIST_HEDIS_CODE L1
				  WHERE				L1.VALUE_SET_NAME IN(@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
				  AND				L1.ACTIVE = 'Y'
				  AND				VALUE_CODE_SYSTEM IN('ICD10PCS', 'ICD9PCS')
				  AND				@CodesetEffDate BETWEEN L1.EffectiveDate AND L1.ExpirationDate
			  )						L11 
			  ON					L11.VALUE_CODE = C1.ProcCode
UNION
			  SELECT DISTINCT		C2.SEQ_CLAIM_ID, VALUE_CODE as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
			  FROM					adw.Claims_Headers C2
			  INNER JOIN
			  (
				  SELECT DISTINCT	VALUE_CODE, VALUE_CODE_SYSTEM, VALUE_SET_NAME 
				  FROM				lst.LIST_HEDIS_CODE L2
				  WHERE				L2.VALUE_SET_NAME IN(@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
				  AND				L2.ACTIVE = 'Y'
				  AND				VALUE_CODE_SYSTEM IN('MSDRG')
				  AND				@CodesetEffDate BETWEEN L2.EffectiveDate AND L2.ExpirationDate
			  )						L22
			  ON					L22.VALUE_CODE = C2.DRG_CODE
UNION
			  SELECT DISTINCT		C3.SEQ_CLAIM_ID, VALUE_CODE_WithoutDot as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
			  FROM					adw.Claims_Diags C3
			  INNER JOIN 
			  --(
				 -- SELECT DISTINCT	SEQ_CLAIM_ID, PRIMARY_SVC_DATE
				 -- FROM				adw.Claims_Headers C33
			  --)						L333
			  --ON				L333.SEQ_CLAIM_ID = C3.SUBSCRIBER_ID
			  --INNER JOIN
			  (
				  SELECT DISTINCT	VALUE_CODE_WithoutDot, VALUE_CODE_SYSTEM, VALUE_SET_NAME
				  FROM				lst.LIST_HEDIS_CODE L3
				  WHERE				L3.VALUE_SET_NAME IN(@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
				  AND				L3.ACTIVE = 'Y'
				  AND				VALUE_CODE_SYSTEM IN('ICD9CM', 'ICD10CM')
				  AND				@CodesetEffDate BETWEEN L3.EffectiveDate AND L3.ExpirationDate
			  )						L33
			  ON					L33.VALUE_CODE_WithoutDot = C3.diagCodeWithoutDot
UNION
			  SELECT DISTINCT		C4.SEQ_CLAIM_ID, VALUE_CODE as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
			  FROM					adw.Claims_Details C4
			  INNER JOIN
			  (
				  SELECT DISTINCT	VALUE_CODE, VALUE_CODE_SYSTEM , VALUE_SET_NAME
				  FROM				lst.LIST_HEDIS_CODE L4
				  WHERE				L4.VALUE_SET_NAME IN(@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
				  AND				L4.ACTIVE = 'Y'
				  AND				VALUE_CODE_SYSTEM IN('UBREV')
				  AND				@CodesetEffDate BETWEEN L4.EffectiveDate AND L4.ExpirationDate
			  )						L44
			  ON					CAST(L44.VALUE_CODE AS INT) = CAST(C4.REVENUE_CODE AS INT)
UNION
			  SELECT DISTINCT		C5.SEQ_CLAIM_ID, VALUE_CODE as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
			  FROM					adw.Claims_Details C5
				INNER JOIN
				(
					SELECT DISTINCT VALUE_CODE, VALUE_CODE_SYSTEM, VALUE_SET_NAME
					FROM			lst.LIST_HEDIS_CODE L5
					WHERE			L5.VALUE_SET_NAME IN (@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
					AND				L5.ACTIVE = 'Y'
					AND				VALUE_CODE_SYSTEM IN('NDC')
					AND				@CodesetEffDate BETWEEN L5.EffectiveDate AND L5.ExpirationDate
				) L55 ON			L55.VALUE_CODE = C5.NDC_CODE
UNION
			 SELECT DISTINCT		C8.SEQ_CLAIM_ID, VALUE_CODE as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
			 FROM							 
									(
											SELECT DISTINCT VALUE_CODE, VALUE_CODE_SYSTEM,VALUE_SET_NAME, SEQ_CLAIM_ID FROM 
											(
											SELECT		 MODIFIER_CODE_1 AS Modifier, SEQ_CLAIM_ID
											FROM		 adw.Claims_Details 
											UNION
											SELECT		 MODIFIER_CODE_2, SEQ_CLAIM_ID
											FROM		 adw.Claims_Details
											UNION
											SELECT		 MODIFIER_CODE_3, SEQ_CLAIM_ID
											FROM		 adw.Claims_Details
											UNION
											SELECT		 MODIFIER_CODE_4, SEQ_CLAIM_ID
											FROM		 adw.Claims_Details
											) a			
											JOIN			
											(
											SELECT DISTINCT VALUE_CODE, VALUE_CODE_SYSTEM, VALUE_SET_NAME
											FROM			lst.LIST_HEDIS_CODE 						
											WHERE			VALUE_CODE IN (SELECT DISTINCT VALUE_CODE FROM lst.LIST_HEDIS_CODE WHERE VALUE_CODE_SYSTEM = 'Modifier')
											AND				VALUE_SET_NAME IN(@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
											AND				ACTIVE = 'Y'
											AND				VALUE_CODE_SYSTEM IN('Modifier')
											AND				@CodesetEffDate BETWEEN EffectiveDate AND ExpirationDate)z
											ON				z.Value_Code = a.Modifier) C8
UNION

			SELECT DISTINCT			C9.SEQ_CLAIM_ID, VALUE_CODE_WithoutDot as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
			FROM					adw.Claims_Diags C9
			  INNER JOIN 
			  (
				  SELECT DISTINCT	VALUE_CODE_WithoutDot, VALUE_CODE_SYSTEM, VALUE_SET_NAME,CCS_CATEGORY, [ICD-10-CM_CODE]
				  FROM				lst.LIST_HEDIS_CODE L9
				  JOIN				[lst].[LIST_ICDCCS] dia
				  ON				VALUE_CODE_WithoutDot = CCS_Category
				  WHERE				L9.VALUE_SET_NAME IN(@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
				  AND				L9.ACTIVE = 'Y'
				  AND				VALUE_CODE_SYSTEM IN('CCS Category-ICD10CM')
				  AND				@CodesetEffDate BETWEEN L9.EffectiveDate AND L9.ExpirationDate
			  )						L99
			  ON					L99.[ICD-10-CM_CODE] = C9.diagCodeWithoutDot

UNION

			SELECT DISTINCT			C10.SEQ_CLAIM_ID, VALUE_CODE_WithoutDot as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
			FROM					adw.Claims_Procs C10 
			  INNER JOIN 
			  (
				  SELECT DISTINCT	VALUE_CODE_WithoutDot, VALUE_CODE_SYSTEM, VALUE_SET_NAME,CCSCategory, ICD10PCSCode
				  FROM				lst.LIST_HEDIS_CODE L10
				  JOIN				[lst].[List_ICD10PCScwCCSCategory] prc
				  ON				VALUE_CODE_WithoutDot = CCSCategory
				  WHERE				L10.VALUE_SET_NAME IN(@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
				  AND				L10.ACTIVE = 'Y'
				  AND				VALUE_CODE_SYSTEM IN('CCS Category-ICD10PCS')
				  AND				@CodesetEffDate BETWEEN L10.EffectiveDate AND L10.ExpirationDate
			  )						L109
			  ON					L109.ICD10PCSCode = C10.ProcCode

UNION
				SELECT DISTINCT		C6.SEQ_CLAIM_ID,VALUE_CODE as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
				FROM				adw.Claims_Details C6			  
				INNER JOIN
			  (
				  SELECT DISTINCT	VALUE_CODE, VALUE_CODE_SYSTEM, VALUE_SET_NAME 
				  FROM				lst.LIST_HEDIS_CODE L6
				  WHERE				L6.VALUE_SET_NAME IN(@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
				  AND				L6.ACTIVE = 'Y'
				  AND				L6.VALUE_CODE_SYSTEM IN('CPT', 'CPT-CAT-II', 'HCPCS', 'CDT')
				  AND				@CodesetEffDate BETWEEN L6.EffectiveDate AND L6.ExpirationDate
			  )						L66
			  ON					L66.VALUE_CODE = C6.PROCEDURE_CODE
UNION 
			  SELECT DISTINCT		C7.SEQ_CLAIM_ID,VALUE_CODE as ValueCode,VALUE_CODE_SYSTEM as ValueCodeSystem, VALUE_SET_NAME as ValueSetName,'' CCSCategory
			  FROM					adw.Claims_Details C7
              INNER JOIN 
			  (
				  SELECT DISTINCT	VALUE_CODE, VALUE_CODE_SYSTEM, VALUE_SET_NAME 
				  FROM				lst.LIST_HEDIS_CODE L7 
				  WHERE				L7.VALUE_SET_NAME IN(@ValueSet1, @ValueSet2, @ValueSet3, @ValueSet4)
				  AND				L7.ACTIVE = 'Y'
				  AND				L7.VALUE_CODE_SYSTEM IN('POS')
				  AND				@CodesetEffDate BETWEEN L7.EffectiveDate AND L7.ExpirationDate
			  )						L77 
			  ON					L77.VALUE_CODE = C7.PLACE_OF_SVC_CODE1
			  )						AS D 
			  ON					D.SEQ_CLAIM_ID = B1.SEQ_CLAIM_ID
			  WHERE					B1.SEQ_CLAIM_ID IS NOT NULL
			  --AND					B1.PROCESSING_STATUS	= 'P'
		      --AND					B1.CLAIM_STATUS IN (0,1,3,5,'')-- = ( Select Destination From [lst].[ListAceMapping] Where lstAceMappingKey = 338)
		AND CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)	>=  @PrimSvcDate_Start
		AND CONVERT(DATETIME, B1.SVC_TO_DATE)			<=  @PrimSvcDate_End

				
)
/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_ClaimsByValueSet] ('HEDIS_ACO_Right Modifier','HEDIS_ACO_Left Modifier','HEDIS_ACO_Bilateral Modifier','','01/01/2019','12/31/2020','2020-01-01')
***/

