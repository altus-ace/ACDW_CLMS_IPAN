

CREATE PROCEDURE [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Population]
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate		DATE
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('[dbo].[tmp_AHR_HL7_Population]', 'U') IS NOT NULL
		DROP TABLE [dbo].[tmp_AHR_HL7_Population];

	CREATE TABLE [dbo].[tmp_AHR_HL7_Population] (
		[ID] [int] IDENTITY(100000, 1) NOT NULL
		,[CLIENTKEY]	VARCHAR(2) NOT NULL
		,[ACE_ID] NUMERIC (20) NULL
		,[SUBSCRIBER_ID] [varchar](50) NULL
		,[FIRSTNAME] [varchar](100) NULL
		,[LASTNAME] [varchar](100) NULL
		,[GENDER] [varchar](1) NULL
		,[DOB] [date] NULL
		,[TIN] [varchar](50) NULL
		,[NPI] [varchar](50) NULL
		,[EMR_ID] [varchar](25) NULL
		,[EMR_NPI] [varchar](50) NULL
		,[EMR_FIRST_NAME] [varchar](50) NULL
		,[EMR_MI] [varchar](1) NULL
		,[EMR_LAST_NAME] [varchar](50) NULL
		,[EMR_CLIENT_ID] [varchar](50) NULL
		,[EMR_CLIENT_NAME] [varchar](50) NULL
		,[EMR_ALT_CLIENT_ID] [varchar](50) NULL
		,[EMR_PRACTICE_TIN] [varchar](50) NULL
		,[AttribNPI] [varchar](10) NULL
		,[AttribTIN] [varchar](10) NULL
		,[LOADDATE] [date] NULL
		,[LOADEDBY] [varchar](50) NULL
		,[CreatedDate] [datetime] NULL
		,[CreatedBy] [varchar](50) NULL
		,[LastUpdatedDate] [datetime] NULL
		,[LastUpdatedBy] [varchar](50) NULL
		,[AdiKey] [int] NULL
		,[SrcFileName] [varchar](100) NULL
		,[AdiTableName] [varchar](100) NULL
		) ON [PRIMARY]
	
		ALTER TABLE [dbo].[tmp_AHR_HL7_Population] ADD  DEFAULT(sysdatetime()) FOR [LOADDATE]
		ALTER TABLE [dbo].[tmp_AHR_HL7_Population] ADD  DEFAULT(suser_sname()) FOR [LOADEDBY]
		ALTER TABLE [dbo].[tmp_AHR_HL7_Population] ADD  DEFAULT (getdate()) FOR [CreatedDate]
		ALTER TABLE [dbo].[tmp_AHR_HL7_Population] ADD  DEFAULT (suser_sname()) FOR [CreatedBy]
		ALTER TABLE [dbo].[tmp_AHR_HL7_Population] ADD  DEFAULT (getdate()) FOR [LastUpdatedDate]
		ALTER TABLE [dbo].[tmp_AHR_HL7_Population] ADD  DEFAULT (suser_sname()) FOR [LastUpdatedBy]


	INSERT INTO dbo.[tmp_AHR_HL7_Population] (
		[SrcFileName]
		,[ClientKey]
		,[ACE_ID]
		,[SUBSCRIBER_ID]
		,[FIRSTNAME]
		,[LASTNAME]
		,[GENDER]
		,[DOB]
		,[TIN]
		,[NPI]
		,[EMR_ID]
		,[EMR_NPI]
		,[EMR_FIRST_NAME]
		,[EMR_MI]
		,[EMR_LAST_NAME]
		,[EMR_CLIENT_ID]
		,[EMR_CLIENT_NAME]
		,[EMR_ALT_CLIENT_ID]
		,[EMR_PRACTICE_TIN]
		,[AttribNPI]
		,[AttribTIN]
		)
	SELECT DISTINCT 
		 '[adw].[2020_tvf_Get_ActiveMembersFull]'
		,@ClientKeyID
		,a.Ace_ID
		,a.[ClientMemberKey]
		,a.[FirstName] AS FirstName
		,a.[LastName] AS LastName
		,a.[Gender] AS Sex
		,a.[DOB] AS DOB
		,a.PcpPracticeTIN AS TIN
		,a.[NPI] AS NPI
		,'' -- b.[EMR_ID]
		,a.[NPI]
		,'' -- b.[EMR_FIRST_NAME]
		,'' -- b.[EMR_MI]
		,'' -- b.[EMR_LAST_NAME]
		,'' -- b.[EMR_CLIENT_ID]
		,'' -- b.[EMR_CLIENT_NAME]
		,'' -- b.[ALT_CLIENT_ID]
		,a.PcpPracticeTIN
		,a.[NPI]
		,a.PcpPracticeTIN
	FROM [adw].[2020_tvf_Get_ActiveMembersFull] (@RunDate) a
	WHERE a.DOD = '1900-01-01'
	AND a.PcpPracticeTIN <> '111111111'

END
/***
EXEC [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Population] 25,'07-15-2021'

SELECT * FROM dbo.[tmp_AHR_HL7_Population]
***/
