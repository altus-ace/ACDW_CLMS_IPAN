CREATE TABLE [lst].[ListAceMapping] (
    [CreatedDate]      DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]  DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]    VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]      VARCHAR (150) NULL,
    [lstAceMappingKey] INT           IDENTITY (1, 1) NOT NULL,
    [ClientKey]        INT           NOT NULL,
    [MappingTypeKey]   INT           NULL,
    [IsActive]         TINYINT       NOT NULL,
    [Source]           VARCHAR (150) NOT NULL,
    [Destination]      VARCHAR (150) NOT NULL,
    [ACTIVE]           CHAR (1)      DEFAULT ('Y') NULL,
    [EffectiveDate]    DATE          DEFAULT ('2017-01-01') NULL,
    [ExpirationDate]   DATE          NOT NULL,
    PRIMARY KEY CLUSTERED ([lstAceMappingKey] ASC)
);

