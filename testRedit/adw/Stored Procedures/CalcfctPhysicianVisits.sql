



CREATE PROCEDURE [adw].[CalcfctPhysicianVisits]
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

INSERT INTO [adw].[FctPhysicianVisits]
         ([SrcFileName]
         ,[LoadDate]
         ,[DataDate]
         ,[ClientKey]
         ,[ClientMemberKey]
         ,[EffectiveAsOfDate]
         ,[VisitExamType]
         ,[SEQ_ClaimID]
         ,[PrimaryServiceDate]
         ,[SVCProviderNPI]
		   ,[SVCProviderName] 
         ,[SVCProviderSpecialty]
		   ,[SVCProviderType]
         ,[PrimaryDiagnosis]
         ,[CPT]
         ,[AttribNPI]
         ,[AttribTIN])
	SELECT  CONCAT('[adw].[CalcfctPhysicianVisits]',@KPIStartDate,'-',@KPIEndDate)
			,GETDATE()
			,@RunDate
			,a.ClientKey
			,a.ClientMemberKey
			,@RunDate
			,b.VisitExamType as VisitType
			,b.SEQ_CLAIM_ID
			,b.PRIMARY_SVC_DATE
			,b.SVC_PROV_NPI
			,svcnpi.LegalBusinessName
			,b.PROV_SPEC as ProviderSpec
			,CASE WHEN b.PROV_SPEC IN ('01','08','11','37','38') THEN 'P'	-- PCP
				WHEN b.PROV_SPEC IN ('50','89','97') THEN 'N' 					-- Non Phy Practioner
				ELSE 'S' END as ProviderType									-- Specialist
			,c.PrimaryDiagCode + ' ' + LEFT(c.PrimaryDiagDescription,75) as PrimDx
			,b.cpt_code as Cpt
			,a.NPI as AttribNPI
			,a.PcpPracticeTIN as AttribTIN
		FROM [adw].[2020_tvf_Get_ActiveMembersFull]	(@MbrEffectiveDate) a
		JOIN 
			(SELECT DISTINCT SUBSCRIBER_ID, SEQ_CLAIM_ID, PRIMARY_SVC_DATE, SVC_PROV_NPI, VisitExamType, PROV_SPEC, CPT_CODE 
			FROM [adw].[2020_tvf_Get_PhyVisitsVisitType] (@KPIStartDate,@KPIEndDate)
			WHERE LineNumber = 1 ) b
			ON b.SUBSCRIBER_ID = a.ClientMemberKey 
		LEFT JOIN [adw].[2020_tvf_Get_PrimarySecondaryDiagCode] ('0','0',@RunDate) c
			ON b.SUBSCRIBER_ID = c.ClientMemberKey
			AND b.SEQ_CLAIM_ID = c.SeqClaimID
		LEFT JOIN adw.[2020_tvf_Get_DataFromNPPES] (getdate()) svcnpi
			ON b.SVC_PROV_NPI = svcnpi.NPI
		--WHERE a.DOD = '1900-01-01'


END;												


/***
EXEC [adw].[CalcfctPhysicianVisits] 16,'07-15-2020','01-01-2020','03-31-2020','07-15-2020'

***/
