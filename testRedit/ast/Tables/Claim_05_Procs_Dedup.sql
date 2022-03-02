CREATE TABLE [ast].[Claim_05_Procs_Dedup] (
    [ClaimProcDedupKey] INT           IDENTITY (1, 1) NOT NULL,
    [ProcAdiKey]        INT           NOT NULL,
    [ProcNumber]        SMALLINT      NOT NULL,
    [SrcClaimType]      CHAR (5)      CONSTRAINT [df_astpstcPrcDeDupUrns_SrcClaimType] DEFAULT ('INST') NOT NULL,
    [CreatedDate]       DATETIME2 (7) CONSTRAINT [df_astpstcPrcDeDupUrns_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         VARCHAR (20)  CONSTRAINT [df_astpstcPrcDeDupUrns_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ClaimProcDedupKey] ASC)
);

