






CREATE FUNCTION [adw].[2020_tvf_Get_ERToIPAdmit]
(
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS @ErToIpAdmit TABLE
(
	ClientMemberKey			VARCHAR(50)
	,ClaimID_ER					VARCHAR(50)
	,ClaimID_IP					VARCHAR(50)
	,PrimSvcDate_ER				DATE
	,SvcToDate_ER				DATE
	,PrimSvcDate_IP				DATE
	,SvcToDate_IP				DATE
	,SvcDateDiff				INT
)
AS BEGIN

	WITH cte AS (
	SELECT SEQ_CLAIM_ID,SUBSCRIBER_ID,SVC_TO_DATE,PRIMARY_SVC_DATE,
		row_number()over(partition BY SUBSCRIBER_ID ORDER BY PRIMARY_SVC_DATE) AS r
	FROM (SELECT b.*
		FROM [adw].[2020_tvf_Get_ERVisits] (@PrimSvcDate_Start,@PrimSvcDate_End) b 
		) vw_tmp )
	INSERT INTO @ErToIpAdmit
	 (
	  ClientMemberKey		
	 ,ClaimID_ER				
	 ,ClaimID_IP				
	 ,PrimSvcDate_ER			
	 ,SvcToDate_ER			
	 ,PrimSvcDate_IP			
	 ,SvcToDate_IP			
	 ,SvcDateDiff
	 )

	SELECT DISTINCT														-- ER Rev Code found in different claim, but are 0,1 days apart from IP
		c1.SUBSCRIBER_ID AS ClientMemberKey, 
		c1.SEQ_CLAIM_ID AS SeqClaimID_ER, c2.SEQ_CLAIM_ID AS SeqClaimID_IP,
		c1.PRIMARY_SVC_DATE as PrimSvcDate_ER,
		c1.SVC_TO_DATE as [SvcToDate_ER],
		c2.PRIMARY_SVC_DATE as [PrimSvcDate_IP],
		c2.SVC_TO_DATE as [SvcToDate_IP],
		DATEDIFF(dd,c1.PRIMARY_SVC_DATE,c2.PRIMARY_SVC_DATE)
	FROM CTE c1
		INNER JOIN [adw].[2020_tvf_Get_IPVisits] (@PrimSvcDate_Start,@PrimSvcDate_End) c2 
		ON c1.SUBSCRIBER_ID=c2.SUBSCRIBER_ID
	WHERE c1.SEQ_CLAIM_ID<>c2.SEQ_CLAIM_ID
		--AND c1.PRIMARY_SVC_DATE BETWEEN c2.PRIMARY_SVC_DATE AND c2.SVC_TO_DATE
		AND DATEDIFF(dd,c1.PRIMARY_SVC_DATE,c2.PRIMARY_SVC_DATE) in (0,1)
		AND c2.CLAIM_TYPE IN ('60')
	union
	SELECT DISTINCT														-- ER Rev Code found in same claim as IP
		c1.SUBSCRIBER_ID AS ClientMemberKey, 
		c1.SEQ_CLAIM_ID AS SeqClaimID_ER, c2.SEQ_CLAIM_ID AS SeqClaimID_IP,
		c1.PRIMARY_SVC_DATE as PrimSvcDate_ER,
		c1.SVC_TO_DATE as [SvcToDate_ER],
		c2.PRIMARY_SVC_DATE as [PrimSvcDate_IP],
		c2.SVC_TO_DATE as [SvcToDate_IP],
		DATEDIFF(dd,c1.PRIMARY_SVC_DATE,c2.PRIMARY_SVC_DATE)
	FROM CTE c1
		INNER JOIN [adw].[2020_tvf_Get_IPVisits] (@PrimSvcDate_Start,@PrimSvcDate_End) c2 
		ON c1.SUBSCRIBER_ID=c2.SUBSCRIBER_ID
	WHERE c1.SEQ_CLAIM_ID=c2.SEQ_CLAIM_ID
		AND c2.CLAIM_TYPE IN ('60')

	RETURN;
END

/***
Usage: 
SELECT *
FROM adw.[2020_tvf_Get_ERToIPAdmit] ('01/01/2020','12/31/2020')
WHERE ClientMemberKey = '1AH9TX1MR00'

***/


