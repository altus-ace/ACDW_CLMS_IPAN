CREATE TABLE [lst].[List_DRG] (
    [CreatedDate]                     DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                       VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]                     DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]                   VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]                     VARCHAR (50)   NULL,
    [lstDrgKey]                       INT            IDENTITY (1, 1) NOT NULL,
    [DRG_CODE]                        VARCHAR (20)   NULL,
    [DRG_DESC]                        VARCHAR (5000) NULL,
    [DRG_MDC_MajorDiagnosticCategory] VARCHAR (150)  NULL,
    [MDC_DESC]                        VARCHAR (300)  NULL,
    [MedMorSurgP]                     VARCHAR (20)   NULL,
    [DRG_VER]                         INT            NULL,
    [ACTIVE]                          CHAR (1)       DEFAULT ('Y') NULL,
    [EffectiveDate]                   DATE           DEFAULT (getdate()) NULL,
    [ExpirationDate]                  DATE           DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([lstDrgKey] ASC)
);

