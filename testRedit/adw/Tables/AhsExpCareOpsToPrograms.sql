﻿CREATE TABLE [adw].[AhsExpCareOpsToPrograms] (
    [AhsExpCareOpsProgramKey]  INT           IDENTITY (1, 1) NOT NULL,
    [CreatedDate]              DATETIME2 (7) DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]          DATETIME2 (7) DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]            VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LoadDate]                 DATE          NOT NULL,
    [SrcKey]                   INT           NOT NULL,
    [SrcTableName]             VARCHAR (100) NOT NULL,
    [CareOpBatchDate]          DATE          NOT NULL,
    [ClientKey]                INT           NULL,
    [ClientMemberKey]          VARCHAR (50)  NOT NULL,
    [QmMsrId]                  VARCHAR (20)  NOT NULL,
    [QmCntCat]                 VARCHAR (10)  NOT NULL,
    [QMDate]                   DATE          NULL,
    [Addressed]                INT           NOT NULL,
    [Exported]                 TINYINT       CONSTRAINT [DF_AhsExpCareOpsToProg_Exported] DEFAULT ((10)) NOT NULL,
    [ExportedDate]             DATE          DEFAULT ('01/01/1980') NOT NULL,
    [CalcQmCntCat]             VARCHAR (3)   NOT NULL,
    [ActiveMembersIsActive]    BIT           NULL,
    [ActiveMembersCsPlanName]  VARCHAR (50)  NULL,
    [CareOpToProgActive]       CHAR (1)      NULL,
    [DESTINATION_PROGRAM_NAME] VARCHAR (250) NULL,
    [programStartDate]         DATE          DEFAULT ('1/1/1980') NOT NULL,
    [ProgramCreateDate]        DATE          DEFAULT ('1/1/1980') NOT NULL,
    [ProgramEndDate]           DATE          DEFAULT ('1/1/1980') NOT NULL,
    [ProgramStatusCode]        VARCHAR (20)  DEFAULT ('Value Not Set') NOT NULL,
    [ReasonDescription]        VARCHAR (50)  DEFAULT ('Value Not Set') NOT NULL,
    [ReferalType]              VARCHAR (50)  DEFAULT ('Value Not Set') NOT NULL,
    PRIMARY KEY CLUSTERED ([AhsExpCareOpsProgramKey] ASC)
);

