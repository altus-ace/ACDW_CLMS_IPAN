



CREATE PROCEDURE [adw].[CalcSNFVisits]
	(
	@ClientKeyID				VARCHAR(2),
	@RunDate						DATE,
	@KPIStartDate				DATE,
	@KPIEndDate					DATE,
	@MbrEffectiveDate			DATE
	)
AS    
BEGIN
    SET NOCOUNT ON;

--DECLARE	@ClientKeyID				VARCHAR(2)		= '16'
--DECLARE	@EffectiveAsOfDate		DATE				= '09-15-2020'
--DECLARE	@PrimarySvcDate_Start	DATE				= '06-01-2019'
--DECLARE	@PrimarySvcDate_End		DATE				= '05-31-2020'

SELECT DISTINCT a.SUBSCRIBER_ID
INTO #tmpAllSNFMbrs
	FROM adw.Claims_Headers a
	WHERE a.CLAIM_TYPE in ('20','30')
	AND LEFT(a.Bill_Type,2) IN (21,18) 	---
	AND a.PRIMARY_SVC_DATE	>= @KPIStartDate 
	AND a.SVC_TO_DATE			<= @KPIEndDate
	AND a.TOTAL_PAID_AMT		> 0
/*** Get all Claims 6 mths prior to Date Range ***/
SELECT SUBSCRIBER_ID as ClientMemberKey, SEQ_CLAIM_ID as SeqClaimID
		,PRIMARY_SVC_DATE as PrimaryServiceDate, ADMISSION_DATE as AdmissionDate, SVC_TO_DATE as DischargeDate, POST_DATE as PostDate
		,ICD_PRIM_DIAG, VEND_FULL_NAME, BILL_TYPE, ADMIT_SOURCE_CODE, TOTAL_PAID_AMT
INTO #tmpAllClaims
FROM adw.Claims_Headers a
WHERE a.SUBSCRIBER_ID IN (SELECT * FROM #tmpAllSNFMbrs)
AND   a.CLAIM_TYPE in ('20','30')
AND   LEFT(a.Bill_Type,2) IN (21,18) 	---
AND	a.PRIMARY_SVC_DATE	>= DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(M, -6,@KPIStartDate)), 0)
AND	a.SVC_TO_DATE			<= @KPIEndDate
AND	a.TOTAL_PAID_AMT		> 0

/*** Get Joined Claims ***/
SELECT * INTO #tmpCTE FROM (
	SELECT ClientMemberKey, FirstSeqClaimID, FirstR, FirstSvcDate, FirstDischDate
	FROM [adw].[2020_tvf_Get_SNFContinuousVisit] (1,DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(M, -6,@KPIStartDate)), 0),@KPIEndDate) m
	WHERE m.BillType NOT IN ('213','223')
	UNION ALL
	SELECT ClientMemberKey, AssocClaimID, LastR, AssocAdmDate, AssocDischDate
	FROM [adw].[2020_tvf_Get_SNFContinuousVisit] (1,DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(M, -6,@KPIStartDate)), 0),@KPIEndDate) n
	WHERE n.BillType NOT IN ('213','223')
) tmp

SELECT a.ClientMemberKey, a.FirstSeqClaimID, a.FirstSvcDate, a.FirstDischDate
		,b.FirstSeqClaimID AS LastSeqClaimID, b.FirstSvcDate AS LastAdmDate, b.FirstDischDate AS LastDischDate
	INTO #tmpJoinedClaims 
	FROM (SELECT ClientMemberKey, FirstSeqClaimID, FirstSvcDate, FirstDischDate,
               ROW_NUMBER() OVER (PARTITION BY ClientMemberKey ORDER BY FirstR ASC) rank
          FROM #tmpCTE) a
	LEFT JOIN (SELECT ClientMemberKey, FirstSeqClaimID, FirstSvcDate, FirstDischDate,
               ROW_NUMBER() OVER (PARTITION BY ClientMemberKey ORDER BY FirstR DESC) rank
          FROM #tmpCTE) b
	ON a.ClientMemberKey = b.ClientMemberKey
	AND b.rank = 1
WHERE a.rank = 1 
AND YEAR(b.FirstDischDate) = YEAR(@KPIEndDate)

/*** Get UnJoined Claims ***/
SELECT * INTO #tmpUnJoinedClaims 
FROM [adw].[2020_tvf_Get_SNFNonContinuousVisit] (1,DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(M, -6,@KPIStartDate)), 0),@KPIEndDate) 
WHERE year(DischargeDate) = YEAR(@KPIEndDate)

/*** Calculate SNF Visits ***/
SELECT JType, a.ClientMemberKey, a.FirstSeqClaimID, a.AdmitDate, a.DischargeDate
	, e.ClientMemberKey as DupClientMemberKey, e.FirstSeqClaimID as DupSeqClaimID
INTO #tmpFinal
FROM 
	(SELECT 'J' as JType,ClientMemberKey, FirstSeqClaimID, FirstSvcDate as AdmitDate,LastDischDate as DischargeDate
	 FROM #tmpJoinedClaims
	 UNION
	 SELECT 'N' as JType,ClientMemberKey, SeqClaimID, AdmissionDate as AdmitDate,DischargeDate as DischargeDate
	 FROM #tmpUnJoinedClaims
	 ) a
LEFT JOIN #tmpCTE e
	ON  a.ClientMemberKey			= e.ClientMemberKey
	AND a.FirstSeqClaimID			= e.FirstSeqClaimID
END;												

/***Update fctInpatientVisits ***/
UPDATE adw.FctInpatientVisits
		SET InstType = 'SNF1'
		FROM  adw.FctInpatientVisits a, (
			SELECT ClientMemberKey, FirstSeqClaimID
			FROM #tmpFinal
		) b
		WHERE a.ClientMemberKey = b.ClientMemberKey 
		AND a.SEQ_ClaimID = b.FirstSeqClaimID
		AND a.EffectiveAsOfDate = @RunDate

/***
EXEC [adw].[CalcSNFVisits] 16,'09-15-2020','01-01-2020','06-30-2020'
***/

