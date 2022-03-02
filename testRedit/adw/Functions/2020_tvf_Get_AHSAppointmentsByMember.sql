-- =============================================
-- Author:		Si Nguyen
-- Create date: 10/16/19
-- Description:	Get Appointments By Member from Altruista
-- =============================================
/***

***/
-- FUNCTION [adw].[2020_tvf_Get_AHSAppointmentsByMember]
CREATE FUNCTION [adw].[2020_tvf_Get_AHSAppointmentsByMember]
	(	
		@ClientKey			INT,
		@PastActivityMonth	INT
	)
RETURNS TABLE 
AS
RETURN 
(
	WITH CTE AS (
	SELECT  b.[MbrAppointmentKey]						as TblKey
		,b.ClientMemberKey										as MemberID
		,convert(DATE, b.AppointmentDate)						as ApptDate
		,convert(DATE, b.AppointmentCreatedDate)				as CreateDate
		,AppointmentStatus+'('+convert(varchar, b.AppointmentDate, 1)+')'			as ApptStatus
	FROM [adw].[MbrAppointments] b
	WHERE DATEDIFF(mm,b.AppointmentCreatedDate,GETDATE()) <= @PastActivityMonth
	--AND AppointmentStatus = 'Scheduled'
)

	SELECT t2.MemberID
		,(SELECT MIN(a.ApptDate) FROM CTE a WHERE a.MemberID = t2.MemberID) as FirstApptDate
		,(SELECT MAX(a.ApptDate) FROM CTE a WHERE a.MemberID = t2.MemberID) as LastApptDate
		,(SELECT MAX(a.CreateDate) FROM CTE a WHERE a.MemberID = t2.MemberID) as CreateDate
		,COUNT(*) as CntAppt
		,ApptType = RIGHT(STUFF(
             (SELECT ' -- ' + t1.ApptStatus
              FROM CTE t1
              WHERE t1.MemberID = t2.MemberID
              FOR XML PATH (''))
             , 1, 1, ''),100) 
	FROM CTE t2
	GROUP BY t2.MemberID
)

/***
Usage:
SELECT * FROM [adw].[2020_tvf_Get_AHSAppointmentsByMember] (16,12)
WHERE ApptType LIKE '%Scheduled%'
***/


