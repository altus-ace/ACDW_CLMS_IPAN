







CREATE  FUNCTION [adw].[2020_tvf_Get_MembersLastAWVisit]
(
	@RunDate DATE
)
RETURNS TABLE
AS RETURN
(
		SELECT @RunDate as EffectiveAsOfDate, * FROM (
		SELECT awv.ClientMemberKey, awv.FctAWVVisitsSkey, awv.PrimaryServiceDate, awv.SVCProviderNPI, awv.SVCProviderName, awv.SVCProviderSpecialty
				, ROW_NUMBER() OVER (PARTITION BY awv.ClientMemberKey ORDER BY awv.PrimaryServiceDate desc) as LastEffective
				FROM [adw].[FctAWVVisits] awv
				WHERE awv.PrimaryServiceDate BETWEEN DATEADD(year, -2, @RunDate) AND @RunDate
		) lst
				WHERE lst.LastEffective = 1
)

/***
SELECT *
FROM [adw].[2020_tvf_Get_MembersLastAWVisit] (getdate())
***/
