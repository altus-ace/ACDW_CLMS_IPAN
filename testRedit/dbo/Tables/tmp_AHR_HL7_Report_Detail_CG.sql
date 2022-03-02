CREATE TABLE [dbo].[tmp_AHR_HL7_Report_Detail_CG] (
    [ID]            INT           IDENTITY (1000, 1) NOT NULL,
    [SUBSCRIBER_ID] VARCHAR (50)  NULL,
    [CGQMDATE]      DATE          NULL,
    [CGQM]          VARCHAR (50)  NULL,
    [CGQMDESC]      VARCHAR (200) NULL,
    [LOADDATE]      DATE          DEFAULT (sysdatetime()) NULL,
    [LOADEDBY]      VARCHAR (50)  DEFAULT (suser_sname()) NULL
);

