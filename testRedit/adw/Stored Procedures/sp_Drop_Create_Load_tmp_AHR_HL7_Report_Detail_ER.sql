
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */




CREATE PROCEDURE [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_ER] 
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate		DATE
	)
AS
BEGIN

	SET NOCOUNT ON;

IF OBJECT_ID('[dbo].[tmp_AHR_HL7_Report_Detail_ER]', 'U') IS NOT NULL 
  DROP TABLE [dbo].[tmp_AHR_HL7_Report_Detail_ER]; 

CREATE TABLE [dbo].[tmp_AHR_HL7_Report_Detail_ER](
	[EP_ID] [int] IDENTITY(3000,1) NOT NULL,
	[SUBSCRIBER_ID] [varchar](50) NULL,
	[DATE] [date] NULL,
	[PRIMARY_DX] [varchar](11) NULL,
	[DESC] [varchar](max) NULL,
	[SECONDARY_DX] [varchar](11) NULL,
	[SECONDARY_DESC] [varchar](max) NULL,
	[LOCATION] [varchar](250) NULL,
	[LOADDATE] [date] NULL,
	[LOADEDBY] [varchar](50) NULL
)


ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_ER] ADD  DEFAULT (sysdatetime()) FOR [LOADDATE]

ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_ER] ADD  DEFAULT (suser_sname()) FOR [LOADEDBY]

DECLARE @BeginDate [Date] = ( SELECT CAST(DATEADD(YEAR, -1, @RunDate) AS DATE) )
DECLARE @EndDate [Date] = ( SELECT CONVERT (DATE, @RunDate) ) 

INSERT INTO [dbo].[tmp_AHR_HL7_Report_Detail_ER]
           (
			  [SUBSCRIBER_ID]
			  ,[DATE]
			  ,[PRIMARY_DX]
			  ,[DESC]
			  ,[SECONDARY_DX]
			  ,[SECONDARY_DESC]
			  ,[LOCATION]
			)
SELECT DISTINCT 
			 a.ClientMemberKey
			,a.PrimaryServiceDate
			,c.PrimaryDiagCode			
			,c.PrimaryDiagDescription		AS [DESC]
			,c.SecondaryDiagCode			AS [SECONDARY_DX]
			,c.SecondaryDiagDescription		AS [SECONDARY_DESC]
			,a.VendorName	AS [LOCATION]
			--,CONCAT(a.VendorID,' ',a.VendorName)	AS [LOCATION]
FROM [adw].[FctEDVisits] a
JOIN dbo.tmp_AHR_HL7_Population b 
ON b.SUBSCRIBER_ID = a.ClientMemberKey              
LEFT JOIN [adw].[2020_tvf_Get_PrimarySecondaryDiagCode] ('0','0',@BeginDate) c
		ON a.ClientMemberKey = c.ClientMemberKey
		AND a.SEQ_ClaimID = c.SeqClaimID
WHERE c.PrimaryDiagCode IS NOT NULL
AND a.EffectiveAsOfDate = (SELECT MAX(EffectiveAsOfDate) FROM [adw].[FctEDVisits])
--FROM [adw].[2020_tvf_Get_ERVisits] (@BeginDate,@EndDate) a
--JOIN dbo.tmp_AHR_HL7_Population b 
--ON b.SUBSCRIBER_ID = a.SUBSCRIBER_ID              
--LEFT JOIN [adw].[2020_tvf_Get_PrimarySecondaryDiagCode] ('0','0',@BeginDate) c
--		ON a.SUBSCRIBER_ID = c.ClientMemberKey
--		AND a.SEQ_CLAIM_ID = c.SeqClaimID

END
/***
EXEC [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_ER] 20,'04-15-2021'

SELECT *
FROM [dbo].[tmp_AHR_HL7_Report_Detail_ER]

SELECT * from [adw].[FctEDVisits]
***/

