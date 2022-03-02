CREATE TABLE [lst].[lstPlanMapping] (
    [CreatedDate]       DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]   DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]     VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]       VARCHAR (100) NULL,
    [lstPlanMappingKey] INT           IDENTITY (1, 1) NOT NULL,
    [ClientKey]         INT           DEFAULT ((0)) NULL,
    [TargetSystem]      VARCHAR (20)  NULL,
    [SourceValue]       VARCHAR (50)  NULL,
    [TargetValue]       VARCHAR (50)  NULL,
    [EffectiveDate]     DATE          DEFAULT ('2017-01-01') NULL,
    [ExpirationDate]    DATE          DEFAULT ('2099-12-31') NULL,
    [ACTIVE]            CHAR (1)      DEFAULT ('Y') NULL,
    PRIMARY KEY CLUSTERED ([lstPlanMappingKey] ASC)
);

