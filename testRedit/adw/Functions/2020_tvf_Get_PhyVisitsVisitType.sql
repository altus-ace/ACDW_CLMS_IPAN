

CREATE  FUNCTION [adw].[2020_tvf_Get_PhyVisitsVisitType]
(
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
		SELECT	DISTINCT a.[SUBSCRIBER_ID]
				,a.[SEQ_CLAIM_ID]
				,a.[SVC_PROV_NPI]
				,a.PRIMARY_SVC_DATE
				,a.PROV_SPEC
				,a.PROV_TYPE
				,b.[PROCEDURE_CODE] AS CPT_CODE
				,b.LINE_NUMBER AS LineNumber
				,CASE WHEN b.[PROCEDURE_CODE] = '99201' THEN 'New - Problem Focused'
					WHEN b.[PROCEDURE_CODE] = '99202' THEN 'New - Expanded Problem Focused'
					WHEN b.[PROCEDURE_CODE] = '99203' THEN 'New - Detailed'
					WHEN b.[PROCEDURE_CODE] = '99204' THEN 'New - Comprehensive'
					WHEN b.[PROCEDURE_CODE] = '99205' THEN 'New - Comprehensive'
					WHEN b.[PROCEDURE_CODE] = '99211' THEN 'Established - Not Required'
					WHEN b.[PROCEDURE_CODE] = '99212' THEN 'Established - Problem Focused'
					WHEN b.[PROCEDURE_CODE] = '99213' THEN 'Established - Expanded Problem Focused'
					WHEN b.[PROCEDURE_CODE] = '99214' THEN 'Established - Detailed'
					WHEN b.[PROCEDURE_CODE] = '99215' THEN 'Established - Comprehensive'
				ELSE 'Unknown' END as VisitExamType
		FROM adw.Claims_Headers a
		JOIN adw.Claims_Details b
		ON a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
		AND a.[SEQ_CLAIM_ID] = b.[SEQ_CLAIM_ID]
		WHERE	a.CATEGORY_OF_SVC IN ('PHYSICIAN','71','72')
		AND b.[DETAIL_SVC_DATE] BETWEEN @PrimSvcDate_Start AND @PrimSvcDate_End
				AND b.PROCEDURE_CODE IN ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')
				--,'99241','99242','99243','99244','99245','92002')
)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_PhyVisitsVisitType] ('01/01/2020','12/31/2020')
***/


