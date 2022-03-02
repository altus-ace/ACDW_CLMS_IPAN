CREATE TABLE [lst].[List_HCPCS] (
    [CreatedDate]    DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]    DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]  VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]    VARCHAR (50)   NULL,
    [lstHCPCSKey]    INT            IDENTITY (1, 1) NOT NULL,
    [HCPC_MOD]       VARCHAR (20)   NULL,
    [ACTION_CD]      VARCHAR (20)   NULL,
    [SHORT_DESC]     VARCHAR (50)   NULL,
    [LONG_DESC]      VARCHAR (8000) NULL,
    [ACTIVE]         CHAR (1)       DEFAULT ('Y') NULL,
    [EffectiveDate]  DATE           DEFAULT (getdate()) NULL,
    [ExpirationDate] DATE           DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([lstHCPCSKey] ASC)
);

