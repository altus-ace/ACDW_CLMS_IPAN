/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */






CREATE PROCEDURE [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Header] 
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate			DATE
	)

AS
BEGIN

	SET NOCOUNT ON;

IF OBJECT_ID('[dbo].[tmp_AHR_HL7_Report_Header]', 'U') IS NOT NULL 
  DROP TABLE [dbo].[tmp_AHR_HL7_Report_Header]; 

CREATE TABLE [dbo].[tmp_AHR_HL7_Report_Header](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ClientName] [varchar](25) NULL,
	[ACE_Id] [varchar](25) NULL,
	[LastName] [varchar](100) NULL,
	[FirstName] [varchar](100) NULL,
	[SubscriberNo] [varchar](50) NULL,
	[PCP] [varchar](50) NULL,
	[PCP_LastName] [varchar](100) NULL,
	[PCP_FirstName] [varchar](100) NULL,
	[DOB] [date] NULL,
	[CurrentAge] [int] NULL,
	[Gender] [varchar](1) NULL,
	[Address1] [varchar](100) NULL,
	[Address2] [varchar](100) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](2) NULL,
	[Zip] [varchar](10) NULL,
	[Phone] [varchar] (20) NULL,
	[PracticeID] [int] NULL,
	[PracticeName] [varchar](100) NULL,
	[ACE_Guid] [varchar] (50) NULL,
	[EMR_CLIENT_ID] varchar(20) NULL,
	[Risk_Score1]	decimal (5,2),
	[Risk_Score2]	decimal (5,2),
	[Risk_Band1]	varchar(10) NULL,
	[Risk_Band2]	varchar(10) NULL,
	[LOADDATE] [datetime] NULL,
	[LOADEDBY] [varchar](100) NULL,
	PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Header] ADD  DEFAULT (sysdatetime()) FOR [LOADDATE]

ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Header] ADD  DEFAULT (suser_sname()) FOR [LOADEDBY]

CREATE TABLE #tmpAHRHeader(
		[ID] [int] IDENTITY(1,1) NOT NULL,
		[ClientName] [varchar](25) NULL,
		[ACE_Id] [varchar](25) NULL,
		[LastName] [varchar](100) NULL,
		[FirstName] [varchar](100) NULL,
		[SubscriberNo] [varchar](50) NULL,
		[PCP] [varchar](50) NULL,
		[PCP_LastName] [varchar](100) NULL,
		[PCP_FirstName] [varchar](100) NULL,
		[DOB] [date] NULL,
		[CurrentAge] [int] NULL,
		[Gender] [varchar](1) NULL,
		[Address1] [varchar](100) NULL,
		[Address2] [varchar](100) NULL,
		[City] [varchar](50) NULL,
		[State] [varchar](2) NULL,
		[Zip] [varchar](10) NULL,
		[Phone] [varchar] (20) NULL,
		[PracticeID] [varchar] (10) NULL,
		[PracticeName] [varchar](100) NULL,
		[ACE_Guid] [varchar] (50) NULL,
		[EMR_CLIENT_ID] varchar(20) NULL,
		[Risk_Score1]	decimal (5,2),
		[Risk_Score2]	decimal (5,2),
		[Risk_Band1]	varchar(10) NULL,
		[Risk_Band2]	varchar(10) NULL)
CREATE NONCLUSTERED INDEX ix_tempAHRHeader ON #tmpAHRHeader ([SubscriberNo]);

INSERT INTO #tmpAHRHeader (
		 [CLIENTNAME]
		,[ACE_Id]
		,[FIRSTNAME]
		,[LASTNAME]
		,[SUBSCRIBERNO]
		,[PCP]
		,[PCP_LASTNAME]
		,[PCP_FirstName]
		,[DOB]
		,[CURRENTAGE]
		,[GENDER]
		,[ADDRESS1],[ADDRESS2],[CITY],[STATE],[ZIP],[PHONE]
		,[PRACTICEID]
		,[PRACTICENAME]
		,[ACE_GUID]
		,[EMR_CLIENT_ID]
		,[RISK_SCORE1]
		,[RISK_SCORE2]
		,[RISK_BAND1]
		,[RISK_BAND2])
