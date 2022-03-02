CREATE TABLE [adw].[AhsExpMemberByPcp] (
    [AhsExpMemberByPcpKey]          INT           IDENTITY (1, 1) NOT NULL,
    [CreatedDate]                   DATETIME2 (7) CONSTRAINT [DF_AhsExpMemberByPcp_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                     VARCHAR (50)  CONSTRAINT [DF_AhsExpMemberByPcp_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]               DATETIME2 (7) CONSTRAINT [DF_AhsExpMemberByPcp_LastUpdatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]                 VARCHAR (50)  CONSTRAINT [DF_AhsExpMemberByPcp_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    [Exported]                      TINYINT       CONSTRAINT [df_adwAhsExpMemberByPcp_Exported] DEFAULT ((10)) NOT NULL,
    [ExportedDate]                  DATE          DEFAULT ('01/01/1900') NOT NULL,
    [ClientMemberKey]               VARCHAR (50)  NOT NULL,
    [ClientKey]                     INT           NOT NULL,
    [fctMembershipKey]              INT           NOT NULL,
    [Exp_MEMBER_ID]                 VARCHAR (50)  NOT NULL,
    [Exp_PcpNpi]                    VARCHAR (10)  NOT NULL,
    [Exp_ProviderRelationshipType]  VARCHAR (50)  NOT NULL,
    [Exp_LOB]                       VARCHAR (20)  NOT NULL,
    [Exp_PcpEffectiveDate]          DATE          NOT NULL,
    [Exp_PcpTermDate]               DATE          NOT NULL,
    [Exp_MemberPcpAdditionalInfo_1] VARCHAR (100) NULL,
    [LoadDate]                      DATE          NOT NULL,
    PRIMARY KEY CLUSTERED ([AhsExpMemberByPcpKey] ASC)
);

