







CREATE  FUNCTION [adw].[2020_tvf_Get_ActiveMembersWithoutPCPVisit]
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
EXCEPT
SELECT DISTINCT SUBSCRIBER_ID, @EffDate AS EffDate, @PrimSvcDate_Start AS SvcStartDate, @PrimSvcDate_End as SvcEndDate
FROM [adw].[2020_tvf_Get_PhyVisitsVisitType] (@PrimSvcDate_Start,@PrimSvcDate_End)

)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_ActiveMembersWithoutPCPVisit] ('01/01/2020','12/31/2020','04/30/2020')
ORDER BY SUBSCRIBER_ID
***/




