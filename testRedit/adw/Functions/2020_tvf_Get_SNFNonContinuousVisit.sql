
CREATE  FUNCTION [adw].[2020_tvf_Get_SNFNonContinuousVisit]
(
 @DaysElapse	      INT,			-- Days Elapse
 @PrimSvcDate_Start	DATE, 
 @PrimSvcDate_End		DATE
)
RETURNS TABLE
AS RETURN
(
	SELECT SUBSCRIBER_ID as ClientMemberKey, SEQ_CLAIM_ID as SeqClaimID, ADMISSION_DATE as AdmissionDate, SVC_TO_DATE as DischargeDate
		,PRIMARY_SVC_DATE as PrimaryServiceDate, ICD_PRIM_DIAG as PrimDx, BILL_TYPE as BillType
		,CASE WHEN SVC_TO_DATE = EOMONTH(SVC_TO_DATE) THEN 1 ELSE 0 END AS EOMFlg
		,row_number()over(partition BY SUBSCRIBER_ID ORDER BY PRIMARY_SVC_DATE) AS r
	FROM (SELECT b.*
		FROM adw.Claims_Headers b --[adw].[FctInpatientVisits] b 
		WHERE b.CLAIM_TYPE in ('20','30')
		and LEFT(b.Bill_Type,2) IN (21,18) 	---
		AND b.PRIMARY_SVC_DATE	>=  @PrimSvcDate_Start 
		AND b.SVC_TO_DATE			<=  @PrimSvcDate_End
		AND b.TOTAL_PAID_AMT		> 0
		) a 
	LEFT JOIN 
		(
		SELECT DISTINCT ClientMemberKey, SeqClaimID FROM (
		SELECT DISTINCT ClientMemberKey, FirstSeqClaimID as SeqClaimID FROM [adw].[2020_tvf_Get_SNFContinuousVisit]  (@DaysElapse ,@PrimSvcDate_Start, @PrimSvcDate_End)
		UNION
		SELECT DISTINCT ClientMemberKey, AssocClaimID as SeqClaimID FROM [adw].[2020_tvf_Get_SNFContinuousVisit]	 (@DaysElapse,@PrimSvcDate_Start, @PrimSvcDate_End)
			) d
		) c
	ON		a.SUBSCRIBER_ID			= c.ClientMemberKey
	AND	a.SEQ_CLAIM_ID				= c.SeqClaimID
	WHERE c.SeqClaimID IS NULL

)
/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_SNFNonContinuousVisit] (1,'06-01-2019','03-31-2020')
WHERE ClientMemberKey = '4X81V19CQ00'
--91484751567
ORDER BY ClientMemberKey, FirstSvcDate

***/


