CREATE TABLE [amd].[AceEtlAudit] (
    [EtlAuditPkey]         INT           IDENTITY (1, 1) NOT NULL,
    [EtlJobStatus]         SMALLINT      NOT NULL,
    [EltJobType]           SMALLINT      CONSTRAINT [DF_amdAceEtlAudit_JobType] DEFAULT ((2)) NOT NULL,
    [ClientKey]            INT           NOT NULL,
    [JobName]              VARCHAR (200) NULL,
    [ActionStartTime]      DATETIME2 (7) NULL,
    [ActionStopTime]       DATETIME2 (7) NULL,
    [InputSourceName]      VARCHAR (200) NULL,
    [InputCount]           INT           NULL,
    [DestinationName]      VARCHAR (200) NULL,
    [DestinationCount]     INT           NULL,
    [ErrorDestinationName] VARCHAR (200) NULL,
    [ErrorCount]           INT           NULL,
    [CreatedDate]          DATETIME2 (7) CONSTRAINT [DF_amdAceEtlAudit_CreatedDate] DEFAULT (getdate()) NULL,
    [CreatedBy]            VARCHAR (200) CONSTRAINT [DF_amdAceEtlAudit_CreatedBy] DEFAULT (suser_sname()) NULL,
    PRIMARY KEY CLUSTERED ([EtlAuditPkey] ASC)
);

