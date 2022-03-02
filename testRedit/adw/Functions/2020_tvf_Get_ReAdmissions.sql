
CREATE  FUNCTION [adw].[2020_tvf_Get_ReAdmissions]
(
 @DaysElapse	      INT,			-- Days Elapse
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
	WITH cte AS (
	SELECT Seq_ClaimID,ClientMemberKey,DischargeDate,AdmissionDate,PrimaryServiceDate,
		row_number()over(partition BY ClientMemberKey ORDER BY AdmissionDate) AS r
	FROM (SELECT b.*
		FROM [adw].[FctInpatientVisits] b 
		WHERE b.ClaimType in ('60','61')
		AND b.InstType IN ('ACUTE')
		AND b.ObvFlag = 0
		AND b.PrimaryServiceDate BETWEEN  @PrimSvcDate_Start AND  @PrimSvcDate_End
		) vw_tmp )

	SELECT
		c1.Seq_ClaimID AS SeqClaimID1, c2.Seq_ClaimID AS SeqClaimID2,
		c1.ClientMemberKey, 
		c1.PrimaryServiceDate,
		c1.DischargeDate as [DischargeDate1],
		c2.AdmissionDate as [AdmitDate2]
	FROM cte c1
		INNER JOIN cte c2 ON c1.ClientMemberKey=c2.ClientMemberKey
	WHERE c1.Seq_ClaimID<>c2.Seq_ClaimID
		AND c1.r+1=c2.r
		AND c2.AdmissionDate BETWEEN c1.DischargeDate AND dateadd(d,@DaysElapse,c1.DischargeDate )
	--ORDER BY c1.ClientMemberKey
)

/***
Usage: 
SELECT DISTINCT *
FROM [adw].[2020_tvf_Get_ReAdmissions] (30,'01/01/2019','12/31/2020')
WHERE ClientMemberKey = '1AH9TX1MR00'

***/
