CREATE TABLE [adw].[Claims_Member] (
    [SUBSCRIBER_ID]         VARCHAR (50)  NOT NULL,
    [IsActiveMember]        TINYINT       CONSTRAINT [DF_ClaimsMember_IsActive] DEFAULT ((0)) NOT NULL,
    [DOB]                   VARCHAR (50)  NULL,
    [MEMB_LAST_NAME]        VARCHAR (50)  NULL,
    [MEMB_MIDDLE_INITIAL]   VARCHAR (50)  NULL,
    [MEMB_FIRST_NAME]       VARCHAR (50)  NULL,
    [MEDICAID_NO]           VARCHAR (50)  NULL,
    [MEDICARE_NO]           VARCHAR (50)  NULL,
    [Gender]                VARCHAR (5)   NULL,
    [MEMB_ZIP]              VARCHAR (50)  NULL,
    [COMPANY_CODE]          VARCHAR (50)  NULL,
    [LINE_OF_BUSINESS_DESC] VARCHAR (50)  NULL,
    [SrcAdiTableName]       VARCHAR (100) NULL,
    [SrcAdiKey]             INT           NOT NULL,
    [LoadDate]              DATETIME      NOT NULL,
    [CreatedDate]           DATETIME      DEFAULT (sysdatetime()) NOT NULL,
    [CreatedBy]             VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]       DATETIME      DEFAULT (sysdatetime()) NOT NULL,
    [LastUpdatedBy]         VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_Claims_Member] PRIMARY KEY CLUSTERED ([SUBSCRIBER_ID] ASC)
);

