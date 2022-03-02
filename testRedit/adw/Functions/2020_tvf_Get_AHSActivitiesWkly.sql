CREATE FUNCTION [adw].[2020_tvf_Get_AHSActivitiesWkly]
	(	
		@StartDate			DATE,
		@EndDate			DATE
	)
RETURNS TABLE 
AS
RETURN 
(

SELECT ClientKey, DATEPART(ww,ActivityCreatedDate) as Wk
       ,DATEADD(dd, -(DATEPART(dw, ActivityCreatedDate)-1), ActivityCreatedDate) WkStart
       ,DATEADD(dd, 7-(DATEPART(dw, ActivityCreatedDate)), ActivityCreatedDate) WkEnd
       ,CareActivityTypeName
       ,count(*) as CntAct
FROM [adw].[mbrActivities]
WHERE ActivityCreatedDate BETWEEN @StartDate	AND @EndDate
GROUP BY ClientKey, DATEPART(ww,ActivityCreatedDate)
       ,DATEADD(dd, -(DATEPART(dw, ActivityCreatedDate)-1), ActivityCreatedDate) 
       ,DATEADD(dd, 7-(DATEPART(dw, ActivityCreatedDate)), ActivityCreatedDate)
       ,CareActivityTypeName 
--ORDER BY DATEPART(ww,ActivityCreatedDate)
--       ,DATEADD(dd, -(DATEPART(dw, ActivityCreatedDate)-1), ActivityCreatedDate) 
--       ,DATEADD(dd, 7-(DATEPART(dw, ActivityCreatedDate)), ActivityCreatedDate)
--       ,CareActivityTypeName
)
