
CREATE  VIEW [adw].[vw_Exp_AhsPrograms] 
AS 
    /* get from SHCN */
    SELECT   
	    programs.CS_Export_LobName
	  , programs.PROGRAM_NAME
	  , CONVERT(date, programs.ENROLL_DATE, 23) AS  ENROLL_DATE
	  , CONVERT(date, programs.CREATE_DATE, 23) AS  CREATE_DATE
	  , programs.MEMBER_ID
	  , CONVERT(date, programs.ENROLL_END_DATE, 23) AS ENROLL_END_DATE
	  , programs.PROGRAM_STATUS
	  , programs.REASON_DESCRIPTION
	  , programs.REFERAL_TYPE
	  , programs.ClientKey
    FROM [adw].vw_Exp_QmPrograms programs
		LEFT JOIN (SELECT PR.ClientKey, PR.ClientMemberKey, PR.EnrollmentStartDate, PR.EnrollmentStopDate, PR.ProgramName
					FROM adw.MbrProgramEnrollments PR
					WHERE PR.EnrollmentStartDate < PR.EnrollmentStopDate) ProgEnr
			ON programs.MEMBER_ID = ProgEnr.ClientMemberKey
				AND programs.PROGRAM_NAME = ProgEnr.ProgramName				
				AND programs.ENROLL_DATE BETWEEN ProgEnr.EnrollmentStartDate and ProgEnr.EnrollmentStopDate
	WHERE ProgEnr.ProgramName is Null

    UNION ALL	   
    SELECT 
	   Client.CS_Export_LobName
	  , 'C-Annual Wellness Visit' PROGRAM_NAME /* THIS NEEDS TO BE ADDED TO THE mapCareOpToProgram table for SHCN */
	  , CONVERT(date, getdate(), 23) AS  ENROLL_DATE
	  , CONVERT(date, getDate(), 23) AS  CREATE_DATE
	  , AWV.ClientMemberKey AS MEMBER_ID
	  , CONVERT(date, DateFromParts(YEAR(getdate()), 12, 31), 23) AS ENROLL_END_DATE
	  , 'ACTIVE' PROGRAM_STATUS
	  , 'ACE Careopps' REASON_DESCRIPTION
	  , 'ACE Careopps' REFERAL_TYPE
	  , Client.ClientKey	   
    FROM adw.vw_Dashboard_CY_AWV_Needed AWV
	   JOIN lst.List_Client Client ON Awv.ClientKey = Client.ClientKey
	   LEFT JOIN (SELECT PR.ClientKey, PR.ClientMemberKey, PR.EnrollmentStartDate, PR.EnrollmentStopDate, PR.ProgramName
					FROM adw.MbrProgramEnrollments PR
					WHERE PR.ProgramName = 'C-Annual Wellness Visit'
						AND PR.EnrollmentStartDate < PR.EnrollmentStopDate
						) ProgEnr
			ON AWV.ClientMemberKey = ProgEnr.ClientMemberKey				
				AND CONVERT(date, getdate(), 23) BETWEEN ProgEnr.EnrollmentStartDate AND ProgEnr.EnrollmentStopDate
    WHERE ((AWV.[LstAWVDate] is null) OR (DateDiff(Month, AWV.LstAWVDate,  GETDATE()) >= 12 ))