SELECT DISTINCT c.ClientShortName
		,a.ACE_ID
		,a.[FirstName] as [FIRSTNAME]
		,a.[LastName] as [LASTNAME]
		,a.[SUBSCRIBER_ID] as SUBSCRIBERNO
		,a.[NPI] as PCP
		,b.ProviderLastName as PCP_LASTNAME
		,b.ProviderFirstName AS PCP_FIRSTNAME
		,a.[DOB] as DOB
		,[CURRENTAGE] = DATEDIFF(HOUR,a.DOB,GETDATE())/8766 
		,a.[Gender] as GENDER
		,LEFT(b.MemberHomeAddress,90) as ADDRESS1
		,LEFT(b.MemberHomeAddress1,90) AS ADDRESS2
		,LEFT(b.MemberHomeCity,50) as CITY
		,LEFT(b.MemberHomeState,2) as STATE
		,LEFT(b.MemberHomeZip,10) as ZIP
		,LEFT(b.MemberPhone,20) AS PHONE
		,a.[TIN] AS PRACTICEID
		,RTRIM(B.ProviderPracticeName) AS PRACTICENAME
		, 'DB01'+ CONVERT(VARCHAR(12), Replace(Replace(Replace(CONVERT(VARCHAR(20), GETDATE(), 121), '-',''),':', ''), ' ', '')) + CONVERT(varchar(7),a.ID) AS ACE_GUID
		,a.EMR_CLIENT_ID ----INSERT EMR_CLIENT_ID
		,b.ClientRiskScore				AS [RISK_SCORE1]
		,b.ACERiskScore					AS [RISK_SCORE2]
		,'U'			AS [RISK_BAND1]
		,CASE WHEN b.ACERiskScore < 5 THEN 'L' WHEN 	b.ACERiskScore >= 5 AND b.ACERiskScore <15 THEN 'M' WHEN b.ACERiskScore >= 15 THEN 'H' ELSE 'U' END	AS [RISK_BAND2]
		FROM [dbo].[tmp_AHR_HL7_Population] a  
		JOIN lst.List_Client c
			ON a.ClientKey	= c.ClientKey
		JOIN [adw].[2020_tvf_Get_ActiveMembersFull] (@RunDate) b
		ON a.[SUBSCRIBER_ID] = b.ClientMemberKey

INSERT INTO dbo.[tmp_AHR_HL7_Report_Header] 
	(
		 [CLIENTNAME]
		,[ACE_Id]
		,[LASTNAME]
		,[FIRSTNAME]
		,[SUBSCRIBERNO]
		,[PCP]
		,[PCP_LASTNAME]
		,[PCP_FirstName]
		,[DOB]
		,[CURRENTAGE]
		,[GENDER]
		,[ADDRESS1],[ADDRESS2],[CITY],[STATE],[ZIP],[PHONE]
		,[PRACTICEID]
		,[PRACTICENAME]
		,[ACE_GUID]
		,[EMR_CLIENT_ID]
		,[RISK_SCORE1]
		,[RISK_SCORE2]
		,[RISK_BAND1]
		,[RISK_BAND2]
	)
SELECT  
		[CLIENTNAME]
		,[ACE_ID]
		,[LASTNAME]
		,[FIRSTNAME]
		,[SUBSCRIBERNO]
		,[PCP]
		,[PCP_LASTNAME]
		,[PCP_FIRSTNAME]
		,[DOB]
		,[CURRENTAGE]
		,[GENDER]
		,adi.udf_ConvertToCamelCase([ADDRESS1]),adi.udf_ConvertToCamelCase([ADDRESS2])
		,adi.udf_ConvertToCamelCase([CITY]),adi.udf_ConvertToCamelCase([STATE]),[ZIP],[PHONE]
		,[PRACTICEID]
		,adi.udf_ConvertToCamelCase([PRACTICENAME])
		,[ACE_GUID]
		,[EMR_CLIENT_ID]
		,[RISK_SCORE1]
		,[RISK_SCORE2]
		,[RISK_BAND1]
		,[RISK_BAND2]

FROM    
		#tmpAHRHeader
		
END
/***
EXEC [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Header] 25,'07-15-2021'

SELECT *
FROM dbo.[tmp_AHR_HL7_Report_Header]
***/
