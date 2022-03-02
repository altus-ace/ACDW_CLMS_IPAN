CREATE TABLE [ast].[QM_Addressed] (
    [astQMAdressedKey]    INT            IDENTITY (1, 1) NOT NULL,
    [srcFileName]         VARCHAR (100)  NOT NULL,
    [AdiKey]              INT            NOT NULL,
    [adiTableName]        VARCHAR (28)   NOT NULL,
    [CreatedDate]         DATETIME       CONSTRAINT [df_CreatedDateBC] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]           NVARCHAR (128) CONSTRAINT [df_CreatedByBC] DEFAULT (suser_sname()) NULL,
    [LastUpdatedDate]     DATETIME       CONSTRAINT [df_LastUpdatedDateBC] DEFAULT (getdate()) NOT NULL,
    [LastUpDatedBy]       NVARCHAR (128) CONSTRAINT [df_LastUpDatedByBC] DEFAULT (suser_sname()) NULL,
    [ClientKey]           INT            NULL,
    [ClientMemberKey]     VARCHAR (8000) NULL,
    [QmMsrId]             VARCHAR (50)   NULL,
    [QmCntCat]            VARCHAR (12)   NOT NULL,
    [QMDate]              DATE           NULL,
    [AddressedDataSource] VARCHAR (50)   NULL,
    [AddressedDate]       DATE           NULL,
    [DataDate]            DATE           NULL,
    [NPI]                 VARCHAR (50)   NULL,
    [ProviderName]        VARCHAR (50)   NULL,
    [RowStatus]           TINYINT        DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([astQMAdressedKey] ASC)
);

