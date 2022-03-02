CREATE TABLE [ast].[Claim_04_Detail_Dedup] (
    [pstClmDetailKey]            INT           IDENTITY (1, 1) NOT NULL,
    [ClaimDetailSrcAdiKey]       INT           NOT NULL,
    [ClaimDetailSrcAdiTableName] VARCHAR (100) NOT NULL,
    [AdiDataDate]                DATE          NOT NULL,
    [ClaimSeqClaimId]            VARCHAR (50)  NOT NULL,
    [ClaimDetailLineNumber]      INT           NOT NULL,
    [SrcClaimType]               CHAR (5)      CONSTRAINT [df_astpstcLnsDeDupUrns_SrcClaimType] DEFAULT ('INST') NOT NULL,
    [CreatedDate]                DATETIME2 (7) CONSTRAINT [df_astpstcLnsDeDupUrns_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                  VARCHAR (20)  CONSTRAINT [df_astpstcLnsDeDupUrns_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([pstClmDetailKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ndx_AstClaim04DetailsDedup_ClaimDetialSrcAdiKe_SrcClmType]
    ON [ast].[Claim_04_Detail_Dedup]([ClaimDetailSrcAdiKey] ASC, [SrcClaimType] ASC);

