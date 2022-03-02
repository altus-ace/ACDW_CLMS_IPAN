CREATE TABLE [lst].[lstChronicConditionIndicator] (
    [CreatedDate]      DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]      DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]    VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [DataDate]         DATE           NOT NULL,
    [SrcFileName]      VARCHAR (100)  NULL,
    [lstCciKey]        INT            IDENTITY (1, 1) NOT NULL,
    [Icd10CmCode]      VARCHAR (15)   NULL,
    [Icd10CmDesc]      VARCHAR (1000) NULL,
    [ChronicIndicator] VARCHAR (10)   NULL,
    [BodySystem]       VARCHAR (10)   NULL,
    [ACTIVE]           CHAR (1)       DEFAULT ('Y') NULL,
    [EffectiveDate]    DATE           DEFAULT (getdate()) NULL,
    [ExpirationDate]   DATE           DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([lstCciKey] ASC)
);

