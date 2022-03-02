

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [adw].[vw_Dashboard_ProgramWorklists]
as 

SELECT h.EffectiveAsOfDate
	,h.ProgramID	
	,h.ProgramName				as MeasureName
	,h.RiskScore				as AceImpactScore
	,h.ClientMemberKey		as MemberID
	,a.FirstName
	,a.LastName
	,a.Gender
	,a.DOB
	,a.MemberHomeCity
	,a.MemberHomeState
	,a.ProviderChapter
	,'(999)999-9999'			as MemberPhone-- a.MemberPhone
	,a.NPI
	,CONCAT(a.ProviderFirstName,' ',a.ProviderLastName) as PCPName
	,a.pcpPracticeTIN
	,a.ProviderPracticeName as PracticeName
	,h.Notes
	,ROW_NUMBER() OVER( PARTITION BY h.ClientMemberKey, h.ProgramID, h.ProgramName ORDER BY h.URN ASC) rn
FROM [adw].[ProgramResultByMember_History] h
	JOIN adw.fctMembership a
		ON		h.ClientMemberKey	= a.ClientMemberKey
		AND	h.EffectiveAsOfDate BETWEEN a.RwEffectiveDate AND a.RwExpirationDate
WHERE h.EffectiveAsOfDate = (SELECT MAX(EffectiveAsOfDate) FROM [adw].[ProgramResultByMember_History])

/***
SELECT * FROM [adw].[vw_Dashboard_ProgramWorklists] WHERE MemberID = '8YE7Y32DD34'
***/
