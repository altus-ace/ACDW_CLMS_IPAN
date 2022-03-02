CREATE TABLE [adi].[Attribution] (
    [IPAN_AttributionKey] INT           IDENTITY (1, 1) NOT NULL,
    [SrcFileName]         VARCHAR (100) NOT NULL,
    [LoadDate]            DATE          NOT NULL,
    [DataDate]            DATE          NOT NULL,
    [CreatedDate]         DATETIME      CONSTRAINT [DF_adiIPAN_Attribution_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]           VARCHAR (50)  CONSTRAINT [DF_adiIPAN_Attribution_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]     DATETIME      CONSTRAINT [DF_adiIPAN_Attribution_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]       VARCHAR (50)  CONSTRAINT [DF_adiIPAN_Attribution_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [OriginalMBI]         VARCHAR (50)  NULL,
    [CurrentMBI]          VARCHAR (50)  NULL,
    [BMTIN]               VARCHAR (20)  NULL,
    [BMNPI]               VARCHAR (20)  NULL,
    [CYTIN]               VARCHAR (20)  NULL,
    [CYNPI]               VARCHAR (20)  NULL,
    [Year_2018]           VARCHAR (10)  NULL,
    [Year_2021Q2]         VARCHAR (10)  NULL,
    [RowStatus]           TINYINT       DEFAULT ((0)) NULL,
    CONSTRAINT [PK_IPAN_Attribution] PRIMARY KEY CLUSTERED ([IPAN_AttributionKey] ASC)
);

