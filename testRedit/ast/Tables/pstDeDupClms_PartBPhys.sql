CREATE TABLE [ast].[pstDeDupClms_PartBPhys] (
    [srcAdiKey]       INT           NOT NULL,
    [CUR_CLM_UNIQ_ID] VARCHAR (20)  NOT NULL,
    [CLM_LINE_NUM]    INT           NOT NULL,
    [BENE_MBI_ID]     VARCHAR (13)  NOT NULL,
    [CLM_FROM_DT]     DATE          NOT NULL,
    [CLM_THRU_DT]     DATE          NOT NULL,
    [fileDate]        DATE          NOT NULL,
    [srcfileName]     VARCHAR (100) NOT NULL,
    [CreatedDate]     DATETIME2 (7) CONSTRAINT [df_astpstcDeDupClms_Cclf5_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       VARCHAR (20)  CONSTRAINT [df_astpstcDeDupClms_Cclf5_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([srcAdiKey] ASC)
);

