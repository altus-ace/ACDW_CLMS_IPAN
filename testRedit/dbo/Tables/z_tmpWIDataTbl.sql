CREATE TABLE [dbo].[z_tmpWIDataTbl] (
    [urn]           INT          IDENTITY (1, 1) NOT NULL,
    [SUBSCRIBER_ID] VARCHAR (50) NULL,
    [HCC_CODE]      VARCHAR (5)  NULL,
    [HCC_GRP]       VARCHAR (50) NULL,
    [CreateDate]    DATE         DEFAULT (getdate()) NULL
);

