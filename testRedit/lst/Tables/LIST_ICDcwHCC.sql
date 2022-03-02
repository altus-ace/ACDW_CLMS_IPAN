CREATE TABLE [lst].[LIST_ICDcwHCC] (
    [CreatedDate]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]  VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]    VARCHAR (50)  NULL,
    [ICDcwHCCKey]    INT           IDENTITY (1, 1) NOT NULL,
    [ICDCode]        VARCHAR (20)  NULL,
    [Description]    VARCHAR (150) NULL,
    [HCC]            VARCHAR (10)  NULL,
    [VER]            VARCHAR (10)  NULL,
    [ACTIVE]         CHAR (1)      DEFAULT ('Y') NULL,
    [EffectiveDate]  DATE          DEFAULT ('2017-01-01') NULL,
    [ExpirationDate] DATE          DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([ICDcwHCCKey] ASC)
);

