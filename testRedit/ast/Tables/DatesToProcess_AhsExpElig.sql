CREATE TABLE [ast].[DatesToProcess_AhsExpElig] (
    [Skey]            INT     IDENTITY (1, 1) NOT NULL,
    [LoadDate]        DATE    NOT NULL,
    [FirstDayOfMonth] DATE    NOT NULL,
    [LastDayOfMonth]  DATE    NOT NULL,
    [status_Load]     TINYINT DEFAULT ((0)) NOT NULL,
    [status_CalcELig] TINYINT DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Skey] ASC)
);

