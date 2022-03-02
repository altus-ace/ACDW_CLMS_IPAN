

CREATE view [adw].[vw_Exp_Ahs_MbrHighRiskProgram] 
AS 
     SELECT Client.CS_Export_LobName		   AS Client_ID
	   , CONVERT(NVARCHAR(1000), 'MSSP High Risk Program') PROGRAM_NAME	   
	   , CONVERT(VARCHAR(10), dateadd(day, -1*day(CONVERT(DATE, fMbr.LoadDate, 101))+1,CONVERT(DATE,fMbr.LoadDate, 101)),23) AS ENROLL_DATE 			 
	   , CONVERT(VARCHAR(10), fMbr.LoadDate, 23)  AS CREATE_DATE	   	   
	   , CONVERT(NVARCHAR, fMbr.ClientMemberKey) AS MEMBER_ID
	   , CONVERT(VARCHAR(10), dateAdd(Day, 90, dateadd(day, -1*day(CONVERT(DATE, fMbr.LoadDate, 101))+1,CONVERT(DATE,fMbr.LoadDate, 101))),23) AS ENROLL_END_DATE 
	   , 'ACTIVE' AS PROGRAM_STATUS
	   , 'Enrolled in a Program' AS REASON_DESCRIPTION
	   , 'MSSP High Risk Program' AS REFERAL_TYPE 	   
	   , Client.ClientKey        
    FROM adw.fctMembership fMbr 
	   JOIN lst.List_Client Client ON fmbr.ClientKey = client.ClientKey
	   LEFT JOIN (SELECT mbr.ClientMemberKey, mbr.ProgramName
				FROM adw.MbrProgramEnrollments mbr
				WHERE mbr.ProgramName = 'MSSP High Risk Program'
				GROUP BY mbr.ClientMemberKey, mbr.ProgramName) AhsPrograms
			 ON fmbr.ClientMemberKey = AhsPrograms.ClientMemberKey	   
    WHERE '05/01/2020' BETWEEN fmbr.RwEffectiveDate and fMbr.RwExpirationDate
	   AND fmbr.ClientRiskScoreLevel = 1.00
	   AND AhsPrograms.ClientMemberKey is null
	   ;
