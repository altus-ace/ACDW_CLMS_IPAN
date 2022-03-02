-- =============================================
-- Author:		Si Nguyen
-- Create date: 10/16/19
-- Description:	Get Activities by Member from Altruista
-- =============================================
CREATE FUNCTION [adw].[2020_tvf_Get_AHSActivitiesByMember]
	(	
		@ClientKey			INT,
		@PastActivityMonth	INT
	)
RETURNS TABLE 
AS
RETURN 
(
	WITH CTE AS (
	SELECT  b.MbrActivityKey       as TblKey
		,b.[ClientMemberKey]					as MemberID
		,convert(DATE, b.ActivityCreatedDate)	as ActDate
		,CareActivityTypeName+'('+ActivityOutcome+')'				as Activity
		,ActivityOutcome						as ActivityOutcome
		,OutcomeNotes							as OutcomeNotes
	FROM [adw].[mbrActivities] b
	WHERE DATEDIFF(mm,b.ActivityCreatedDate,GETDATE()) <= @PastActivityMonth
)

	SELECT t2.MemberID
		,(SELECT MIN(a.ActDate) FROM CTE a WHERE a.MemberID = t2.MemberID) as FirstActDate
		,(SELECT MAX(a.ActDate) FROM CTE a WHERE a.MemberID = t2.MemberID) as LastActDate
		,COUNT(*) as CntAct
		,ActType = RIGHT(STUFF(
             (SELECT ' -- ' + t1.Activity
              FROM CTE t1
              WHERE t1.MemberID = t2.MemberID
              FOR XML PATH (''))
             , 1, 1, ''),100) 
	FROM CTE t2
	GROUP BY t2.MemberID
)

/***
Usage:
SELECT * FROM [adw].[2020_tvf_Get_AHSActivitiesByMember] (16,12)
ORDER BY CntAct
***/

