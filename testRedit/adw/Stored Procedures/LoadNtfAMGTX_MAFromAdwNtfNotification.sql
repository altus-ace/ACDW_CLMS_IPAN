

/****** Object:  Table [adw].[NtfNotification]    Script Date: 6/16/2020 12:50:14 PM ******/
CREATE PROCEDURE [adw].[LoadNtfAMGTX_MAFromAdwNtfNotification]
AS

BEGIN
SET IDENTITY_INSERT [adw].[NtfNotification] ON

INSERT INTO			[adw].[NtfNotification](
					[CreatedDate]
					, [CreatedBy]
					, [LastUpdatedDate]
					, [LastUpdatedBy]
					, [LoadDate]
					, [DataDate]
					, [ntfNotificationKey]
					, [ClientKey]
					, [NtfSource]
					, [ClientMemberKey]
					, [ntfEventType]
					, [NtfPatientType]
					, [CaseType]
					, [AdmitDateTime]
					, [ActualDischargeDate]
					, [DischargeDisposition]
					, [ChiefComplaint]
					, [DiagnosisDesc]
					, [DiagnosisCode]
					, [AdmitHospital]
					, [AceFollowUpDueDate]
					, [Exported]
					, [ExportedDate]
					, [AdiKey]
					, [SrcFileName]
					, [AceID]
					, [DschrgInferredInd]
					, [DschrgInferredDate])

SELECT				[CreatedDate]
					, [CreatedBy]
					, [LastUpdatedDate]
					, [LastUpdatedBy]
					, [LoadDate]
					, [DataDate]
					, [ntfNotificationKey]
					, [ClientKey]
					, [NtfSource]
					, [ClientMemberKey]
					, [ntfEventType]
					, [NtfPatientType]
					, [CaseType]
					, [AdmitDateTime]
					, [ActualDischargeDate]
					, [DischargeDisposition]
					, [ChiefComplaint]
					, [DiagnosisDesc]
					, [DiagnosisCode]
					, [AdmitHospital]
					, [AceFollowUpDueDate]
					, [Exported]
					, [ExportedDate]
					, [AdiKey]
					, [SrcFileName]
					, [AceID]
					, [DschrgInferredInd]
					, [DschrgInferredDate] 
FROM				[ACECAREDW].[adw].[NtfNotification]
WHERE				ClientKey = 21
AND					CONVERT(DATE,CreatedDate) = CONVERT(DATE,GETDATE())

SET IDENTITY_INSERT [adw].[NtfNotification] OFF

END


