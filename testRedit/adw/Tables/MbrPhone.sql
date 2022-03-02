CREATE TABLE [adw].[MbrPhone] (
    [mbrPhoneKey]     INT           IDENTITY (1, 1) NOT NULL,
    [ClientMemberKey] VARCHAR (50)  NOT NULL,
    [ClientKey]       INT           NULL,
    [adiKey]          INT           NOT NULL,
    [adiTableName]    VARCHAR (100) NOT NULL,
    [IsCurrent]       CHAR (1)      CONSTRAINT [DF_MbrPhone_recordFlag] DEFAULT ('Y') NOT NULL,
    [EffectiveDate]   DATE          NOT NULL,
    [ExpirationDate]  DATE          CONSTRAINT [DF_MbrPhoneExpirationDate] DEFAULT ('12/31/9999') NOT NULL,
    [PhoneType]       INT           NOT NULL,
    [CarrierType]     INT           NOT NULL,
    [PhoneNumber]     VARCHAR (30)  NULL,
    [IsPrimary]       TINYINT       CONSTRAINT [DF_MbrPhone_IsPrimary] DEFAULT ((0)) NOT NULL,
    [LoadDate]        DATE          NOT NULL,
    [DataDate]        DATE          NOT NULL,
    [CreatedDate]     DATETIME2 (7) CONSTRAINT [DF_MbrPhone_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (50)  CONSTRAINT [DF_MbrPhone_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate] DATETIME2 (7) CONSTRAINT [DF_MbrPhone_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]   VARCHAR (50)  CONSTRAINT [DF_MbrPhone_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [CellPhone]       VARCHAR (50)  NULL,
    [HomePhone]       VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([mbrPhoneKey] ASC)
);

