CREATE TABLE [ast].[MbrStg2_MbrData] (
    [mbrStg2_MbrDataUrn]          INT             IDENTITY (1, 1) NOT NULL,
    [ClientSubscriberId]          VARCHAR (50)    NULL,
    [ClientKey]                   VARCHAR (50)    NULL,
    [MstrMrnKey]                  NUMERIC (15)    CONSTRAINT [DF_astMbrStg2_MbrData_MstrMrnKey] DEFAULT ((-1)) NOT NULL,
    [LoadType]                    VARCHAR (5)     CONSTRAINT [DF_astMbrStg2_MbrData_LoadType] DEFAULT ('P') NULL,
    [mbrLastName]                 VARCHAR (100)   NULL,
    [mbrFirstName]                VARCHAR (100)   NULL,
    [mbrMiddleName]               VARCHAR (100)   CONSTRAINT [df_MI] DEFAULT ('') NULL,
    [mbrSSN]                      VARCHAR (15)    NULL,
    [mbrGENDER]                   VARCHAR (5)     CONSTRAINT [df_gender] DEFAULT ('') NULL,
    [mbrDob]                      DATE            NULL,
    [mbrInsuranceCardIdNum]       VARCHAR (20)    NULL,
    [mbrMEDICAID_NO]              VARCHAR (15)    NULL,
    [mbrMEDICARE_ID]              VARCHAR (15)    NULL,
    [HICN]                        VARCHAR (11)    NULL,
    [MBI]                         VARCHAR (11)    NULL,
    [mbrEthnicity]                VARCHAR (20)    CONSTRAINT [DF_EmbrEthnicity] DEFAULT ('') NULL,
    [mbrRace]                     VARCHAR (20)    CONSTRAINT [DF_mbrRace] DEFAULT ('') NULL,
    [mbrPrimaryLanguage]          VARCHAR (20)    NULL,
    [prvNPI]                      VARCHAR (10)    NULL,
    [prvTIN]                      VARCHAR (10)    NULL,
    [prvAutoAssign]               VARCHAR (10)    NULL,
    [prvClientEffective]          DATE            NULL,
    [prvClientExpiration]         DATE            NULL,
    [plnProductPlan]              VARCHAR (50)    NULL,
    [plnProductSubPlan]           VARCHAR (100)   NULL,
    [plnProductSubPlanName]       VARCHAR (50)    NULL,
    [plnMbrIsDualCoverage]        VARCHAR (20)    NULL,
    [plnClientPlanEffective]      DATE            NULL,
    [SrcFileName]                 VARCHAR (100)   NULL,
    [AdiTableName]                VARCHAR (100)   NULL,
    [AdiKey]                      INT             NULL,
    [stgRowStatus]                VARCHAR (20)    CONSTRAINT [DF_astMbrStg2_MbrData_StgRowStatus] DEFAULT ('Not Valid') NOT NULL,
    [LoadDate]                    DATE            NULL,
    [DataDate]                    DATE            NULL,
    [CreateDate]                  DATETIME        CONSTRAINT [DF_astMbrStg2_MbrData_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                    VARCHAR (50)    CONSTRAINT [DF_astMbrStg2_MbrData_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [plnClientPlanEndDate]        DATE            NULL,
    [stgRowAction]                VARCHAR (10)    DEFAULT ('Upsert') NOT NULL,
    [Member_Dual_Eligible_Flag]   VARCHAR (20)    NULL,
    [MbrState]                    CHAR (2)        NOT NULL,
    [MemberStatus]                VARCHAR (50)    NULL,
    [MemberOriginalEffectiveDate] DATE            NULL,
    [RiskScore]                   DECIMAL (5)     NULL,
    [OpportunityScore]            DECIMAL (5)     NULL,
    [MbrCity]                     VARCHAR (50)    NULL,
    [SubscriberID_Client]         VARCHAR (50)    NULL,
    [Indicator834]                VARCHAR (50)    NULL,
    [MbrDOD]                      DATE            DEFAULT ('') NULL,
    [ProviderChapter]             VARCHAR (50)    NULL,
    [MemberOriginalEndDate]       DATE            NULL,
    [EffectiveDate]               DATE            NULL,
    [MbrNPIFlg]                   BIT             DEFAULT ((0)) NULL,
    [MbrPlnFlg]                   BIT             DEFAULT ((0)) NULL,
    [MbrFlgCount]                 TINYINT         DEFAULT ((0)) NULL,
    [ProviderFirstName]           VARCHAR (50)    DEFAULT ('') NULL,
    [ProviderMI]                  VARCHAR (50)    DEFAULT ('') NULL,
    [ProviderLastName]            VARCHAR (50)    DEFAULT ('') NULL,
    [ProviderPracticeName]        VARCHAR (100)   DEFAULT ('') NULL,
    [ProviderAddressLine1]        VARCHAR (50)    DEFAULT ('') NULL,
    [ProviderAddressLine2]        VARCHAR (50)    DEFAULT ('') NULL,
    [ProviderCity]                VARCHAR (50)    DEFAULT ('') NULL,
    [ProviderCounty]              VARCHAR (50)    DEFAULT ('') NULL,
    [ProviderZip]                 VARCHAR (50)    DEFAULT ('') NULL,
    [ProviderPhone]               VARCHAR (50)    DEFAULT ('') NULL,
    [ProviderSpecialty]           VARCHAR (100)   DEFAULT ('') NULL,
    [ProviderNetwork]             VARCHAR (50)    DEFAULT ('') NULL,
    [SpecialistStatus]            VARCHAR (50)    DEFAULT ('') NULL,
    [GroupOrPrivatePractice]      VARCHAR (20)    DEFAULT ('') NULL,
    [ProviderPOD]                 VARCHAR (50)    DEFAULT ('') NULL,
    [AceRiskScore]                DECIMAL (5, 2)  NULL,
    [AceRiskScoreLevel]           DECIMAL (5, 2)  NULL,
    [ClientRiskScore]             DECIMAL (10, 2) NULL,
    [ClientRiskScoreLevel]        DECIMAL (25, 2) NULL,
    [RiskScoreUtilization]        DECIMAL (5, 2)  NULL,
    [RiskScoreClinical]           DECIMAL (5, 2)  NULL,
    [RiskScoreHRA]                DECIMAL (5, 2)  NULL,
    [RiskScorePlaceHolder]        DECIMAL (5, 2)  NULL,
    [srcNPI]                      VARCHAR (50)    NULL,
    [srcPln]                      VARCHAR (50)    NULL,
    [LOB]                         VARCHAR (50)    NULL,
    [CsplnProductSubPlanName]     VARCHAR (100)   NULL,
    [NPIReplacedFlg]              TINYINT         DEFAULT ((0)) NULL,
    [srcTIN]                      VARCHAR (50)    NULL,
    [Active]                      BIT             DEFAULT ((1)) NULL,
    [Excluded]                    BIT             DEFAULT ((0)) NULL,
    [ProviderFullName]            VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([mbrStg2_MbrDataUrn] ASC),
    CONSTRAINT [CK_MbrStg2_MbrData_stgRowStatus] CHECK ([stgRowStatus]='Exported' OR [stgRowStatus]='Valid' OR [stgRowStatus]='Loaded' OR [stgRowStatus]='Not Valid' OR [stgRowStatus]='Dups')
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MCO Subscriber ID, key Business Identifier ', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'ClientSubscriberId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to Client', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'ClientKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MRN: Unique id for member accross all mcos and subscriber ids', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'MstrMrnKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is this a primary or secondary load, not all MCO''s have Secondary', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'LoadType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Last Name of member', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrLastName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'First Name', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrFirstName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Middle Name or initial', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrMiddleName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SSN if available', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrSSN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Gender as text', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrGENDER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date of birth', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrDob';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Medicaid number', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrMEDICAID_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Medicare number', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrMEDICARE_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'HICN: CMS provided HIC Number. Being phased out', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'HICN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Medicare Beneficiary Identifier Number:', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'MBI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ethnicity as text: will be mapped to Ace values further in model', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrEthnicity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Race as text: will be mapped to Ace Values further in model', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrRace';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Prmary Language: will be mapped to Ace values further in model', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'mbrPrimaryLanguage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PCP NPI number', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'prvNPI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PCP TIN ', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'prvTIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Is Pcp Auto Assign: this should be transformed to be Auto/Self', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'prvAutoAssign';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date Member Effective with PCP', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'prvClientEffective';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date Member Expired with PCP', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'prvClientExpiration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Member Benefit Plan Identifier', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'plnProductPlan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Subplan code', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'plnProductSubPlan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sub Plan name', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'plnProductSubPlanName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dual coverage indicator', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'plnMbrIsDualCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date plan effective', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'plnClientPlanEffective';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Source File Name ', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'SrcFileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ADI table Name that holds source records', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'AdiTableName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ADI Primary Key', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'AdiKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date data was loaded into ACE (load date from adi)', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'LoadDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Data Date: date data was created: data date from ADI', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'DataDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'datetime row was created', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'CreateDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'user id of system user who created the row.', @level0type = N'SCHEMA', @level0name = N'ast', @level1type = N'TABLE', @level1name = N'MbrStg2_MbrData', @level2type = N'COLUMN', @level2name = N'CreateBy';

