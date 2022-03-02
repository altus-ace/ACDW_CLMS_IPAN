
CREATE  FUNCTION [adw].[2020_tvf_Get_NumOfGaps]
(
	@QMDate DATE
)
RETURNS TABLE
AS RETURN
(
SELECT DISTINCT ClientMemberKey
		,Count(DISTINCT QmMsrID) as CntOfGaps
	FROM [adw].[QM_ResultByMember_History]
	WHERE QMDate = QMDate
	AND QmCntCat = 'COP'
	GROUP BY ClientMemberKey

)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_NumOfGaps] ('2020-05-15')
***/




