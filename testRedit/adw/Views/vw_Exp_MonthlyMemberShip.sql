
CREATE VIEW [adw].[vw_Exp_MonthlyMemberShip]

AS


	SELECT DISTINCT 
				[MemberMonth], 
				tam.[CLientKey], 
				cl.ClientShortName AS ClientName, 
				[PCP_PRACTICE_TIN] AS AttribTin, 
				[PCP_PRACTICE_NAME] AS AttribTINName, 
				[PCP_NPI] AS AttribNPI, 
				pr.FirstName AS AttribNPIFirstName, 
				pr.LastName AS AttribNPILastName, 
				pr.AccountType AS PCPAffiliation, 
				tam.[ClientMemberKey] AS PatientID, 
				[MEMBER_FIRST_NAME] AS MemberFirstName, 
				'' AS MemberMiddleInitial, 
				[MEMBER_LAST_NAME] AS MemberLastName, 
				[GENDER] AS MemberGender, 
				[DATE_OF_BIRTH] AS MemberBirthDate, 
				[MEMBER_HOME_ADDRESS] AS MemberAddressLine1, 
				[MEMBER_HOME_ADDRESS2] AS MemberAddressLine2, 
				[MEMBER_HOME_CITY] AS MemberCity, 
				[MEMBER_HOME_STATE] AS MemberState, 
				[MEMBER_HOME_ZIP] AS MemberZIP, 
				MEMBER_HOME_PHONE AS MemberPhone, 
				[LOB], 
				[PLAN_CODE] AS PlanName, 
				[SUBGRP_NAME] AS SubgrpName --- SELECT DISTINCT ACCOUNTTYPE
	FROM		(SELECT *
					FROM [ACECAREDW].[dbo].[TmpAllMemberMonths] tmp
					WHERE	CLientKey = (SELECT CLientKey FROM lst.List_Client)
					AND		MemberMonth = (SELECT MAX(MemberMonth) 
											FROM [ACECAREDW].[dbo].[TmpAllMemberMonths]
											WHERE CLientKey = (SELECT CLientKey FROM lst.List_Client)
										  )
				) tam
	LEFT JOIN	adw.tvf_AllClient_ProviderRoster((SELECT CLientKey FROM lst.List_Client)
															  , (SELECT CONVERT(DATE,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)))
															  , 1) pr 
	ON			tam.CLientKey = pr.ClientKey
	AND			tam.PCP_NPI = pr.NPI
    LEFT JOIN	AceMasterData.[lst].[List_Client] cl 
	ON			tam.CLientKey = cl.clientkey
	WHERE		pr.AccountType IN ('SHCN_AFF','SHCN_SMG')

