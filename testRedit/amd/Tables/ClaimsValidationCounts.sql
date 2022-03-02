CREATE TABLE [amd].[ClaimsValidationCounts] (
    [skey]           INT          IDENTITY (1, 1) NOT NULL,
    [ValidationType] VARCHAR (20) NULL,
    [cnt]            INT          NULL,
    [PrimarySvcYear] INT          NULL,
    [CatOfSvc]       VARCHAR (20) DEFAULT ('ALL') NULL,
    [CreatedDate]    DATE         DEFAULT (getdate()) NOT NULL,
    [CreatedBy]      VARCHAR (50) DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([skey] ASC)
);

