





CREATE VIEW [adw].[vw_Exp_GHH_MSSPMembership]

AS
/* Purpose: Gets all Active members with MPI/Ace ID for Export to 3rd parties 
			 Used by GHH Export file creation ETL: Ghh-Exp-ActiveMembers.dtsx

			 */  
			 
			 
    SELECT DISTINCT 
	fctMbr.Ace_ID AS AceID,
	fctMbr.LastName AS LAST_NAME,
	fctMbr.FirstName AS FIRST_NAME,
	fctMbr.MiddleName AS MIDDLE_NAME,
	fctMbr.Gender AS GENDER,
	CONVERT(VARCHAR(8), fctMbr.DOB, 112) AS DATE_OF_BIRTH,    
	''	AS SSN ,
	fctMbr.MemberHomeAddress AS MEMBER_HOME_ADDRESS,
	fctMbr.MemberHomeAddress1 AS MEMBER_HOME_ADDRESS2,
	fctMbr.MemberHomeCity AS MEMBER_HOME_CITY,
	fctMbr.MemberHomeState AS MEMBER_HOME_STATE,
	fctMbr.MemberHomeZip AS MEMBER_HOME_ZIP,
	fctMbr.MemberHomePhone AS Member_Home_Phone,
	CONVERT(VARCHAR(8), DATEADD(DAY, -45, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()) , 1)),112) MinEligDate, 
    CONVERT(VARCHAR(8), DATEADD(MONTH, 6, DATEADD(Day, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()) , 1))),112) MinExpDate,
	fctMbr.ClientMemberKey AS ClientMemberKey	,
	fctMbr.ClientKey 
	FROM adw.vw_Dashboard_Membership fctMbr
	WHERE fctmbr.active = 1
	AND DOD = '1900-01-01'
	AND FctMbr.ProviderPOD <> 'Greater Odessa'

