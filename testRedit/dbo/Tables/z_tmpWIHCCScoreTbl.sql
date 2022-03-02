CREATE TABLE [dbo].[z_tmpWIHCCScoreTbl] (
    [urn]           INT          IDENTITY (1, 1) NOT NULL,
    [SUBSCRIBER_ID] VARCHAR (50) NULL,
    [HCC_CODE]      VARCHAR (5)  NULL,
    [HCC_GRP]       VARCHAR (50) NULL,
    [SourceURN]     INT          NULL,
    [HCC_Weight]    FLOAT (53)   NULL,
    [HCC_Ver]       VARCHAR (25) NULL,
    [CreateDate]    DATE         DEFAULT (getdate()) NULL,
    [CreateBy]      VARCHAR (50) NULL
);

