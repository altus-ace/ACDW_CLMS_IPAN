
-- =============================================
-- Author:			Si Nguyen
-- Create date:	09/05/20
-- Description:	Get SNF Claims by Member 
-- =============================================
CREATE FUNCTION [adw].[2020_tvf_Get_SNFClaimsByMember]
	(
	 @DaysElapse	      INT,			-- Days Elapse
	 @PrimSvcDate_Start	DATE, 
	 @PrimSvcDate_End		DATE
	)
RETURNS TABLE 
AS
RETURN 
(
	--WITH cte AS (
	--SELECT SEQ_CLAIM_ID , SUBSCRIBER_ID , SVC_TO_DATE , ADMISSION_DATE 
	--	,PRIMARY_SVC_DATE 
	--	--,count(SEQ_CLAIM_ID)over(partition BY SUBSCRIBER_ID ORDER BY PRIMARY_SVC_DATE) AS c
	--	,row_number()over(partition BY SUBSCRIBER_ID ORDER BY PRIMARY_SVC_DATE) AS r
	--FROM (SELECT b.*
	--	FROM adw.Claims_Headers b --[adw].[FctInpatientVisits] b 
	--	WHERE b.CLAIM_TYPE in ('20','30')
	--	and LEFT(b.Bill_Type,1) = 2 	---
	--	AND b.PRIMARY_SVC_DATE	>= @PrimSvcDate_Start 
	--	AND b.SVC_TO_DATE			<= @PrimSvcDate_End
	--	) vw_tmp )

	WITH cte AS (
	SELECT ClientMemberKey , FirstSeqClaimID , FirstSvcDate , FirstDischDate , AssocClaimID, AssocAdmDate, AssocDischDate 
	  ,row_number()over(partition BY ClientMemberKey ORDER BY FirstSvcDate) AS Rnk
	FROM [adw].[2020_tvf_Get_SNFContinuousVisit] (1,'06-01-2019','03-31-2020')
	--WHERE YEAR(LstDischDate) = YEAR( @PrimSvcDate_End)
	)

	SELECT t2.ClientMemberKey as ClientMemberKey
		--,(SELECT a.PRIMARY_SVC_DATE FROM CTE a WHERE a.r = 1) as FirstPrimarySvcDate
		,(SELECT a.FirstSeqClaimID FROM CTE a WHERE a.ClientMemberKey = t2.ClientMemberKey AND a.Rnk = 1) as SeqClaimID
		,(SELECT a.FirstSvcDate FROM CTE a WHERE a.ClientMemberKey = t2.ClientMemberKey AND a.Rnk = 1) as FirstPrimarySvcDate
		,(SELECT MAX(a.FirstSvcDate) FROM CTE a WHERE a.ClientMemberKey = t2.ClientMemberKey) as LastPrimarySvcDate
		,(SELECT MAX(a.AssocDischDate) FROM CTE a WHERE a.ClientMemberKey = t2.ClientMemberKey) as LastSvcToDate
		--,COUNT(distinct t2.AssocClaimID) as CntAssocClaims
		--,ClaimIDs = RIGHT(STUFF(
  --           (SELECT '|' + t1.AssocClaimID
  --            FROM CTE t1
  --            WHERE t1.ClientMemberKey = t2.ClientMemberKey
  --            FOR XML PATH (''))
  --           , 1, 1, ''),100) 
	FROM CTE t2
	GROUP BY t2.ClientMemberKey
)

/***
Usage:
SELECT * ,(CASE WHEN cntAssocClaims > 1 THEN LEFT([ClaimIDs], CHARINDEX('|', [ClaimIDs])-1 ) ELSE [ClaimIDs] END) AS [FirstClaimID] 
	,(CASE WHEN cntAssocClaims > 1 THEN RIGHT([ClaimIDs], CHARINDEX('|', [ClaimIDs])-1 ) ELSE [ClaimIDs] END) AS [LastClaimID] 
FROM adw.[2020_tvf_Get_SNFClaimsByMember] (1,'01-01-2020','03-31-2020')
WHERE ClientMemberKey = '5WW8XV5WY35'
***/


