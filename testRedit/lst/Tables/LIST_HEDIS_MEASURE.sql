CREATE TABLE [lst].[LIST_HEDIS_MEASURE] (
    [CreatedDate]        DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]        DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]      VARCHAR (50)  DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]        VARCHAR (50)  NOT NULL,
    [HedisMeasureKey]    INT           IDENTITY (1, 1) NOT NULL,
    [MEASURE_ID]         VARCHAR (5)   NOT NULL,
    [MEASURE_NAME]       VARCHAR (255) NULL,
    [VALUE_SET_NAME]     VARCHAR (100) NULL,
    [VALUE_SET_OID]      VARCHAR (100) NULL,
    [A_LAST_UPDATE_DATE] DATETIME      DEFAULT (getdate()) NULL,
    [A_LAST_UPDATE_BY]   VARCHAR (20)  NULL,
    [A_LAST_UPDATE_FLAG] VARCHAR (1)   DEFAULT ('Y') NULL,
    [ACTIVE]             CHAR (1)      NULL,
    [EffectiveDate]      DATE          DEFAULT (getdate()) NULL,
    [ExpirationDate]     DATE          DEFAULT ('2099-12-31') NULL,
    [Status]             CHAR (1)      NULL,
    PRIMARY KEY CLUSTERED ([HedisMeasureKey] ASC)
);

