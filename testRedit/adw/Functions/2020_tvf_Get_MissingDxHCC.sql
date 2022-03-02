





CREATE  FUNCTION [adw].[2020_tvf_Get_MissingDxHCC]
(
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20),
 @CodesetEffDate	VARCHAR(20)
)

RETURNS TABLE
AS RETURN
(
SELECT DISTINCT
	 PY.[SUBSCRIBER_ID]
	,PY.ValueCode
	,PY.HCC_CODE
	,PY.PRIMARY_SVC_DATE
FROM [adw].[2020_tvf_Get_ClaimsByHCC] (DATEADD(yy, DATEDIFF(yy, 0, @PrimSvcDate_Start) - 1, 0),DATEADD(yy, DATEDIFF(yy, 0, @PrimSvcDate_End), -1),DATEADD(yy, DATEDIFF(yy, 0, @CodesetEffDate), 0)) PY
LEFT JOIN [adw].[2020_tvf_Get_ClaimsByHCC] (@PrimSvcDate_Start,@PrimSvcDate_End,@CodesetEffDate) CY
ON PY.SUBSCRIBER_ID = CY.SUBSCRIBER_ID
AND PY.ValueCode = CY.ValueCode
WHERE PY.PRIMARY_SVC_DATE IS NOT NULL
AND PY.CLAIM_TYPE IN ('71','72')
AND CY.SUBSCRIBER_ID IS NULL

)


/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_MissingDxHCC] ('01/01/2021','01/31/2021','12/31/2020')
***/


