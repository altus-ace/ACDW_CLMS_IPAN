CREATE TABLE [adw].[MbrPcp] (
    [CreatedDate]      DATETIME2 (7) CONSTRAINT [DF_MbrPcp_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        VARCHAR (50)  CONSTRAINT [DF_MbrPcp_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]  DATETIME2 (7) CONSTRAINT [DF_MbrPcp_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]    VARCHAR (50)  CONSTRAINT [DF_MbrPcp_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [mbrPcpKey]        INT           IDENTITY (1, 1) NOT NULL,
    [ClientMemberKey]  VARCHAR (50)  NOT NULL,
    [ClientKey]        INT           NULL,
    [adiKey]           INT           NOT NULL,
    [adiTableName]     VARCHAR (100) NOT NULL,
    [IsCurrent]        CHAR (1)      CONSTRAINT [DF_mbrPcp_recordFlag] DEFAULT ('Y') NOT NULL,
    [EffectiveDate]    DATE          CONSTRAINT [DF_MbrPcpExpirationDate] DEFAULT ('12/31/9999') NOT NULL,
    [ExpirationDate]   DATE          NOT NULL,
    [NPI]              VARCHAR (10)  NOT NULL,
    [TIN]              VARCHAR (10)  NULL,
    [ClientEffective]  DATE          NULL,
    [ClientExpiration] DATE          NULL,
    [AutoAssigned]     VARCHAR (10)  NOT NULL,
    [LoadDate]         DATE          NOT NULL,
    [DataDate]         DATE          NOT NULL,
    [ProviderChapter]  VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([mbrPcpKey] ASC)
);

