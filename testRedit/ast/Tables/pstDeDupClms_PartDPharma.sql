CREATE TABLE [ast].[pstDeDupClms_PartDPharma] (
    [urn]         INT           NOT NULL,
    [CreatedDate] DATETIME2 (7) CONSTRAINT [df_astpstcDeDupClms_PartDPharma_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]   VARCHAR (20)  CONSTRAINT [df_astpstcDeDupClms_PartDPharma_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([urn] ASC)
);

