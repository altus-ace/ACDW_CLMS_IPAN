CREATE TABLE [adw].[DimPCVisitsByTIN] (
    [DimVisitsByTINSkey] INT           IDENTITY (1, 1) NOT NULL,
    [CreatedDate]        DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]    DATE          DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]      VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]        VARCHAR (100) NOT NULL,
    [LoadDate]           DATE          NOT NULL,
    [DataDate]           DATE          NOT NULL,
    [MBI]                VARCHAR (50)  NULL,
    [HICN]               VARCHAR (50)  NULL,
    [FirstName]          VARCHAR (50)  NULL,
    [LastName]           VARCHAR (50)  NULL,
    [Sex]                VARCHAR (5)   NULL,
    [DOB]                DATE          NULL,
    [DOD]                DATE          NULL,
    [TIN]                VARCHAR (25)  NULL,
    [PCServices]         INT           NULL,
    [MbrYear]            SMALLINT      NULL,
    [MbrMonth]           TINYINT       NULL,
    PRIMARY KEY CLUSTERED ([DimVisitsByTINSkey] ASC)
);

