CREATE TABLE [lst].[LIST_QM_Mapping] (
    [CreatedDate]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]    DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]  VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]    VARCHAR (100) NULL,
    [QmKey]          INT           IDENTITY (1, 1) NOT NULL,
    [QM]             VARCHAR (100) NOT NULL,
    [QM_DESC]        VARCHAR (500) NULL,
    [AHR_QM_DESC]    VARCHAR (500) NULL,
    [ACTIVE]         CHAR (1)      DEFAULT ('Y') NULL,
    [EffectiveDate]  DATE          DEFAULT ('2017-01-01') NULL,
    [ExpirationDate] DATE          DEFAULT ('2099-12-31') NULL,
    [ClientKey]      INT           DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([QmKey] ASC)
);

