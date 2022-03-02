CREATE TABLE [adw].[MbrEmail] (
    [mbrEmailKey]     INT           IDENTITY (1, 1) NOT NULL,
    [LoadDate]        DATE          NOT NULL,
    [DataDate]        DATE          NOT NULL,
    [CreatedDate]     DATETIME2 (7) CONSTRAINT [DF_MbrEmail_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (50)  CONSTRAINT [DF_MbrEmail_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate] DATETIME2 (7) CONSTRAINT [DF_MbrEmail_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]   VARCHAR (50)  CONSTRAINT [DF_MbrEmail_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ClientMemberKey] VARCHAR (50)  NOT NULL,
    [ClientKey]       INT           NULL,
    [adiKey]          INT           NOT NULL,
    [adiTableName]    VARCHAR (100) NOT NULL,
    [IsCurrent]       CHAR (1)      CONSTRAINT [DF_mbrEmail_recordFlag] DEFAULT ('Y') NOT NULL,
    [EffectiveDate]   DATE          NOT NULL,
    [ExpirationDate]  DATE          CONSTRAINT [DF_MbrEmailExpirationDate] DEFAULT ('12/31/9999') NOT NULL,
    [EmailType]       INT           NOT NULL,
    [EmailAddress]    VARCHAR (100) NOT NULL,
    [IsPrimary]       TINYINT       CONSTRAINT [DF_MbrEmail_IsPrimary] DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([mbrEmailKey] ASC),
    CONSTRAINT [CK_MbrEmail_IsPrimary] CHECK ([IsPrimary]=(1) OR [IsPrimary]=(0))
);

