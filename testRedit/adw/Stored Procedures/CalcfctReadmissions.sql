



CREATE PROCEDURE [adw].[CalcfctReadmissions]
	(
	@ClientKeyID				VARCHAR(2),
	@RunDate						DATE,
	@KPIStartDate				DATE,
	@KPIEndDate					DATE,
	@MbrEffectiveDate			DATE
	)
AS    
BEGIN
    SET NOCOUNT ON;

	INSERT INTO [adw].[FctReadmissionVisits]
			(
			[SrcFileName]
			,[LoadDate]
			,[DataDate]
			,[ClientKey]
			,[ClientMemberKey]
			,[EffectiveAsOfDate]
			,[SEQ_ClaimID]
			,[PrimaryServiceDate]
			,[AdmissionDate]
			,[DischargeDate]
			,[DischargeDisposition]
			,[DrgCode]
			,[PrimaryDiagnosis]
			,[VendorID]
		   ,[VendorName]
         ,[SVCProviderID]
         ,[SVCProviderFullName]
         ,[SNFPreferredFlag]
         ,[FacilityPrefferedFlag]
         ,[LOS]
         ,[ClaimType]
 		   ,[BillType]
		   ,[AttribNPI]
		   ,[AttribTIN]
		   ,[InstType]
		   ,[AssocSEQ_ClaimID]
		   ,[AssocDischargeDate])
	SELECT  DISTINCT CONCAT('[adw].[CalcfctReadmissions]',@KPIStartDate,'-',@KPIEndDate) 
			,GETDATE()
			,@RunDate
			,a.ClientKey
			,a.ClientMemberKey
			,@RunDate
			,c.SEQ_ClaimID
			,c.PrimaryServiceDate
			,c.AdmissionDate
			,c.DischargeDate
			,c.DischargeDisposition
			,c.DrgCode
			,c.PrimaryDiagnosis
			,c.VendorID
			,c.VendorName
			,c.SVCProviderID
			,c.SVCProviderFullName
			,c.SNFPreferredFlag
			,c.FacilityPrefferedFlag
			,c.LOS
			,c.ClaimType
			,c.BillType
			,c.AttribNPI
			,c.AttribTIN
			,c.InstType
			,b.SeqClaimID1
			,b.DischargeDate1
		FROM [adw].[2020_tvf_Get_ActiveMembersFull]	(@MbrEffectiveDate) a
		JOIN [adw].[2020_tvf_Get_ReAdmissions] (30,@KPIStartDate,@KPIEndDate) b
			ON a.ClientMemberKey = b.ClientMemberKey
		LEFT JOIN [adw].[FctInpatientVisits] c
			ON b.ClientMemberKey = c.ClientMemberKey
			AND b.SeqClaimID2 = c.Seq_ClaimID
			AND c.EffectiveAsOfDate = @RunDate
		--WHERE a.DOD = '1900-01-01'

END;												


/***
EXEC [adw].[CalcfctReadmissions] 16,'04-01-2020','01-01-2019','12-31-2020','2020-09-14'

SELECT *
FROM [adw].[FctReadmissionVisits]
WHERE EffectiveAsOfDate = '2020-07-14'

truncate table [adw].[FctReadmissionVisits]
***/


