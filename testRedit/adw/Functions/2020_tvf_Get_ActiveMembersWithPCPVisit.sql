







CREATE  FUNCTION [adw].[2020_tvf_Get_ActiveMembersWithPCPVisit]
(
	@PrimSvcDate_Start	DATE, 
	@PrimSvcDate_End	DATE,
	@EffDate			DATE
)
RETURNS TABLE
AS RETURN
(
SELECT DISTINCT SUBSCRIBER_ID, @EffDate AS EffDate, @PrimSvcDate_Start AS SvcStartDate, @PrimSvcDate_End as SvcEndDate
FROM [adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions] (@EffDate) 
INTERSECT
SELECT DISTINCT SUBSCRIBER_ID, @EffDate AS EffDate, @PrimSvcDate_Start AS SvcStartDate, @PrimSvcDate_End as SvcEndDate
FROM [adw].[2020_tvf_Get_PhyVisitsVisitType] (@PrimSvcDate_Start,@PrimSvcDate_End)

)

/***
Usage: 
SELECT DISTINCT SUBSCRIBER_ID
FROM [adw].[2020_tvf_Get_ActiveMembersWithPCPVisit] ('01/01/2020','12/31/2020','06/15/2020')
ORDER BY SUBSCRIBER_ID
***/




