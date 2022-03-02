CREATE TABLE [adw].[mbrActivities] (
    [MbrActivityKey]        INT           IDENTITY (1, 1) NOT NULL,
    [ClientMemberKey]       VARCHAR (50)  NOT NULL,
    [ClientKey]             INT           NOT NULL,
    [ActivitySource]        VARCHAR (10)  CONSTRAINT [DF_MbrActivities_ActivitySource] DEFAULT ('AHS') NOT NULL,
    [CareActivityTypeName]  VARCHAR (100) NULL,
    [ActivityOutcome]       VARCHAR (100) NULL,
    [ActivityPerformedDate] DATE          NULL,
    [ActivityCreatedDate]   DATE          NULL,
    [OutcomeNotes]          VARCHAR (MAX) NULL,
    [VenueName]             VARCHAR (100) NULL,
    [srcFileName]           VARCHAR (100) NULL,
    [LoadDate]              DATE          NULL,
    [CreatedDate]           DATETIME      CONSTRAINT [DF_MbrActivity_CreateDate] DEFAULT (getdate()) NULL,
    [CreatedBy]             VARCHAR (50)  CONSTRAINT [DF_MbrActivity_CreateBy] DEFAULT (suser_sname()) NULL,
    [Status]                INT           NULL,
    PRIMARY KEY CLUSTERED ([MbrActivityKey] ASC)
);

