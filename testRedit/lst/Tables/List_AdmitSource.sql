CREATE TABLE [lst].[List_AdmitSource] (
    [CreatedDate]          DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]          DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]        VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]          VARCHAR (50)   NULL,
    [lstAdmtSrcKey]        INT            IDENTITY (1, 1) NOT NULL,
    [Code]                 VARCHAR (20)   NULL,
    [Name]                 VARCHAR (5000) NULL,
    [Inpatient/Outpatient] VARCHAR (150)  NULL,
    [Reason_Desc]          VARCHAR (5000) NULL,
    [Poc_VER]              INT            NULL,
    [Active]               CHAR (1)       DEFAULT ('Y') NULL,
    [EffectiveDate]        DATE           DEFAULT (getdate()) NULL,
    [ExpirationDate]       DATE           DEFAULT ('2099-12-31') NULL
);

