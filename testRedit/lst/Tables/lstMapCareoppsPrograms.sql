CREATE TABLE [lst].[lstMapCareoppsPrograms] (
    [CreatedDate]              DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [LastUpdated]              DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]            VARCHAR (50)   DEFAULT (suser_sname()) NOT NULL,
    [SrcFileName]              VARCHAR (50)   NULL,
    [lstMapCareoppsPrograms]   INT            IDENTITY (1, 1) NOT NULL,
    [SOURCE]                   VARCHAR (50)   NULL,
    [SOURCE_MEASURE_NAME]      VARCHAR (1000) NULL,
    [SOURCE_SUB_MEASURE_NAME]  VARCHAR (1000) NULL,
    [DESTINATION]              VARCHAR (50)   NULL,
    [DESTINATION_PROGRAM_NAME] VARCHAR (1000) NULL,
    [IS_ACTIVE]                INT            NULL,
    [Criteria]                 CHAR (10)      NULL,
    [ACE_PROG_ID]              VARCHAR (50)   NULL,
    [ACTIVE]                   CHAR (1)       DEFAULT ('Y') NULL,
    [EffectiveDate]            DATE           DEFAULT (getdate()) NULL,
    [ExpirationDate]           DATE           DEFAULT ('2099-12-31') NULL,
    [ClientKey]                INT            DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([lstMapCareoppsPrograms] ASC)
);

