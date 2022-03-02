CREATE TABLE [lst].[LIST_ICD10PCS] (
    [CreatedDate]           DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]             VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]           DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]         VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]           VARCHAR (50)   NULL,
    [lstICD10PCSKey]        INT            IDENTITY (1, 1) NOT NULL,
    [ICD10PCS_Code]         VARCHAR (20)   NULL,
    [ICD10PCS_Desc]         VARCHAR (1000) NULL,
    [ICD10PCS_CodeCategory] VARCHAR (20)   NULL,
    [ACTIVE]                CHAR (1)       DEFAULT ('Y') NULL,
    [EffectiveDate]         DATE           DEFAULT (getdate()) NULL,
    [ExpirationDate]        DATE           DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([lstICD10PCSKey] ASC)
);

