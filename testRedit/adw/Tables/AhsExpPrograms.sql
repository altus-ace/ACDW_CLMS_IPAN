CREATE TABLE [adw].[AhsExpPrograms] (
    [AhsExpProgramsKey]    INT           IDENTITY (1, 1) NOT NULL,
    [CreatedDate]          DATE          CONSTRAINT [DF_AhsExpPrograms_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            VARCHAR (50)  CONSTRAINT [DF_AhsExpPrograms_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]      DATE          CONSTRAINT [DF_AhsExpPrograms_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]        VARCHAR (50)  CONSTRAINT [DF_AhsExpPrograms_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LoadDate]             DATE          NOT NULL,
    [Exported]             TINYINT       CONSTRAINT [df_adwAhsExpPrograms_Exported] DEFAULT ((10)) NULL,
    [ExportedDate]         DATE          CONSTRAINT [DF_AhsExpProgramsExportedDate] DEFAULT ('01/01/1900') NULL,
    [ClientKey]            INT           NOT NULL,
    [ClientMemberKey]      VARCHAR (50)  NOT NULL,
    [ProgramID]            INT           NOT NULL,
    [ExpLobName]           VARCHAR (50)  NULL,
    [ExpProgram_Name]      VARCHAR (100) NULL,
    [ExpEnrollDate]        DATE          NULL,
    [ExpCreateDate]        DATE          NULL,
    [ExpMemberID]          VARCHAR (50)  NULL,
    [ExpEnrollEndDate]     DATE          NULL,
    [ExpProgramstatus]     VARCHAR (50)  NULL,
    [ExpReasonDescription] VARCHAR (50)  NULL,
    [ExpReferalType]       VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([AhsExpProgramsKey] ASC)
);

