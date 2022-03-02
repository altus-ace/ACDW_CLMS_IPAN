CREATE TABLE [adw].[QM_ResultByMember_TESTING] (
    [urn]             INT          IDENTITY (1, 1) NOT NULL,
    [ClientMemberKey] VARCHAR (50) NOT NULL,
    [QmMsrId]         VARCHAR (20) NOT NULL,
    [QmCntCat]        VARCHAR (10) NOT NULL,
    [QMDate]          DATE         NULL,
    [CreateDate]      DATETIME     DEFAULT (getdate()) NOT NULL,
    [CreateBy]        VARCHAR (50) DEFAULT (suser_name()) NOT NULL,
    [ClientKey]       INT          NULL,
    PRIMARY KEY CLUSTERED ([urn] ASC)
);

