CREATE TABLE [adw].[Claims_Headers] (
    [SEQ_CLAIM_ID]            VARCHAR (50)  NOT NULL,
    [SUBSCRIBER_ID]           VARCHAR (50)  NULL,
    [CLAIM_NUMBER]            VARCHAR (50)  NULL,
    [CATEGORY_OF_SVC]         VARCHAR (50)  NULL,
    [PAT_CONTROL_NO]          VARCHAR (50)  NULL,
    [ICD_PRIM_DIAG]           VARCHAR (10)  NULL,
    [PRIMARY_SVC_DATE]        DATE          NULL,
    [SVC_TO_DATE]             DATE          NULL,
    [CLAIM_THRU_DATE]         DATE          NULL,
    [POST_DATE]               DATETIME      NULL,
    [CHECK_DATE]              DATETIME      NULL,
    [CHECK_NUMBER]            VARCHAR (20)  NULL,
    [DATE_RECEIVED]           DATETIME      NULL,
    [ADJUD_DATE]              DATETIME      NULL,
    [CMS_CertificationNumber] VARCHAR (12)  NULL,
    [SVC_PROV_ID]             VARCHAR (20)  NULL,
    [SVC_PROV_FULL_NAME]      VARCHAR (250) NULL,
    [SVC_PROV_NPI]            VARCHAR (20)  NULL,
    [PROV_SPEC]               VARCHAR (20)  NULL,
    [PROV_TYPE]               VARCHAR (20)  NULL,
    [PROVIDER_PAR_STAT]       VARCHAR (20)  NULL,
    [ATT_PROV_ID]             VARCHAR (50)  NULL,
    [ATT_PROV_FULL_NAME]      VARCHAR (250) NULL,
    [ATT_PROV_NPI]            VARCHAR (20)  NULL,
    [REF_PROV_ID]             VARCHAR (20)  NULL,
    [REF_PROV_FULL_NAME]      VARCHAR (250) NULL,
    [VENDOR_ID]               VARCHAR (20)  NULL,
    [VEND_FULL_NAME]          VARCHAR (250) NULL,
    [IRS_TAX_ID]              VARCHAR (20)  NULL,
    [DRG_CODE]                VARCHAR (20)  NULL,
    [BILL_TYPE]               VARCHAR (20)  NULL,
    [ADMISSION_DATE]          DATE          NULL,
    [AUTH_NUMBER]             VARCHAR (50)  NULL,
    [ADMIT_SOURCE_CODE]       VARCHAR (20)  NULL,
    [ADMIT_HOUR]              VARCHAR (20)  NULL,
    [DISCHARGE_HOUR]          VARCHAR (20)  NULL,
    [PATIENT_STATUS]          VARCHAR (20)  NULL,
    [CLAIM_STATUS]            VARCHAR (20)  NULL,
    [PROCESSING_STATUS]       VARCHAR (20)  NULL,
    [CLAIM_TYPE]              VARCHAR (20)  NULL,
    [TOTAL_BILLED_AMT]        MONEY         NULL,
    [TOTAL_PAID_AMT]          MONEY         NULL,
    [SrcAdiTableName]         VARCHAR (100) NULL,
    [SrcAdiKey]               INT           NOT NULL,
    [LoadDate]                DATETIME      NOT NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF__Claims_He__Creat__01142BA1] DEFAULT (sysdatetime()) NOT NULL,
    [CreatedBy]               VARCHAR (50)  CONSTRAINT [DF__Claims_He__Creat__02084FDA] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]         DATETIME      CONSTRAINT [DF__Claims_He__LastU__02FC7413] DEFAULT (sysdatetime()) NOT NULL,
    [LastUpdatedBy]           VARCHAR (50)  CONSTRAINT [DF__Claims_He__LastU__03F0984C] DEFAULT (suser_sname()) NOT NULL,
    [CalcdTotalBilledAmount]  MONEY         DEFAULT ((0)) NULL,
    [BENE_PTNT_STUS_CD]       INT           NULL,
    [DISCHARGE_DISPO]         INT           NULL,
    [CalcdTotalPaidAmount]    MONEY         DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Claims_Headers_SeqClaimId] PRIMARY KEY CLUSTERED ([SEQ_CLAIM_ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'based on the Claim Type', @level0type = N'SCHEMA', @level0name = N'adw', @level1type = N'TABLE', @level1name = N'Claims_Headers', @level2type = N'COLUMN', @level2name = N'CATEGORY_OF_SVC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique Patient Identifier Number', @level0type = N'SCHEMA', @level0name = N'adw', @level1type = N'TABLE', @level1name = N'Claims_Headers', @level2type = N'COLUMN', @level2name = N'PAT_CONTROL_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'From CMS Provider specialty List', @level0type = N'SCHEMA', @level0name = N'adw', @level1type = N'TABLE', @level1name = N'Claims_Headers', @level2type = N'COLUMN', @level2name = N'PROV_SPEC';

