CREATE TABLE [adw].[dimDate] (
    [dateKey]         INT          NOT NULL,
    [LoadDate]        DATETIME     NOT NULL,
    [CreatedDate]     DATETIME     DEFAULT (sysdatetime()) NOT NULL,
    [CreatedBy]       VARCHAR (50) DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate] DATETIME     DEFAULT (sysdatetime()) NOT NULL,
    [LastUpdatedBy]   VARCHAR (50) DEFAULT (suser_sname()) NOT NULL,
    [dDate]           DATE         DEFAULT ('1/1/1980') NOT NULL,
    [dDay]            INT          DEFAULT ((0)) NULL,
    [dMonth]          INT          DEFAULT ((0)) NULL,
    [dYear]           INT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([dateKey] ASC)
);

