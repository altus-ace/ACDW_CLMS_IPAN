/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */






CREATE PROCEDURE [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_Phy] 
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate		DATE
	)
AS
BEGIN

	SET NOCOUNT ON;

IF OBJECT_ID('[dbo].[tmp_AHR_HL7_Report_Detail_Phy]', 'U') IS NOT NULL 
  DROP TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Phy]; 

CREATE TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Phy](
	[IP_ID] [int] IDENTITY(4000,1) NOT NULL,
	[ClientKey]			[int] NULL,
	[ClientMemberKey]	[varchar](50) NULL,
	[PrimaryServiceDate] [date] NULL,
	[ProviderNPI]		[varchar](10) NULL,
	[ProviderSpecialty] [varchar](50) NULL,
	[PrimaryDiagnosis]	[varchar](100) NULL,
	[VisitType]			[varchar](50) NULL,
	[AttribNPI]			[varchar](10) NULL,
	[AttribTIN]			[varchar](10) NULL,
	[LOADDATE] [date] NULL,
	[LOADEDBY] [varchar](50) NULL
)

ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Phy] ADD  DEFAULT (sysdatetime()) FOR [LOADDATE]

ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Phy] ADD  DEFAULT (suser_sname()) FOR [LOADEDBY]

DECLARE @BeginDate [DATE] = ( SELECT CAST(DATEADD(YEAR, -1, @RunDate) AS DATE) )
DECLARE @EndDate [DATE] = ( SELECT CONVERT (DATE, @RunDate) ) 

INSERT INTO [dbo].[tmp_AHR_HL7_Report_Detail_Phy](
		[ClientKey]			
		,[ClientMemberKey]	
		,[PrimaryServiceDate]
		,[ProviderNPI]		
		,[ProviderSpecialty] 
		,[PrimaryDiagnosis]	
		,[VisitType]		
		,[AttribNPI]			
		,[AttribTIN]			
	)

SELECT DISTINCT
       a.[ClientKey]
      ,a.[ClientMemberKey]
      ,a.[PrimaryServiceDate]
      --,a.[EffectiveAsOfDate]
	  ,a.SVCProviderNPI
      ,CONCAT(a.[SVCProviderSpecialty],' ',LEFT(b.CodeDesc,35))
      ,CASE WHEN a.PrimaryDiagnosis = '' OR a.PrimaryDiagnosis IS NULL
			THEN CONCAT(c.[PrimaryDiagCode],' ',LEFT(c.[PrimaryDiagDescription],75)) ELSE a.PrimaryDiagnosis END 
	  ,LEFT(a.VisitExamType,49)
	  ,a.AttribNPI
	  ,a.AttribTIN
  FROM [adw].[FctPhysicianVisits] a
  LEFT JOIN [adw].[2020_tvf_Get_PrimarySecondaryDiagCode] ('0','0',@BeginDate) c
		ON a.[ClientMemberKey] = c.ClientMemberKey
		AND a.[SEQ_ClaimID] = c.SeqClaimID
  LEFT JOIN lst.LIST_PROV_SPECIALTY_CODES b 
		ON a.[SVCProviderSpecialty] = b.Code
  WHERE  a.[PrimaryServiceDate] BETWEEN @BeginDate AND @EndDate
  AND  a.[PrimaryServiceDate] BETWEEN b.EffectiveDate AND b.ExpirationDate 
  AND a.EffectiveAsOfDate = (SELECT MAX(EffectiveAsOfDate) FROM [adw].[FctPhysicianVisits])

--SELECT DISTINCT 
--		 @ClientKeyID
--		,a.SUBSCRIBER_ID
--		,a.PRIMARY_SVC_DATE
--		,a.[SVC_PROV_NPI]
--		,a.[PROV_SPEC]
--		,CONCAT(c.PrimaryDiagCode,' ',LEFT(c.PrimaryDiagDescription,75))
--		,LEFT(d.VisitExamType,50)
--		,b.AttribNPI					
--		,b.AttribTIN					
--FROM [adw].[2020_tvf_Get_PhyVisits] (@BeginDate,@EndDate) a
--JOIN dbo.tmp_AHR_HL7_Population b 
--ON b.SUBSCRIBER_ID = a.SUBSCRIBER_ID             
--LEFT JOIN [adw].[2020_tvf_GetPrimarySecondaryDiagCode] ('0','0') c
--		ON a.SUBSCRIBER_ID = c.ClientMemberKey
--		AND a.SEQ_CLAIM_ID = c.SeqClaimID
--LEFT JOIN [adw].[2020_tvf_Get_PhyVisitsVisitType] (@BeginDate,@EndDate) d
--		ON a.SUBSCRIBER_ID = d.SUBSCRIBER_ID
--		AND a.SEQ_CLAIM_ID = d.SEQ_CLAIM_ID 
END
/***
EXEC [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_Phy] 25,'07-15-2021'

SELECT *
FROM [dbo].[tmp_AHR_HL7_Report_Detail_Phy]
***/


