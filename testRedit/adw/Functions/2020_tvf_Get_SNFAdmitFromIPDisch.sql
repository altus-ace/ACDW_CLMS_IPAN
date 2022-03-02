






CREATE  FUNCTION [adw].[2020_tvf_Get_SNFAdmitFromIPDisch]
(
 @EffectiveAsOfDate	DATE,
 @DaysElapse	      INT,			-- Days Elapse
 @PrimSvcDate_Start VARCHAR(20), 
 @PrimSvcDate_End   VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
--WITH CTE AS (
--SELECT b.ClientMemberKey, SEQ_ClaimID, PrimaryServiceDate, DischargeDate, BillType
--	,row_number()over(partition BY ClientMemberKey ORDER BY PrimaryServiceDate) AS r
--	FROM [adw].[FctInpatientVisits] b 
--		WHERE b.ClaimType in ('60')
--		AND b.EffectiveAsOfDate = @EffectiveAsOfDate
--		AND b.InstType IN ('ACUTE')	
--		AND b.DischargeDisposition IN ('03')
--		AND b.ObvFlag = 0
--		AND b.LOS >= 3
--		AND b.PrimaryServiceDate BETWEEN @PrimSvcDate_Start AND  @PrimSvcDate_End
--)	
SELECT DISTINCT b.ClientMemberKey, b.SEQ_ClaimID as SNFClaimID, b.PrimaryServiceDate as SNFAdmDate, b.DischargeDate as SNFDischDate, b.LOS as SNFLos
	,b.AttribNPI, b.AttribTIN, b.BillType as SNFBillType
	--,a.SEQ_ClaimID as IPClaimID
	--,a.PrimaryServiceDate as IPAdmit, a.DischargeDate as IPDisch, DATEDIFF(dd,a.PrimaryServiceDate,a.DischargeDate) as IPLos
FROM [adw].[FctInpatientVisits] b 
--INNER JOIN CTE a ON a.ClientMemberKey=b.ClientMemberKey
--WHERE a.Seq_ClaimID<>b.Seq_ClaimID
	WHERE b.EffectiveAsOfDate = @EffectiveAsOfDate
	--AND b.PrimaryServiceDate BETWEEN a.DischargeDate AND dateadd(d,@DaysElapse,a.DischargeDate )
	AND b.ClaimType in ('20','30') 
	AND b.InstType IN ('SNF')	
	--AND b.BillType IN ('211','181')  -- Admit Thorough Discharge	
	--AND b.ObvFlag = 0
	AND b.PrimaryServiceDate >=  @PrimSvcDate_Start 
	AND b.DischargeDate		 <=  @PrimSvcDate_End
	
)

/***
Usage: 
SELECT *--YEAR(SNFDischDate), Month(SNFDischDate), Sum(SNFLos)
FROM adw.[2020_tvf_Get_SNFAdmitFromIPDisch] ('08-15-2020',30,'01/01/2020','05/30/2020')
***/

--SELECT b.ClientMemberKey, b.SEQ_ClaimID, b.*
--FROM [adw].[FctInpatientVisits] b 
--LEFT JOIN (
--				SELECT ClientMemberKey, SNFClaimID
--				FROM adw.[2020_tvf_Get_SNFAdmitFromIPDisch] ('08-15-2020',30,'01/01/2020','05/30/2020')
--				) a
--ON b.ClientMemberKey =	a.ClientMemberKey 
--AND b.SEQ_ClaimID		=  a.SNFClaimID
--WHERE b.EffectiveAsOfDate =  '08-15-2020' -- @EffectiveAsOfDate
--	AND b.ClaimType in ('20','30')
--	AND b.InstType IN ('SNF')	
--	AND b.ObvFlag = 0
--	AND b.PrimaryServiceDate BETWEEN '01/01/2020' and '05/30/2020' ---@PrimSvcDate_Start AND  @PrimSvcDate_End
--	AND a.ClientMemberKey IS NULL

--SELECT *
--FROM adw.Claims_Headers
--WHERE SUBSCRIBER_ID = '5VD5AH0QX59'
--AND CATEGORY_OF_SVC NOT IN ('PHARMACY','PHYSICIAN','outpatient')
--ORDER BY PRIMARY_SVC_DATE DESC
