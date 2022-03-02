
-- =============================================
-- Author:			Si Nguyen
-- Create date:	10/16/19
-- Description:	Get Activities by Member from Altruista
-- Modified:		08/05/21 Changed from input paramters, @PastActivityMonth
--						WHERE (mm,b.ActivityCreatedDate, getdate()) <= @PastActivityMonth
-- =============================================
CREATE FUNCTION [adw].[2020_tvf_Get_CMScoreByMember]
	(	
		@ClientKey				INT,
		@ActivityDate_Start	DATE,
		@ActivityDate_End		DATE
	)
RETURNS TABLE 
AS
RETURN 
(
	WITH CTE AS (
	SELECT  DISTINCT
		b.[ClientMemberKey]					as MemberID
		,convert(DATE, b.ActivityCreatedDate)	as ActDate
		,CareActivityTypeName				as Activity
		,ActivityOutcome						as ActivityOutcome
		,CASE ActivityOutcome	WHEN 'Left a Message'					THEN	.5
										WHEN 'Barrier Physician Workflow'	THEN	1
										WHEN 'Educational Materials Sent'	THEN	2
										WHEN 'Fax Sent'							THEN	2
										WHEN 'Letter Sent'						THEN	2
										WHEN 'Appointment Scheduled'			THEN	3
										WHEN 'Cancellation'						THEN	3
										WHEN 'Acknowledged'						THEN	2
										WHEN 'Appointment no show'				THEN	4
										WHEN 'Attended'							THEN	4
										WHEN 'Rescheduled'						THEN	4
										WHEN 'Appointment Attendance Confirmed'	THEN	5
										WHEN 'Appointment Completed'			THEN	5
										WHEN 'Refused'								THEN	-3
										WHEN 'Disconnected Number'				THEN	-2
			ELSE 0 END As UnitScore	
		,1 as Qty
	FROM [adw].[mbrActivities] b
	WHERE b.ActivityCreatedDate BETWEEN @ActivityDate_Start AND @ActivityDate_End
	AND ActivityOutcome NOT IN (
			'Data Found'
			,'MDB'
			,'Member Termed'
			,'MSSP Refusal Letter'
			,'NA'
			,'No Contact Information Available'
			,'No Data Available'
			,'Other'
			,'Unable to Reach' 
			,'Update Member Demographics'
			,'WN'
			,'Completed'
			,'Acknowledged'
	)
)
SELECT MemberID, SUM(UnitScore * Qty) as TotScore
	FROM CTE t2
	GROUP BY t2.MemberID
)

/***
Usage:
SELECT * FROM [adw].[2020_tvf_Get_CMScoreByMember] (16,'01-01-2021','03-01-2021')
***/


