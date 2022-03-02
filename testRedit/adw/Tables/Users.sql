CREATE TABLE [adw].[Users] (
    [UserID]                   INT           IDENTITY (1, 1) NOT NULL,
    [Username]                 VARCHAR (50)  NOT NULL,
    [Password]                 VARCHAR (100) NOT NULL,
    [UserCreationTime]         DATETIME      DEFAULT (getdate()) NOT NULL,
    [LastPasswordModifiedTime] DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Username] ASC)
);

