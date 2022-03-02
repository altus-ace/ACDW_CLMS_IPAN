CREATE TABLE [lst].[LIST_PROV_SPECIALTY_CODES] (
    [CreatedDate]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]  VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]    VARCHAR (50)  NULL,
    [ProvSpecKey]    INT           IDENTITY (1, 1) NOT NULL,
    [Code]           VARCHAR (20)  NOT NULL,
    [CodeDesc]       VARCHAR (200) NOT NULL,
    [ACTIVE]         CHAR (1)      NULL,
    [EffectiveDate]  DATE          DEFAULT (getdate()) NULL,
    [ExpirationDate] DATE          DEFAULT ('2099-12-31') NULL,
    [Prov_Class]     VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([ProvSpecKey] ASC)
);

