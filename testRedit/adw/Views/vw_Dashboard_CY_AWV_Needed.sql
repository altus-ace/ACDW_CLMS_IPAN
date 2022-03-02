


CREATE VIEW [adw].[vw_Dashboard_CY_AWV_Needed]
AS 
    -- 
WITH CTE 
AS 
(
		SELECT src.*
		FROM
	(
		 SELECT	DISTINCT [ClientKey]
						,[ClientMemberKey]
						,[AttribNPI]
						,[AttribTIN]
						,'C' as CompliantStatus
						,AWVType 
						,[PrimaryServiceDate]
						,EffectiveAsOfDate
						,ROW_NUMBER() OVER(PARTITION BY ClientKey,ClientMemberKey,AttribNPI,AttribTIN 
							ORDER BY ClientKey,ClientMemberKey,PrimaryServiceDate DESC) arn
		 FROM	adw.FctAWVVisits m
		 WHERE	EffectiveAsOfDate = (SELECT MAX(EffectiveAsOfDate) FROM  adw.FctAWVVisits)
		 --AND awvtype = 'NonClaim'
	) src
	WHERE src.arn = 1 
)


	SELECT		RANK() OVER (ORDER BY vis.PrimaryServiceDate, ClientRiskScoreLevel DESC) RankNo
				,mbr.[ClientKey]
				,mbr.[ClientMemberKey]
				,mbr.[Contract]
  				,mbr.PlanName
				,mbr.[NPI] as AttribNPI
				,mbr.[PcpPracticeTIN] as AttribTIN
				,mbr.ProviderChapter
				,mbr.ClientRiskScore
				,mbr.ClientRiskScoreLevel
				,mbr.FirstName
				,mbr.LastName
				,mbr.CurrentAge
				,mbr.DOB
				,mbr.Gender
				,mbr.MemberHomeAddress
  				,mbr.MemberHomeAddress1
				,mbr.MemberHomeCity
				,mbr.MemberHomeState
				,mbr.MemberHomeZip
				,mbr.MemberPhone
				,concat(1,mbr.MemberCellPhone) as MemberCellPhone
				,mbr.MemberHomePhone
				,CASE WHEN YEAR(vis.PrimaryServiceDate) = YEAR(GETDATE()) THEN 'Y' ELSE 'N' END as CompliantStatus
				,CASE WHEN vis.AWVType = 'NonClaim' THEN 'Y' ELSE 'N' END as AddressedFlg
				,vis.PrimaryServiceDate AS LstAWVDate
				,CASE WHEN DOD = '1900-01-01' THEN 'N' ELSE 'Y' END AS Expired
				,Year(Getdate()) as SvcYear
				,vis.EffectiveAsOfDate		--
	FROM		adw.FctMembership mbr
	LEFT JOIN	CTE vis
	ON			vis.ClientMemberKey = mbr.ClientMemberKey
	AND			vis.ClientKey = mbr.ClientKey
	WHERE		'12-01-2020' BETWEEN mbr.RwEffectiveDate AND mbr.RwExpirationDate
	AND			Active = 1
