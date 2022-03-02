
-- =============================================
-- Author:		Si Nguyen
-- Create date: 10/17/19
-- Description:	Get Programs By Member from Altruista
-- =============================================
CREATE FUNCTION [adw].[tvf_Get_AHSProgramsByMember]
(	
	-- parameters 
	@PlanEndYear		INT,
	@PastActivityMonth	INT

)
RETURNS TABLE 
AS
RETURN 
(
	WITH CTE AS (
	SELECT  
		b.[ClientMemberKey]					as MemberID
		,CONCAT(b.ProgramName,'(',b.ProgramStatus,')')		as PrgName
		--,ProgramStatusName						as ProgramStatus
		,convert(DATE, b.PlanStartDate)	as PlanSDate
		,convert(DATE, b.PlanStopDate)	as PlanEDate
		,convert(DATE, b.UpdateOnDate)	as UpdatedOnDate
	FROM [adw].[MbrProgramEnrollments] b
	WHERE YEAR(b.PlanStopDate)				= @PlanEndYear
	AND b.[ClientKey]					= 16				--
	AND ProgramStatus NOT LIKE '%Close%'					--
	AND Getdate() BETWEEN b.PlanStartDate AND b.PlanStopDate
)
	SELECT 
		t2.MemberID
		,(SELECT MIN(a.PlanSDate) FROM CTE a WHERE a.MemberID = t2.MemberID) as FirstActDate
		,(SELECT MAX(a.PlanSDate) FROM CTE a WHERE a.MemberID = t2.MemberID) as LastActDate
		,COUNT(*) as CntAct
		,ActType = LEFT(STUFF(
             (SELECT ' -- ' + t1.PrgName
              FROM CTE t1
              WHERE t1.MemberID = t2.MemberID
			  ORDER BY t1.UpdatedOnDate
              FOR XML PATH (''))
             , 1, 1, ''),200) 
	FROM CTE t2
	WHERE DATEDIFF(mm,(SELECT MIN(a.PlanSDate) FROM CTE a WHERE a.MemberID = t2.MemberID),GETDATE()) <= @PastActivityMonth 
	GROUP BY t2.MemberID
)

/***
Usage:
SELECT TOP 10 plansdate FROM [adw].[tvf_Get_AHSProgramsByMember] (2020, 12)
WHERE  ActType NOT LIKE '%CLOSE%'
AND MemberID = '7HJ0QU2JT49'
-- C- BMI Percentile 3-17 year olds(ACTIVE) -- C- BMI with nutritional counseling(ACTIVE) -- C- BMI with physical activity counseling(ACTIVE) -- C-Adolescent Well Care visits(ACTIVE) -- High-Adolescen
ORDER BY CntAct
***/


