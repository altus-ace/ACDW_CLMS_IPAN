CREATE TABLE [dbo].[tmp_AHR_HL7_Report_Detail_Rx] (
    [RX_ID]                       INT             IDENTITY (3000, 1) NOT NULL,
    [SUBSCRIBER_ID]               VARCHAR (50)    NULL,
    [DETAIL_SVC_DATE]             DATE            NULL,
    [NDC_CODE]                    VARCHAR (20)    NULL,
    [NDC_DESC]                    VARCHAR (100)   NULL,
    [LINE_NUMBER]                 INT             NULL,
    [RX_DATE_PRESCRIPTION_FILLED] DATE            NULL,
    [PRESCRIBING_PROV_ID]         VARCHAR (20)    NULL,
    [PRESCRIBING_PROV_NAME]       VARCHAR (100)   NULL,
    [QUANTITY]                    NUMERIC (12, 2) NULL,
    [RX_SUPPLY_DAYS]              VARCHAR (50)    NULL,
    [LOADDATE]                    DATE            DEFAULT (sysdatetime()) NULL,
    [LOADEDBY]                    VARCHAR (50)    DEFAULT (suser_sname()) NULL
);

