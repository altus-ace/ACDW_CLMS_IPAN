CREATE TABLE [adw].[FctEDToIPVisits] (
    [FctEDToIPVisitskey] INT           IDENTITY (1, 1) NOT NULL,
    [CreatedDate]        DATETIME      DEFAULT (getdate()) NULL,
    [CreatedBy]          VARCHAR (20)  DEFAULT (suser_sname()) NULL,
    [LastUpdatedDate]    DATETIME      DEFAULT (getdate()) NULL,
    [LastUpdatedBy]      VARCHAR (20)  DEFAULT (suser_sname()) NULL,
    [AdiKey]             INT           NULL,
    [adiTableName]       VARCHAR (100) NULL,
    [SrcFileName]        VARCHAR (100) NULL,
    [LoadDate]           DATE          NULL,
    [DataDate]           DATE          NULL,
    [ClientKey]          INT           NULL,
    [ClientMemberKey]    VARCHAR (50)  NULL,
    [EffectiveAsOfDate]  DATE          NULL,
    [ClaimID_ER]         VARCHAR (50)  NULL,
    [ClaimID_IP]         VARCHAR (50)  NULL,
    [PrimSvcDate_ER]     DATE          NULL,
    [SvcToDate_ER]       DATE          NULL,
    [PrimSvcDate_IP]     DATE          NULL,
    [SvcToDate_IP]       DATE          NULL,
    [AttribNPI]          VARCHAR (10)  NULL,
    PRIMARY KEY CLUSTERED ([FctEDToIPVisitskey] ASC)
);

