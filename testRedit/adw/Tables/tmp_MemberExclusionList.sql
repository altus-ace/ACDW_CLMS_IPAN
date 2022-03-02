CREATE TABLE [adw].[tmp_MemberExclusionList] (
    [tmp_MemberExclusionListKey] INT           IDENTITY (1, 1) NOT NULL,
    [CreatedDate]                DATETIME      DEFAULT (getdate()) NULL,
    [CreatedBy]                  VARCHAR (20)  DEFAULT (suser_sname()) NULL,
    [LastUpdatedDate]            DATETIME      DEFAULT (getdate()) NULL,
    [LastUpdatedBy]              VARCHAR (20)  DEFAULT (suser_sname()) NULL,
    [AdiKey]                     INT           NULL,
    [adiTableName]               VARCHAR (100) NULL,
    [SrcFileName]                VARCHAR (100) NULL,
    [LoadDate]                   DATE          NULL,
    [DataDate]                   DATE          NULL,
    [ClientKey]                  INT           NULL,
    [ClientMemberKey]            VARCHAR (50)  NULL,
    [AttribNPI]                  VARCHAR (10)  NULL,
    [AttribTIN]                  VARCHAR (10)  NULL,
    [EffectiveAsOfDate]          DATE          NULL,
    [EffectiveDate]              DATE          NULL,
    [ExpirationDate]             DATE          NULL,
    PRIMARY KEY CLUSTERED ([tmp_MemberExclusionListKey] ASC)
);

