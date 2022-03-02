CREATE TABLE [adw].[Claims_Diags] (
    [URN]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [SEQ_CLAIM_ID]       VARCHAR (50)  NULL,
    [SUBSCRIBER_ID]      VARCHAR (50)  NULL,
    [ICD_FLAG]           CHAR (2)      NULL,
    [diagNumber]         SMALLINT      NULL,
    [diagCode]           VARCHAR (20)  NULL,
    [diagCodeWithoutDot] VARCHAR (20)  NULL,
    [diagPoa]            VARCHAR (20)  NULL,
    [LoadDate]           DATETIME      NOT NULL,
    [SrcAdiTableName]    VARCHAR (100) NULL,
    [SrcAdiKey]          INT           NOT NULL,
    [CreatedDate]        DATETIME      DEFAULT (sysdatetime()) NOT NULL,
    [CreatedBy]          VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]    DATETIME      DEFAULT (sysdatetime()) NOT NULL,
    [LastUpdatedBy]      VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_Claims_Diags] PRIMARY KEY CLUSTERED ([URN] ASC)
);

