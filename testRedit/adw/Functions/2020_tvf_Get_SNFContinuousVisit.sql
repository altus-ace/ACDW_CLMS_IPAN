
CREATE  FUNCTION [adw].[2020_tvf_Get_SNFContinuousVisit]
(
 @DaysElapse	      INT,			-- Days Elapse
 @PrimSvcDate_Start	DATE, 
 @PrimSvcDate_End		DATE
)
RETURNS TABLE
AS RETURN
(
	WITH cte AS (
	SELECT vw_tmp.SEQ_CLAIM_ID as Seq_ClaimID, SUBSCRIBER_ID as ClientMemberKey, SVC_TO_DATE as DischargeDate, ADMISSION_DATE as AdmissionDate
		,PRIMARY_SVC_DATE as PrimaryServiceDate, ICD_PRIM_DIAG as PrimDx, BILL_TYPE as BillType
		,CASE WHEN SVC_TO_DATE = EOMONTH(SVC_TO_DATE) THEN 1 ELSE 0 END AS EOMFlg
		--,count(SEQ_CLAIM_ID)over(partition BY SUBSCRIBER_ID ORDER BY PRIMARY_SVC_DATE) AS c
		,row_number()over(partition BY SUBSCRIBER_ID ORDER BY PRIMARY_SVC_DATE) AS r
	FROM (SELECT b.*
		FROM adw.Claims_Headers b --[adw].[FctInpatientVisits] b 
		WHERE b.CLAIM_TYPE in ('20','30')
		and LEFT(b.Bill_Type,2) IN (21,18) 	---
		AND b.PRIMARY_SVC_DATE	>= @PrimSvcDate_Start 
		AND b.SVC_TO_DATE			<= @PrimSvcDate_End
		AND b.TOTAL_PAID_AMT		> 0
		) vw_tmp ) 

SELECT DISTINCT a.ClientMemberKey, a.Seq_ClaimID as FirstSeqClaimID
	,a.r as FirstR
	,a.PrimaryServiceDate	as FirstSvcDate 
	,a.DischargeDate			as FirstDischDate
	,a.EOMFlg					as FirstEOM
	,a.PrimDx					as PrimDx
	,b.EOMFlg					as AssocEOM
	,b.r							as LastR
	,b.Seq_ClaimID				as AssocClaimID
	,b.AdmissionDate			as AssocAdmDate
	,b.DischargeDate			as AssocDischDate
	,a.BillType					as	BillType
FROM CTE a
LEFT JOIN CTE b ON a.ClientMemberKey = b.ClientMemberKey 
AND a.Seq_ClaimID <> b.Seq_ClaimID 
AND a.PrimDx = b.PrimDx
AND ABS(DATEDIFF(day, a.DischargeDate, b.AdmissionDate)) <= @DaysElapse
AND a.DischargeDate <= b.AdmissionDate
AND a.EOMFlg = 1
WHERE b.ClientMemberKey IS NOT NULL

)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_SNFContinuousVisit] (1,'06-01-2019','03-31-2020')
WHERE ClientMemberKey = '4X81V19CQ00'
--91484751567
ORDER BY ClientMemberKey, FirstSvcDate
***/

