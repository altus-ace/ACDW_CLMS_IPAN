CREATE TABLE [adw].[MbrAppointments] (
    [MbrAppointmentKey]      INT            IDENTITY (1, 1) NOT NULL,
    [ClientMemberKey]        VARCHAR (50)   NOT NULL,
    [ClientKey]              INT            NOT NULL,
    [AppointmentStatus]      VARCHAR (50)   NULL,
    [AppointmentDate]        DATE           NULL,
    [ScheduledByUser]        VARCHAR (50)   NULL,
    [AppointmentNote]        VARCHAR (5000) NULL,
    [AppointmentCreatedDate] DATE           NULL,
    [srcFileName]            VARCHAR (100)  NOT NULL,
    [LoadDate]               DATE           NOT NULL,
    [CreatedDate]            DATETIME       CONSTRAINT [DF_MbrAppointment_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              VARCHAR (100)  CONSTRAINT [DF_MbrAppointment_CreateBy] DEFAULT (suser_sname()) NOT NULL,
    [Status]                 INT            NULL,
    PRIMARY KEY CLUSTERED ([MbrAppointmentKey] ASC)
);

