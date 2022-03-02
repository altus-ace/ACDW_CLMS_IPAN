CREATE TABLE [lst].[List_ICD10PCScwCCSCategory] (
    [CreatedDate]             DATETIME      DEFAULT (getdate()) NULL,
    [CreatedBy]               VARCHAR (20)  DEFAULT (suser_sname()) NULL,
    [LastUpdatedDate]         DATETIME      DEFAULT (getdate()) NULL,
    [LastUpdatedBy]           VARCHAR (20)  DEFAULT (suser_sname()) NULL,
    [LoadDate]                DATE          DEFAULT (CONVERT([date],getdate())) NULL,
    [ICD10PCSCCSCategoryKey]  INT           IDENTITY (1, 1) NOT NULL,
    [ICD10PCSCode]            VARCHAR (50)  NULL,
    [CCSCategory]             CHAR (5)      NULL,
    [ICD10PCSCodeDescription] VARCHAR (500) NULL,
    [CCSCategoryDescription]  VARCHAR (500) NULL,
    [MultiCCSLvl1]            VARCHAR (150) NULL,
    [MultiCCSLvl1Label]       VARCHAR (150) NULL,
    [MultiCCSLvl2]            VARCHAR (150) NULL,
    [MultiCCSLvl2Label]       VARCHAR (150) NULL,
    [ACTIVE]                  CHAR (1)      DEFAULT ('Y') NULL,
    [EffectiveDate]           DATE          DEFAULT (getdate()) NULL,
    [ExpirationDate]          DATE          DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([ICD10PCSCCSCategoryKey] ASC)
);

