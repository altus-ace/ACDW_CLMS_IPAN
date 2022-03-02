



CREATE PROCEDURE [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_CG] 
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate		DATE
	)
AS
BEGIN

	SET NOCOUNT ON;


IF OBJECT_ID('[dbo].[tmp_AHR_HL7_Report_Detail_CG]', 'U') IS NOT NULL 
  DROP TABLE [dbo].[tmp_AHR_HL7_Report_Detail_CG]; 

CREATE TABLE [dbo].[tmp_AHR_HL7_Report_Detail_CG](
	[ID] [int] IDENTITY(1000,1) NOT NULL,
	[SUBSCRIBER_ID] [varchar](50) NULL,
	[CGQMDATE] DATE NULL,
	[CGQM] [varchar](50) NULL,
	[CGQMDESC] [varchar](200) NULL,
	[LOADDATE] [date] NULL,
	[LOADEDBY] [varchar](50) NULL
	)

ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_CG] ADD  DEFAULT (sysdatetime()) FOR [LOADDATE]


ALTER TABLE [dbo].[tmp_AHR_HL7_Report_Detail_CG] ADD  DEFAULT (suser_sname()) FOR [LOADEDBY]

INSERT INTO [dbo].[tmp_AHR_HL7_Report_Detail_CG]
		([SUBSCRIBER_ID], 
		 [CGQMDATE],
		 [CGQM], 
		 [CGQMDESC]
		)
	SELECT a.[ClientMemberKey] as [SUBSCRIBER_ID]
			,a.QMDate
			,a.[QmMsrId]		as [CGQM]
			,b.AHR_QM_DESC		as [CGQMDESC]
	FROM [adw].[QM_ResultByMember_History] a
	JOIN dbo.vw_tmp_AHR_Population m
         ON a.ClientMemberKey = m.ClientMemberKey
	LEFT JOIN lst.LIST_QM_Mapping b ON a.QmMsrId = b.QM
	WHERE [QmCntCat] = 'COP'
	AND a.QMDate = (SELECT MAX(QMDATE) FROM [adw].[QM_ResultByMember_History])
	AND b.ACTIVE = 'Y' AND a.QMDate BETWEEN b.EffectiveDate AND b.ExpirationDate
	--AND QMDate = @RunDate
			--ORDER BY a.[ClientMemberKey], a.[QmMsrId]
	--             LEFT JOIN lst.LIST_QM_Mapping b ON co.QmMsrId = b.QM
    --             LEFT JOIN lst.LIST_AHRTIPS c ON co.QmMsrId = c.QM_ID
    --             WHERE [Gap] = 1
    --                   AND b.ACTIVE = 'Y')
	UNION
	SELECT a.ClientMemberKey
			,b.EffectiveAsOfDate
			,'AWV'
			,CONCAT('Last AWV Date = ',b.PrimaryServiceDate,' as of ', b.EffectiveAsOfDate)
	FROM dbo.vw_tmp_AHR_Population a
	LEFT JOIN [adw].[2020_tvf_Get_MembersLastAWVisit] (@RunDate) b
	ON a.ClientMemberKey = b.ClientMemberKey
	WHERE b.ClientMemberKey IS NOT NULL
	AND b.PrimaryServiceDate BETWEEN DATEADD(YEAR, -1, @RunDate) AND DATEADD(yy,DATEDIFF(yy,0,GETDATE()),0)

    END;

/***
EXEC [adw].[sp_Drop_Create_Load_tmp_AHR_HL7_Report_Detail_CG] 16,'10-30-2020'

SELECT * FROM [dbo].[tmp_AHR_HL7_Report_Detail_CG]
where cgqm = 'AWV'
***/
