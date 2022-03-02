CREATE TABLE [adw].[AhsExpEligiblity] (
    [AhsExpEligibilityKey]            INT           IDENTITY (1, 1) NOT NULL,
    [CreatedDate]                     DATETIME2 (7) CONSTRAINT [DF_AhsExpEligiblity_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                       VARCHAR (50)  CONSTRAINT [DF_AhsExpEligiblity_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]                 DATETIME2 (7) CONSTRAINT [DF_AhsExpEligiblity_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]                   VARCHAR (50)  CONSTRAINT [DF_AhsExpEligiblity_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [Exported]                        TINYINT       CONSTRAINT [df_adwAhsExpEligiblity_Exported] DEFAULT ((10)) NOT NULL,
    [ExportedDate]                    DATE          DEFAULT ('01/01/1900') NOT NULL,
    [ClientMemberKey]                 VARCHAR (50)  NOT NULL,
    [ClientKey]                       INT           NOT NULL,
    [fctMembershipKey]                INT           NOT NULL,
    [Exp_MEMBER_ID]                   VARCHAR (50)  NOT NULL,
    [Exp_LOB]                         VARCHAR (20)  NOT NULL,
    [Exp_BENEFIT PLAN]                VARCHAR (50)  NOT NULL,
    [Exp_INTERNAL/EXTERNAL INDICATOR] CHAR (10)     NOT NULL,
    [Exp_START_DATE]                  DATE          NOT NULL,
    [Exp_END_DATE]                    DATE          NOT NULL,
    [LoadDate]                        DATE          NOT NULL,
    PRIMARY KEY CLUSTERED ([AhsExpEligibilityKey] ASC)
);

