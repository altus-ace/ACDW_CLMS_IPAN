

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */





CREATE PROCEDURE [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_Rx] 
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate		DATE
	)
AS
BEGIN

	SET NOCOUNT ON;

CREATE TABLE #tmpMedications(
	[RX_ID] [int]		IDENTITY(3000,1) NOT NULL,
	[SUBSCRIBER_ID]		[varchar](50) NULL,
	[DETAIL_SVC_DATE]	[date] NULL,
	[NDC_CODE]			[varchar](20) NULL,
	[NDC_DESC]			[varchar](100) NULL,
	[LINE_NUMBER]		INT NULL,
	[RX_DATE_PRESCRIPTION_FILLED] [date] NULL,
	[PRESCRIBING_PROV_ID]	[varchar](20) NULL,
	[PRESCRIBING_PROV_NAME] [varchar](100) NULL,
	[QUANTITY]			numeric(12,2) NULL,
	[RX_SUPPLY_DAYS]	[varchar](50) NULL,
	[LOADDATE]			[date] NULL,
	[LOADEDBY]			[varchar](50) NULL
)
CREATE CLUSTERED INDEX ix_tmpSubcriberID ON #tmpMedications ([SUBSCRIBER_ID])

IF OBJECT_ID('[dbo].[tmp_AHR_HL7_Report_Detail_Rx]', 'U') IS NOT NULL 
  DROP TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Rx]; 

CREATE TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Rx](
	[RX_ID] [int]		IDENTITY(3000,1) NOT NULL,
	[SUBSCRIBER_ID]		[varchar](50) NULL,
	[DETAIL_SVC_DATE]	[date] NULL,
	[NDC_CODE]			[varchar](20) NULL,
	[NDC_DESC]			[varchar](100) NULL,
	[LINE_NUMBER]		INT NULL,
	[RX_DATE_PRESCRIPTION_FILLED] [date] NULL,
	[PRESCRIBING_PROV_ID]	[varchar](20) NULL,
	[PRESCRIBING_PROV_NAME] [varchar](100) NULL,
	[QUANTITY]			numeric(12,2) NULL,
	[RX_SUPPLY_DAYS]	[varchar](50) NULL,
	[LOADDATE]			[date] NULL,
	[LOADEDBY]			[varchar](50) NULL
)

ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Rx] ADD  DEFAULT (sysdatetime()) FOR [LOADDATE]

ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Rx] ADD  DEFAULT (suser_sname()) FOR [LOADEDBY]

DECLARE @BeginDate [Date] = ( SELECT CAST(DATEADD(month, -6, @RunDate) AS DATE) )
DECLARE @EndDate [Date] = ( SELECT CONVERT (DATE, @RunDate) ) 

INSERT INTO #tmpMedications
         (
			[SUBSCRIBER_ID]		
			,[DETAIL_SVC_DATE]	
			,[NDC_CODE]			
			,[NDC_DESC]			
			,[LINE_NUMBER]		
			,[RX_DATE_PRESCRIPTION_FILLED]
			,[PRESCRIBING_PROV_ID]
			,[PRESCRIBING_PROV_NAME]
			,[QUANTITY]			 
			,[RX_SUPPLY_DAYS]	
			)
SELECT  --DISTINCT  
			 a.[SUBSCRIBER_ID]		
			,a.[DETAIL_SVC_DATE]	
			,a.[NDC]			
			,LEFT(a.[NDC_DESC],80)			
			,a.[LINE_NUMBER]		
			,a.[RX_DATE_PRESCRIPTION_FILLED]
			,a.[PRESCRIBING_PROV_ID]
			,'' AS [PRESCRIBING_PROV_NAME]
			,a.[QUANTITY]
			,a.[RX_SUPPLY_DAYS]
FROM  [adw].[2020_tvf_Get_Medications] (@BeginDate, @EndDate, @EndDate ) a


INSERT INTO [dbo].[tmp_AHR_HL7_Report_Detail_Rx]
         (
			[SUBSCRIBER_ID]		
			,[DETAIL_SVC_DATE]	
			,[NDC_CODE]			
			,[NDC_DESC]			
			,[LINE_NUMBER]		
			,[RX_DATE_PRESCRIPTION_FILLED]
			,[PRESCRIBING_PROV_ID]
			,[PRESCRIBING_PROV_NAME]
			,[QUANTITY]			 
			,[RX_SUPPLY_DAYS]	
			)
SELECT  --DISTINCT  
			 a.[SUBSCRIBER_ID]		
			,a.[DETAIL_SVC_DATE]	
			,a.[NDC_CODE]			
			,a.[NDC_DESC]			
			,a.[LINE_NUMBER]		
			,a.[RX_DATE_PRESCRIPTION_FILLED]
			,a.[PRESCRIBING_PROV_ID]
			,svcnpi.LegalBusinessName AS [PRESCRIBING_PROV_NAME]
			,a.[QUANTITY]
			,a.[RX_SUPPLY_DAYS]
FROM  #tmpMedications a
	JOIN  dbo.tmp_AHR_HL7_Population b
	ON b.SUBSCRIBER_ID = a.SUBSCRIBER_ID 
LEFT JOIN adw.[2020_tvf_Get_DataFromNPPES] (getdate()) svcnpi
	ON a.[PRESCRIBING_PROV_ID] = svcnpi.NPI             

END

/***
EXEC [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_Rx] 20,'04-15-2021'

SELECT TOP 1000 * 
FROM [adw].[2020_tvf_Get_Medications] ('2021-01-15', '2021-05-15', '2020-05-15') a

SELECT *
FROM [tmp_AHR_HL7_Report_Detail_Rx]
***/
