CREATE TABLE [lst].[LIST_UBREV] (
    [CreatedDate]       DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]       DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]     VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]       VARCHAR (50)  NULL,
    [lstUBREVKey]       INT           IDENTITY (1, 1) NOT NULL,
    [UBREV_CODE]        VARCHAR (10)  NULL,
    [UBREV_DESC]        VARCHAR (150) NULL,
    [LOAD_DATE]         DATE          NULL,
    [LOAD_USER]         VARCHAR (25)  NULL,
    [ACTIVE]            CHAR (1)      DEFAULT ('Y') NULL,
    [EffectiveDate]     DATE          DEFAULT (getdate()) NULL,
    [ExpirationDate]    DATE          DEFAULT ('2099-12-31') NULL,
    [UBREV_CODE_PADDED] VARCHAR (10)  NULL,
    PRIMARY KEY CLUSTERED ([lstUBREVKey] ASC)
);

