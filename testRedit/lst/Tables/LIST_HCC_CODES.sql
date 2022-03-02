CREATE TABLE [lst].[LIST_HCC_CODES] (
    [CreatedDate]     DATETIME       DEFAULT (getdate()) NULL,
    [CreatedBy]       VARCHAR (50)   DEFAULT (suser_sname()) NULL,
    [LastUpdated]     DATETIME       DEFAULT (getdate()) NULL,
    [LastUpdatedBy]   VARCHAR (50)   DEFAULT (suser_sname()) NULL,
    [SrcFileName]     VARCHAR (50)   NULL,
    [HccSkey]         INT            IDENTITY (1, 1) NOT NULL,
    [HCC_No]          INT            NOT NULL,
    [HCC_VERSION]     VARCHAR (20)   NULL,
    [HCC_Description] NVARCHAR (MAX) NULL,
    [Disease_Hier]    NVARCHAR (50)  NULL,
    [ACTIVE]          CHAR (1)       DEFAULT ('Y') NULL,
    [EffectiveDate]   DATE           DEFAULT (getdate()) NULL,
    [ExpirationDate]  DATE           DEFAULT ('2099-12-31') NULL,
    PRIMARY KEY CLUSTERED ([HccSkey] ASC)
);

