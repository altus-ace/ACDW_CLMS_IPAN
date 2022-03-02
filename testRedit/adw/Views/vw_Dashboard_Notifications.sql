





CREATE VIEW [adw].[vw_Dashboard_Notifications]
AS





SELECT				DISTINCT a.[CreatedDate]
					, a.[CreatedBy]
					, a.[LastUpdatedDate]
					, a.[LastUpdatedBy]
					, a.[LoadDate]
					, a.[DataDate]
					, a.[ntfNotificationKey] 
					, a.[ClientKey]
					, b.[ClientShortName]
					, a.[NtfSource]
					, a.[ClientMemberKey]
					, c.[FirstName]
					, c.[LastName]
					, c.[DOB]
					, c.[MemberCellPhone]
					, a.[ntfEventType]
					, a.[NtfPatientType]
					, c.[MbrYear]
					, a.[CaseType]
					, a.[AdmitDateTime]
					, a.[ActualDischargeDate]
					, a.[DischargeDisposition]
					, a.[ChiefComplaint]
					, a.[DiagnosisDesc]
					, a.[DiagnosisCode]
					, a.[AdmitHospital]
					, a.[AceFollowUpDueDate]
					, a.[Exported]
					, a.[ExportedDate]
					, a.[AdiKey]
					, a.[SrcFileName]
					, a.[AceID]
					, a.[DschrgInferredInd]
					, a.[DschrgInferredDate]
FROM				adw.NtfNotification a
JOIN				lst.List_Client b
ON					a.ClientKey = b.ClientKey
JOIN				adw.FctMembership c
ON					a.ClientMemberKey = c.ClientMemberKey
WHERE				CONVERT(DATE,a.CreatedDate) BETWEEN DATEADD(MONTH,-3,CONVERT(DATE,GETDATE())) AND CONVERT(DATE,GETDATE())
AND					MbrYear <> 2019










