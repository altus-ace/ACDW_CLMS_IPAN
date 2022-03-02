CREATE TABLE [lst].[lstNdcDrugPackage] (
    [CreatedDate]           DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]             VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]       DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]         VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]           VARCHAR (100)  NULL,
    [lstNdcDrugPackageKey]  INT            IDENTITY (1, 1) NOT NULL,
    [PRODUCTID]             VARCHAR (60)   NOT NULL,
    [PRODUCTNDC]            VARCHAR (20)   NOT NULL,
    [NDCPACKAGECODE_SRC]    VARCHAR (100)  NOT NULL,
    [NdcPackageCode_Clean]  VARCHAR (100)  NOT NULL,
    [PACKAGEDESCRIPTION]    VARCHAR (1000) NULL,
    [srcStartMarketingDate] VARCHAR (100)  NULL,
    [srcEndMarketingDate]   VARCHAR (100)  NULL,
    [StartMarketingDate]    VARCHAR (50)   NULL,
    [EndMarketingDate]      VARCHAR (50)   NULL,
    [NdcExcludeFlag]        VARCHAR (50)   NULL,
    [SamplePackage]         VARCHAR (50)   NULL,
    [ACTIVE]                CHAR (1)       DEFAULT ('Y') NULL,
    [EffectiveDate]         DATE           DEFAULT (getdate()) NULL,
    [ExpirationDate]        DATE           DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([lstNdcDrugPackageKey] ASC)
);

