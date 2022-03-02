CREATE TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Phy] (
    [IP_ID]              INT           IDENTITY (4000, 1) NOT NULL,
    [ClientKey]          INT           NULL,
    [ClientMemberKey]    VARCHAR (50)  NULL,
    [PrimaryServiceDate] DATE          NULL,
    [ProviderNPI]        VARCHAR (10)  NULL,
    [ProviderSpecialty]  VARCHAR (50)  NULL,
    [PrimaryDiagnosis]   VARCHAR (100) NULL,
    [VisitType]          VARCHAR (50)  NULL,
    [AttribNPI]          VARCHAR (10)  NULL,
    [AttribTIN]          VARCHAR (10)  NULL,
    [LOADDATE]           DATE          DEFAULT (sysdatetime()) NULL,
    [LOADEDBY]           VARCHAR (50)  DEFAULT (suser_sname()) NULL
);

