﻿CREATE TABLE [adi].[CCLFB] (
    [URN]                            INT           IDENTITY (1, 1) NOT NULL,
    [CUR_CLM_UNIQ_ID]                VARCHAR (13)  NULL,
    [CLM_LINE_NUM]                   VARCHAR (10)  NULL,
    [BENE_MBI_ID]                    VARCHAR (11)  NULL,
    [BENE_HIC_NUM]                   VARCHAR (11)  NULL,
    [CLM_TYPE_CD]                    VARCHAR (2)   NULL,
    [CLM_LINE_NGACO_PBPMT_SW]        VARCHAR (1)   NULL,
    [CLM_LINE_NGACO_PDSCHRG_HCBS_SW] VARCHAR (1)   NULL,
    [CLM_LINE_NGACO_SNF_WVR_SW]      VARCHAR (1)   NULL,
    [CLM_LINE_NGACO_TLHLTH_SW]       VARCHAR (1)   NULL,
    [CLM_LINE_NGACO_CPTATN_SW]       VARCHAR (1)   NULL,
    [CLM_DEMO_1ST_NUM]               VARCHAR (2)   NULL,
    [CLM_DEMO_2ND_NUM]               VARCHAR (2)   NULL,
    [CLM_DEMO_3RD_NUM]               VARCHAR (2)   NULL,
    [CLM_DEMO_4TH_NUM]               VARCHAR (2)   NULL,
    [CLM_DEMO_5TH_NUM]               VARCHAR (2)   NULL,
    [CLM_PBP_INCLSN_AMT]             MONEY         NULL,
    [CLM_PBP_RDCTN_AMT]              MONEY         NULL,
    [SrcFileName]                    VARCHAR (100) NULL,
    [FileDate]                       DATE          NULL,
    [originalFileName]               VARCHAR (100) NULL,
    [CreateDate]                     DATETIME      NULL,
    [CreateBy]                       VARCHAR (100) NULL,
    CONSTRAINT [PK__CCLFB__C5B1000EBA2DC3A2] PRIMARY KEY CLUSTERED ([URN] ASC)
);

