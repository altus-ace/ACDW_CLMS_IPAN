CREATE TABLE [ast].[Claim_03_Header_LatestEffective] (
    [clmSKey]            VARCHAR (50)  NOT NULL,
    [LatestClaimAdiKey]  INT           NOT NULL,
    [LatestClaimID]      VARCHAR (50)  NOT NULL,
    [ReplacesAdiKey]     INT           NOT NULL,
    [ReplacesClaimID]    VARCHAR (50)  NOT NULL,
    [ProcessDate]        DATE          NOT NULL,
    [ClaimAdjCode]       SMALLINT      NOT NULL,
    [LatestClaimRankNum] SMALLINT      NOT NULL,
    [SrcClaimType]       CHAR (5)      CONSTRAINT [df_astCLaimHeader03LatestEffClaim_SrcClaimType] DEFAULT ('INST') NOT NULL,
    [CreatedDate]        DATETIME2 (7) CONSTRAINT [df_astCLaimHeader03LatestEffClaim_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          VARCHAR (20)  CONSTRAINT [df_astCLaimHeader03LatestEffClaim_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([clmSKey] ASC, [ReplacesAdiKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ndx_AstClaim03HdrLatestEff_LatestClaimID]
    ON [ast].[Claim_03_Header_LatestEffective]([LatestClaimID] ASC);

