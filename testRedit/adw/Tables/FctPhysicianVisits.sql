﻿CREATE TABLE [adw].[FctPhysicianVisits] (
    [FctPhysicianVisitsSkey] INT           IDENTITY (1, 1) NOT NULL,
    [CreatedDate]            DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]        DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]          VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [AdiKey]                 INT           NULL,
    [SrcFileName]            VARCHAR (100) NULL,
    [AdiTableName]           VARCHAR (100) NULL,
    [LoadDate]               DATE          NULL,
    [DataDate]               DATE          NULL,
    [ClientKey]              INT           NULL,
    [ClientMemberKey]        VARCHAR (50)  NULL,
    [EffectiveAsOfDate]      DATE          NULL,
    [VisitExamType]          VARCHAR (50)  NULL,
    [SEQ_ClaimID]            VARCHAR (50)  NULL,
    [PrimaryServiceDate]     DATE          NULL,
    [SVCProviderNPI]         VARCHAR (10)  NULL,
    [SVCProviderName]        VARCHAR (100) NULL,
    [SVCProviderSpecialty]   VARCHAR (50)  NULL,
    [PrimaryDiagnosis]       VARCHAR (100) NULL,
    [CPT]                    VARCHAR (10)  NULL,
    [AttribNPI]              VARCHAR (10)  NULL,
    [AttribTIN]              VARCHAR (10)  NULL,
    [SVCProviderType]        VARCHAR (1)   NULL,
    PRIMARY KEY CLUSTERED ([FctPhysicianVisitsSkey] ASC)
);

