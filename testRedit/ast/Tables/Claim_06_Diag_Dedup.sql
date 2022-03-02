CREATE TABLE [ast].[Claim_06_Diag_Dedup] (
    [ClaimDiagDedupKey] INT           IDENTITY (1, 1) NOT NULL,
    [DiagAdiKey]        INT           NOT NULL,
    [DiagNum]           SMALLINT      NOT NULL,
    [SrcClaimType]      CHAR (5)      CONSTRAINT [df_astpstcDgDeDupUrns_SrcClaimType] DEFAULT ('INST') NOT NULL,
    [CreatedDate]       DATETIME2 (7) CONSTRAINT [df_astpstcDgDeDupUrns_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (20)  CONSTRAINT [df_astpstcDgDeDupUrns_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ClaimDiagDedupKey] ASC)
);

