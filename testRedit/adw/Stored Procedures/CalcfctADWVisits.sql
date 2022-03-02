



CREATE PROCEDURE [adw].[CalcfctADWVisits]
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

DECLARE @PrevYearDate_Start	DATE = DATEADD(DD,-DATEPART(DY,DATEADD(year, -1, @KPIStartDate))+1,DATEADD(year, -1, @KPIStartDate))
DECLARE @PrevYearDate_End		DATE = @KPIEndDate	--DATEADD(DD,-1,DATEADD(YY,DATEDIFF(YY,0,@KPIStartDate)+1,0))
DECLARE @CodeSetDate				DATE = @KPIStartDate

IF OBJECT_ID(N'tempdb..#tmpAWVVisits') IS NOT NULL DROP TABLE #tmpAWVVisits
CREATE TABLE #tmpAWVVisits (
	 CatGrp					VARCHAR(10)
	,QMDate					DATE
	,ClientKey				VARCHAR(2)
	,PrimSvcDate			DATE
	,QMMsrID					VARCHAR(50)
	,QmCntCat				VARCHAR(50)
	,ClientMemberKey		VARCHAR(50)
	,SeqClaimID				VARCHAR(50)
	,AddressedFlg			INT
	,AWV_CODE				VARCHAR(20)
	,AWV_TYPE				VARCHAR(30)
	)
INSERT INTO #tmpAWVVisits
-- Population of Members that AWV has either been captured through a claim or addressed by emr data
SELECT * FROM (
-- From QM_ResultByValueCodeDetails_History, to get AWV_CODE & AWV_TYPE
SELECT 'Claims' as CatGrp, b.QmDate, b.ClientKey, b.valueCodePrimarySvcDate as PrimSvcDate, b.QMMsrID, b.QMCntCat, b.ClientMemberKey, b.SEQ_CLAIM_ID, a.Addressed, b.ValueCode as AWV_CODE
  ,CASE	WHEN b.ValueCode = 'G0438' THEN 'Initial'
			WHEN b.ValueCode = 'G0439' THEN 'Subsequent'
			WHEN b.ValueCode = 'G0402' THEN 'Welcome'
			WHEN b.ValueCode = 'G0468' THEN 'FQHC AWV'
			ELSE 'Other' END AS AWV_TYPE
FROM [adw].[QM_ResultByValueCodeDetails_History] b 
JOIN adw.QM_ResultByMember_History a
	ON		b.ClientMemberKey		= a.ClientMemberKey
	AND	b.QmMsrID				= a.QmMsrId
	AND	b.QmCntCat				= a.QmCntCat
	AND	b.QMDate					= a.QMDate
	AND	b.QmCntCat = 'NUM'
WHERE		b.QmMsrID LIKE '%ACE%AWV%'
	AND	b.QmDate = @MbrEffectiveDate --@RunDate
UNION
-- From QM_ResultByMember_History, to get AddressFlag, and default in AWV_CODE & AWV_TYPE
SELECT 'NonClaims' as CatGrp, a.QmDate, a.ClientKey, b.AddressedDate as PrimSvcDate, a.QMMsrID, a.QMCntCat, a.ClientMemberKey, 'ExtSrc', a.Addressed, 'ExtSrc' as AWV_CODE, 'NonClaim' as AWV_TYPE
FROM adw.QM_ResultByMember_History a  
JOIN adw.QM_Addressed b
	ON  a.ClientMemberKey		= b.ClientMemberKey
	AND a.QmDate					= b.QMDate
	AND a.QmMsrId					= b.QmMsrId
WHERE		a.QmMsrID LIKE '%ACE%AWV%'
	AND	a.QmDate = @MbrEffectiveDate --@RunDate
	AND	a.QmCntCat = 'COP'
	AND	a.Addressed = 1
	) m

INSERT INTO [adw].[FctAWVVisits]
         (
          [SrcFileName]
         ,[LoadDate]
         ,[DataDate]
         ,[ClientKey]
         ,[ClientMemberKey]
         ,[EffectiveAsOfDate]
         ,[ClaimID]
         ,[PrimaryServiceDate]
		   ,[AWVType]
		   ,[AWVCode]
         ,[SVCProviderNPI]
         ,[SVCProviderName]
         ,[SVCProviderSpecialty]
		   ,[AttribNPI]
		   ,[AttribTIN])

