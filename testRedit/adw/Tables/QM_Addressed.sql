CREATE TABLE [adw].[QM_Addressed] (
    [QmAddressedKey]      INT           IDENTITY (1, 1) NOT NULL,
    [srcFileName]         VARCHAR (150) DEFAULT ('File Name Not Provided') NOT NULL,
    [AdiKey]              INT           DEFAULT ((0)) NOT NULL,
    [adiTableName]        VARCHAR (150) NULL,
    [CreateDate]          DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreateBy]            VARCHAR (50)  DEFAULT (suser_name()) NOT NULL,
    [LastUpdatedDate]     DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]       VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [ClientKey]           INT           NOT NULL,
    [ClientMemberKey]     VARCHAR (50)  DEFAULT ('0') NOT NULL,
    [QmMsrId]             VARCHAR (50)  DEFAULT ('0') NULL,
    [QmCntCat]            VARCHAR (10)  DEFAULT ('NUM') NOT NULL,
    [QMDate]              DATE          NOT NULL,
    [AddressedDataSource] VARCHAR (50)  NULL,
    [AddressedDate]       DATE          NULL,
    [DataDate]            DATE          NULL,
    [NPI]                 VARCHAR (50)  NULL,
    [ProviderName]        VARCHAR (50)  NULL,
    [RowStatus]           TINYINT       DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([QmAddressedKey] ASC)
);

