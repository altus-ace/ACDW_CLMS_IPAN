CREATE TABLE [lst].[LIST_AHRTIPS] (
    [CreatedDate]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]  VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]    VARCHAR (50)  NULL,
    [AhrTipsKey]     INT           IDENTITY (1, 1) NOT NULL,
    [QMID]           VARCHAR (20)  NOT NULL,
    [QMDesc]         VARCHAR (100) NOT NULL,
    [Gender]         VARCHAR (5)   NULL,
    [StartAgeMth]    INT           NULL,
    [EndAgeMth]      INT           NULL,
    [Line]           TINYINT       NULL,
    [Documentation]  VARCHAR (250) NULL,
    [Tips]           VARCHAR (250) NULL,
    [Codes]          VARCHAR (250) NULL,
    [VersionDate]    DATE          NOT NULL,
    [ACTIVE]         CHAR (1)      NULL,
    [EffectiveDate]  DATE          DEFAULT (getdate()) NULL,
    [ExpirationDate] DATE          DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([AhrTipsKey] ASC)
);

