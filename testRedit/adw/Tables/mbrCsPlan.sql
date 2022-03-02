CREATE TABLE [adw].[mbrCsPlan] (
    [mbrCsPlanKey]      INT           IDENTITY (1, 1) NOT NULL,
    [ClientMemberKey]   VARCHAR (50)  NOT NULL,
    [ClientKey]         INT           NULL,
    [adiKey]            INT           NOT NULL,
    [adiTableName]      VARCHAR (100) NOT NULL,
    [IsCurrent]         CHAR (1)      CONSTRAINT [DF_mbrCSPlan_recordFlag] DEFAULT ('Y') NOT NULL,
    [EffectiveDate]     DATE          NOT NULL,
    [ExpirationDate]    DATE          CONSTRAINT [DF_CsMbrPlan_ExpirationDate] DEFAULT ('12/31/9999') NOT NULL,
    [MbrCsSubPlan]      VARCHAR (100) NULL,
    [MbrCsSubPlanName]  VARCHAR (100) NULL,
    [planHistoryStatus] TINYINT       CONSTRAINT [DF_CsMbrPlan_PlanHistoryStatus] DEFAULT ((1)) NOT NULL,
    [LoadDate]          DATE          CONSTRAINT [DF_CsMbrPlan_LoadDate] DEFAULT (getdate()) NOT NULL,
    [DataDate]          DATE          NOT NULL,
    [CreatedDate]       DATETIME2 (7) CONSTRAINT [DF_mbrCsPlan_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (50)  CONSTRAINT [DF_mbrCsPlan_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]   DATETIME2 (7) CONSTRAINT [DF_mbrCsPlan_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]     VARCHAR (50)  CONSTRAINT [DF_mbrCsPlan_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([mbrCsPlanKey] ASC),
    CONSTRAINT [CK_CsMbrPlan_PlanStatus] CHECK ([planHistoryStatus]=(0) OR [planHistoryStatus]=(1))
);

