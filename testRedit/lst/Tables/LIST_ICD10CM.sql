CREATE TABLE [lst].[LIST_ICD10CM] (
    [CreatedDate]     DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]     DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]   VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]     VARCHAR (50)   NULL,
    [ACTIVE]          CHAR (1)       NULL,
    [EffectiveDate]   DATE           NULL,
    [ExpirationDate]  DATE           NULL,
    [lstIcd10CmKey]   INT            IDENTITY (1, 1) NOT NULL,
    [VALUE_CODE]      VARCHAR (50)   NULL,
    [VALUE_CODE_NAME] VARCHAR (2000) NULL,
    PRIMARY KEY CLUSTERED ([lstIcd10CmKey] ASC)
);

