

CREATE PROCEDURE [adw].[LoadQmResultHistoryIntoQmResultCL]
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate		DATE
	)
AS

BEGIN
TRUNCATE TABLE adw.QM_ResultByMember_CL;
INSERT INTO adw.QM_ResultByMember_CL(
		[ClientMemberKey]
		, [QmMsrId]
		, [QmCntCat]
		, [QMDate])

SELECT	[ClientMemberKey]
		, [QmMsrId]
		, [QmCntCat]
		, [QMDate]	
FROM	adw.QM_ResultByMember_History
WHERE	QMDate = @RunDate


END

/***
EXEC [adw].[LoadQmResultHistoryIntoQmResultCL] '16','2021-03-15'
***/
