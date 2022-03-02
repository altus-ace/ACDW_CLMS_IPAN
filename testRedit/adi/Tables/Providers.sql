CREATE TABLE [adi].[Providers] (
    [IPAN_ProvidersKey] INT           IDENTITY (1, 1) NOT NULL,
    [SrcFileName]       VARCHAR (100) NOT NULL,
    [LoadDate]          DATE          NOT NULL,
    [DataDate]          DATE          NOT NULL,
    [CreatedDate]       DATETIME      CONSTRAINT [DF_adiIPAN_Providers_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (50)  CONSTRAINT [DF_adiIPAN_Providers_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]   DATETIME      CONSTRAINT [DF_adiIPAN_Providers_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]     VARCHAR (50)  CONSTRAINT [DF_adiIPAN_Providers_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [TIN]               VARCHAR (20)  NULL,
    [PracticeName]      VARCHAR (50)  NULL,
    [NPI]               VARCHAR (20)  NULL,
    [ProviderName]      VARCHAR (50)  NULL,
    [Site]              VARCHAR (20)  NULL,
    [Specialty]         VARCHAR (100) NULL,
    [LASTNAME]          VARCHAR (50)  NULL,
    [FIRSTNAME]         VARCHAR (50)  NULL,
    [PrimaryCare]       VARCHAR (20)  NULL,
    [AttribType]        VARCHAR (20)  NULL,
    [LoadStatus]        TINYINT       DEFAULT ((0)) NULL,
    CONSTRAINT [PK_IPAN_Providers] PRIMARY KEY CLUSTERED ([IPAN_ProvidersKey] ASC)
);

