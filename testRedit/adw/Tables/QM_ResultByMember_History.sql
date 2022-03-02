CREATE TABLE [adw].[QM_ResultByMember_History] (
    [QM_ResultByMbr_HistoryKey] INT           IDENTITY (1, 1) NOT NULL,
    [ClientKey]                 INT           NULL,
    [ClientMemberKey]           VARCHAR (50)  NOT NULL,
    [QmMsrId]                   VARCHAR (20)  NOT NULL,
    [QmCntCat]                  VARCHAR (10)  NOT NULL,
    [QMDate]                    DATE          CONSTRAINT [DF_QM_ResultByMbr_History_QmDate] DEFAULT (CONVERT([date],getdate())) NULL,
    [CreateDate]                DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreateBy]                  VARCHAR (50)  DEFAULT (suser_name()) NOT NULL,
    [LastUpdatedDate]           DATETIME      CONSTRAINT [DF_QM_ResultByMbr_History_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]             VARCHAR (50)  CONSTRAINT [DF_QM_ResultByMbr_History_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [AdiKey]                    INT           CONSTRAINT [DF_QM_ResutlByMbr_History_AdiKey] DEFAULT ((0)) NULL,
    [adiTableName]              VARCHAR (150) DEFAULT ('No Table name') NULL,
    [Addressed]                 INT           DEFAULT ((0)) NULL,
    [QmMeasYear]                CHAR (4)      NULL,
    [QMMbrEffectiveDate]        DATE          NULL,
    CONSTRAINT [QmResultsByMemberHistory_pk] PRIMARY KEY CLUSTERED ([QM_ResultByMbr_HistoryKey] ASC)
);