SELECT  CONCAT('[adw].[CalcfctAWVVisits] ',@KPIStartDate,'-',@KPIEndDate) as [SrcFileName]
	,GETDATE()						as [LoadDate]
	,@RunDate						as DataDate
	,t.ClientKey
	,t.ClientMemberKey
	,@RunDate						as EffectiveAsOfDate
	,t.SeqClaimID
	,t.PrimSvcDate					-- From Claims (tvf_Get_AWVisits) and Addressed (AddressedDate)
	,t.AWV_TYPE
	,t.AWV_CODE
	,c.SVC_PROV_NPI
	,svcnpi.LegalBusinessName	as LBN
	,c.PROV_SPEC
	,a.NPI							AS AttribNPI
	,a.PcpPracticeTIN				AS AttribTIN
	--,t.AddressedFlg AS tAddress
FROM #tmpAWVVisits	t
-- Claims based AWV 
LEFT JOIN  [adw].[2020_tvf_Get_AWVisits]	(@PrevYearDate_Start,@PrevYearDate_End,@MbrEffectiveDate) c --@RunDate) c
	ON		t.ClientMemberKey		= c.SUBSCRIBER_ID
	AND	t.SeqClaimID			= c.SEQ_CLAIM_ID
-- Current Membership
LEFT JOIN  [adw].[2020_tvf_Get_ActiveMembersFull]	(@MbrEffectiveDate) a
	ON		t.ClientKey				= a.ClientKey
	AND	t.ClientMemberKey		= a.ClientMemberKey
-- Update Service Name
LEFT JOIN adw.[2020_tvf_Get_DataFromNPPES] (@MbrEffectiveDate) svcnpi
	ON c.SVC_PROV_NPI = svcnpi.NPI

WAITFOR DELAY '00:00:02';
IF OBJECT_ID(N'tempdb..#tmpCurAWV') IS NOT NULL 	DROP TABLE #tmpCurAWV ;
IF OBJECT_ID(N'tempdb..#tmpFinal') IS NOT NULL 	DROP TABLE #tmpFinal ;

BEGIN
SELECT * INTO #tmpCurAWV FROM (
SELECT EffectiveAsOfDate, ClientMemberKey, PrimaryServiceDate
	, ROW_NUMBER() OVER (PARTITION BY EffectiveAsOfDate, ClientMemberKey ORDER BY PrimaryServiceDate desc) as rn
FROM [adw].[FctAWVVisits] WHERE EffectiveAsOfDate =  @RunDate
) a WHERE rn = 1

SELECT * INTO #tmpFinal FROM (
SELECT a.*
	, b.PRIMARY_SVC_DATE as LstAWVDate
	, b.SVC_PROV_NPI as LstSvcNPI
	, ROW_NUMBER() OVER (PARTITION BY a.ClientMemberKey ORDER BY b.PRIMARY_SVC_DATE desc) as rnL
	FROM #tmpCurAWV a
	LEFT JOIN (SELECT DISTINCT SUBSCRIBER_ID, PRIMARY_SVC_DATE, SVC_PROV_NPI FROM  [adw].[2020_tvf_Get_AWVisits]	(@PrevYearDate_Start,@PrevYearDate_End,@MbrEffectiveDate)) b
		ON		a.ClientMemberKey		= b.SUBSCRIBER_ID
		AND	a.PrimaryServiceDate > b.PRIMARY_SVC_DATE
) b WHERE rnL = 1
END

BEGIN	
UPDATE [adw].[FctAWVVisits]
	SET 
		LastAWVDate = lstawv.LstAWVDate,
		LastAWVNPI =  lstawv. LstSvcNPI
	FROM [adw].[FctAWVVisits] a, #tmpFinal lstawv
	WHERE a.ClientMemberKey = lstawv.ClientMemberKey
	AND a.EffectiveAsOfDate = @RunDate
END

--WAITFOR DELAY '00:00:02'; 
--UPDATE [adw].[FctAWVVisits]
--	SET LastAWVKey =  lstawv.FctAWVVisitsSkey,
--		LastAWVDate = lstawv.PrimaryServiceDate,
--		LastAWVNPI =  lstawv.SVCProviderNPI
--	FROM [adw].[FctAWVVisits] a, (SELECT ClientMemberKey, FctAWVVisitsSkey, PrimaryServiceDate, SVCProviderNPI FROM [adw].[2020_tvf_Get_MembersLastAWVisit] (@MbrEffectiveDate)) lstawv
--	WHERE a.ClientMemberKey = lstawv.ClientMemberKey
	
END;												

/***
EXEC [adw].[CalcfctADWVisits] 25,'02-15-2022','01-01-2020','07-31-2021','07-15-2021'

SELECT * --DISTINCT(ClientMemberKey) as DstMbr--, PrimaryServiceDate
FROM [adw].[FctAWVVisits]
WHERE EffectiveAsOfDate = '02-15-2022'

***/












