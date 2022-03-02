CREATE TABLE [lst].[LIST_MDC] (
    [CreatedDate]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]  VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]    VARCHAR (50)  NULL,
    [lstMDCKey]      INT           IDENTITY (1, 1) NOT NULL,
    [Mdc_Code]       VARCHAR (20)  NULL,
    [Mdc_Desc]       VARCHAR (300) NULL,
    [MS_DRG]         VARCHAR (20)  NULL,
    [Type]           VARCHAR (20)  NULL,
    [ACTIVE]         CHAR (1)      DEFAULT ('Y') NULL,
    [EffectiveDate]  DATE          DEFAULT (getdate()) NULL,
    [ExpirationDate] DATE          DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([lstMDCKey] ASC)
);

