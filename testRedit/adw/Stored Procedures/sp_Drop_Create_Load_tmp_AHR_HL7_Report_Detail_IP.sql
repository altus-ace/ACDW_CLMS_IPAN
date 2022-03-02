
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */




CREATE PROCEDURE [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_IP] 
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate		DATE
	)
AS
BEGIN

	SET NOCOUNT ON;

IF OBJECT_ID('[dbo].[tmp_AHR_HL7_Report_Detail_IP]', 'U') IS NOT NULL 
  DROP TABLE [dbo].[tmp_AHR_HL7_Report_Detail_IP]; 

CREATE TABLE [dbo].[tmp_AHR_HL7_Report_Detail_IP](
	[IP_ID] [int] IDENTITY(4000,1) NOT NULL,
	[SUBSCRIBER_ID] [varchar](50) NULL,
	[ADMIT_DATE] [date] NULL,
	[DISC_DATE] [date] NULL,
	[LOS] [int] NULL,
	[DISC_DISPOSITION] [varchar](25) NULL,
	[PRIMARY_DX] [varchar](11) NULL,
	[DESC] [varchar](max) NULL,
	[SECONDARY_DX] [varchar](11) NULL,
	[SECONDARY_DESC] [varchar](max) NULL,
	[LOCATION] [varchar](250) NULL,
	[LOADDATE] [date] NULL,
	[LOADEDBY] [varchar](50) NULL
)

ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_IP] ADD  DEFAULT (sysdatetime()) FOR [LOADDATE]

ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_IP] ADD  DEFAULT (suser_sname()) FOR [LOADEDBY]

DECLARE @BeginDate [DATE] = ( SELECT CAST(DATEADD(YEAR, -1, @RunDate) AS DATE) )
DECLARE @EndDate [DATE] = ( SELECT CONVERT (DATE, @RunDate) ) 

INSERT INTO [dbo].[tmp_AHR_HL7_Report_Detail_IP](
		[SUBSCRIBER_ID]
		,[ADMIT_DATE]
		,[DISC_DATE]
		,[LOS]
		,[DISC_DISPOSITION]
		,[PRIMARY_DX]
		,[DESC]
		,[SECONDARY_DX]
		,[SECONDARY_DESC]
		,[LOCATION]
	)

SELECT DISTINCT 
		 a.ClientMemberKey
		,a.AdmissionDate
		,a.DischargeDate
		,a.LOS
		,a.DischargeDisposition
		,c.PrimaryDiagCode			
		,c.PrimaryDiagDescription		AS [DESC]
		,c.SecondaryDiagCode			AS [SECONDARY_DX]
		,c.SecondaryDiagDescription		AS [SECONDARY_DESC]
		,a.VendorName	AS [LOCATION]
		--,CONCAT(a.VendorID,' ',a.VendorName)	AS [LOCATION]
FROM adw.fctInpatientVisits a
JOIN dbo.tmp_AHR_HL7_Population b 
ON b.SUBSCRIBER_ID = a.ClientMemberKey             
LEFT JOIN [adw].[2020_tvf_Get_PrimarySecondaryDiagCode] ('0','0',@BeginDate) c
		ON a.ClientMemberKey = c.ClientMemberKey
		AND a.SEQ_ClaimID = c.SeqClaimID
WHERE a.ClaimType = '60'
AND a.EffectiveAsOfDate = (SELECT MAX(EffectiveAsOfDate) FROM adw.fctInpatientVisits)

--FROM [adw].[2020_tvf_Get_IPVisits] (@BeginDate,@EndDate) a
--JOIN dbo.tmp_AHR_HL7_Population b 
--ON b.SUBSCRIBER_ID = a.SUBSCRIBER_ID             
--LEFT JOIN [adw].[2020_tvf_Get_PrimarySecondaryDiagCode] ('0','0',@BeginDate) c
--		ON a.SUBSCRIBER_ID = c.ClientMemberKey
--		AND a.SEQ_CLAIM_ID = c.SeqClaimID
--WHERE a.CLAIM_TYPE = '60'

END
/***
EXEC [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_IP] 20,'04-15-2021'

SELECT *
FROM [dbo].[tmp_AHR_HL7_Report_Detail_IP]

SELECT *
FROM adw.fctInpatientVisits
WHERE ClaimType = '60'
OR LEFT(BillType,1) = 1
***/



