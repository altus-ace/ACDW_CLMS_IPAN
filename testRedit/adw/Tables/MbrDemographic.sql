﻿CREATE TABLE [adw].[MbrDemographic] (
    [mbrDemographicKey]           INT           IDENTITY (1, 1) NOT NULL,
    [ClientMemberKey]             VARCHAR (50)  NOT NULL,
    [ClientKey]                   INT           NULL,
    [adiKey]                      INT           NOT NULL,
    [adiTableName]                VARCHAR (100) NOT NULL,
    [IsCurrent]                   CHAR (1)      CONSTRAINT [DF_mbrDemo_recordFlag] DEFAULT ('Y') NOT NULL,
    [EffectiveDate]               DATE          NOT NULL,
    [ExpirationDate]              DATE          CONSTRAINT [DF_MbrDemographicExpirationDate] DEFAULT ('12/31/9999') NOT NULL,
    [LastName]                    VARCHAR (100) NULL,
    [FirstName]                   VARCHAR (100) NULL,
    [MiddleName]                  VARCHAR (100) NULL,
    [SSN]                         VARCHAR (15)  NULL,
    [Gender]                      CHAR (5)      NULL,
    [DOB]                         DATE          NULL,
    [mbrInsuranceCardIdNum]       VARCHAR (20)  NULL,
    [MedicaidID]                  VARCHAR (15)  NULL,
    [HICN]                        VARCHAR (11)  NULL,
    [MBI]                         VARCHAR (11)  NULL,
    [MedicareID]                  VARCHAR (15)  NULL,
    [Ethnicity]                   VARCHAR (20)  NULL,
    [Race]                        VARCHAR (20)  NULL,
    [PrimaryLanguage]             VARCHAR (20)  NULL,
    [LoadDate]                    DATE          NOT NULL,
    [DataDate]                    DATE          NOT NULL,
    [CreatedDate]                 DATETIME2 (7) CONSTRAINT [DF_MbrDemographic_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                   VARCHAR (50)  CONSTRAINT [DF_MbrDemographic_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]             DATETIME2 (7) CONSTRAINT [DF_MbrDemographic_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]               VARCHAR (50)  CONSTRAINT [DF_MbrDemographic_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [DOD]                         DATE          CONSTRAINT [DF_MbrDemoDOD] DEFAULT ('12/31/3099') NULL,
    [MemberOriginalEffectiveDate] DATE          NULL,
    PRIMARY KEY CLUSTERED ([mbrDemographicKey] ASC)
);

