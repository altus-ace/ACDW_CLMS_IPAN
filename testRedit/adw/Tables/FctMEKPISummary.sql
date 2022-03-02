CREATE TABLE [adw].[FctMEKPISummary] (
    [FctFctMEKpiSumKey] INT             IDENTITY (1, 1) NOT NULL,
    [CreatedDate]       DATETIME        DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (50)    DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]   DATETIME        DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]     VARCHAR (50)    DEFAULT (suser_sname()) NOT NULL,
    [AdiKey]            INT             NULL,
    [SrcFileName]       VARCHAR (100)   NULL,
    [AdwTableName]      VARCHAR (100)   NULL,
    [LoadDate]          DATE            DEFAULT (getdate()) NULL,
    [DataDate]          DATE            NULL,
    [EffectiveAsOfDate] DATE            NULL,
    [KPI_ID]            INT             NULL,
    [KPI]               VARCHAR (50)    NULL,
    [KPIEffYear]        INT             NULL,
    [KPIEffMth]         INT             NULL,
    [Numerator]         NUMERIC (15, 2) NULL,
    [Denominator]       NUMERIC (15, 2) NULL,
    [Value]             NUMERIC (15, 2) NULL,
    PRIMARY KEY CLUSTERED ([FctFctMEKpiSumKey] ASC)
);

