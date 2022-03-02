CREATE TABLE [lst].[List_CPT] (
    [CreatedDate]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]  VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]    VARCHAR (50)  NULL,
    [lstCPTKey]      INT           IDENTITY (1, 1) NOT NULL,
    [CPT_CODE]       VARCHAR (20)  NULL,
    [CPT_DESC]       VARCHAR (100) NULL,
    [CPT_VER]        INT           NULL,
    [ACTIVE]         CHAR (1)      DEFAULT ('Y') NULL,
    [EffectiveDate]  DATE          DEFAULT (getdate()) NULL,
    [ExpirationDate] DATE          DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([lstCPTKey] ASC)
);

