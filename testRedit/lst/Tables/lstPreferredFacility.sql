CREATE TABLE [lst].[lstPreferredFacility] (
    [CreatedDate]          DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]      DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]        VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LoadDate]             DATE          NOT NULL,
    [DataDate]             DATE          NOT NULL,
    [SourceJobName]        VARCHAR (50)  NULL,
    [PreferredFacilityKey] INT           IDENTITY (1, 1) NOT NULL,
    [ClientKey]            INT           NOT NULL,
    [FacilityName]         VARCHAR (100) NULL,
    [FacilityType]         VARCHAR (10)  NULL,
    [State]                VARCHAR (35)  NULL,
    [Region]               VARCHAR (35)  NULL,
    [NPI]                  VARCHAR (10)  NULL,
    [ACTIVE]               CHAR (1)      DEFAULT ('Y') NULL,
    [EffectiveDate]        DATE          DEFAULT (getdate()) NULL,
    [ExpirationDate]       DATE          DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([PreferredFacilityKey] ASC)
);

