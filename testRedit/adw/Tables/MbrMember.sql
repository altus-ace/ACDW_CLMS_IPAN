CREATE TABLE [adw].[MbrMember] (
    [mbrMemberKey]    INT           IDENTITY (1, 1) NOT NULL,
    [ClientMemberKey] VARCHAR (50)  NOT NULL,
    [ClientKey]       INT           NULL,
    [MstrMrnKey]      NUMERIC (15)  NOT NULL,
    [adiKey]          INT           NOT NULL,
    [adiTableName]    VARCHAR (100) NOT NULL,
    [IsCurrent]       CHAR (1)      CONSTRAINT [DF_mbrMember_IsCurrent] DEFAULT ('Y') NOT NULL,
    [LoadDate]        DATE          NOT NULL,
    [DataDate]        DATE          NOT NULL,
    [CreatedDate]     DATETIME2 (7) CONSTRAINT [DF_MbrMember_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (50)  CONSTRAINT [DF_MbrMember_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate] DATETIME2 (7) CONSTRAINT [DF_MbrMember_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]   VARCHAR (50)  CONSTRAINT [DF_MbrMember_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [ExpirationDate]  DATE          DEFAULT ('2099-12-31') NULL,
    [EffectiveDate]   DATE          NULL,
    PRIMARY KEY CLUSTERED ([mbrMemberKey] ASC)
);

