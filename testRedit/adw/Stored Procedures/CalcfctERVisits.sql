



CREATE PROCEDURE [adw].[CalcfctERVisits]
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

	INSERT INTO [adw].[FctEDVisits]
        (
          [SrcFileName]
         ,[LoadDate]
         ,[DataDate]
         ,[ClientKey]
         ,[ClientMemberKey]
         ,[EffectiveAsOfDate]
         ,[SEQ_ClaimID]
         ,[PrimaryServiceDate]
         ,[PrimaryDiagnosis]
			,[RevCode]
			,[VendorID]   
			,[VendorName] 
         ,[SVCProviderID]
         ,[SVCProviderFullName]
			,[AttProviderID]
			,[AttProviderFullName]
			,[FacilityPrefferedFlag]
         ,[LOS]
         ,[ClaimType]
			,[BillType]
			,[AttribNPI]
			,[AttribTIN]
			,[SvcNPISpecialty]
         ,[AttNPISpecialty]
			,[DischDispo])
	SELECT  DISTINCT CONCAT('[adw].[CalcfctERVisits]',@KPIStartDate,'-',@KPIEndDate)
			,GETDATE()
			,@RunDate
			,a.ClientKey
			,a.ClientMemberKey
			,@RunDate
			,b.SEQ_CLAIM_ID
			,b.PRIMARY_SVC_DATE
			,c.PrimaryDiagCode + ' ' + LEFT(c.PrimaryDiagDescription,75)
			,b.REV_CODE
			,b.VENDOR_ID
			,vennpi.LegalBusinessName --[adi].[udf_ConvertToCamelCase] (vennpi.LegalBusinessName)
			,b.SVC_PROV_NPI
			,svcnpi.LegalBusinessName --[adi].[udf_ConvertToCamelCase] (svcnpi.LegalBusinessName)
			,b.ATT_PROV_NPI
			,attnpi.LegalBusinessName --[adi].[udf_ConvertToCamelCase] (attnpi.LegalBusinessName)
			,CASE WHEN d.FacilityName IS NOT NULL THEN 1 ELSE 0 END as PreferredFacilicyFlg
			,b.LOS
			,b.CLAIM_TYPE
			,b.BILL_TYPE
			,a.NPI
			,a.PcpPracticeTIN
			,LEFT(svc.SpecDesc,30) as SVCSpecialty
			,LEFT(att.SpecDesc,30) as ATTSpecialty
			,b.DISCHARGE_DISPO
		FROM [adw].[2020_tvf_Get_ActiveMembersFull] (@MbrEffectiveDate) a
		--JOIN [adw].[2020_tvf_Get_ERVisits] (@KPIStartDate,@KPIEndDate) b
		--	ON a.ClientMemberKey = b.SUBSCRIBER_ID
		JOIN (SELECT SUBSCRIBER_ID, SEQ_CLAIM_ID,VENDOR_ID,REV_CODE,SVC_PROV_NPI, ATT_PROV_NPI, PRIMARY_SVC_DATE, CLAIM_TYPE, LOS, BILL_TYPE, DISCHARGE_DISPO
				,ROW_NUMBER () OVER (PARTITION BY SUBSCRIBER_ID, SEQ_CLAIM_ID ORDER BY REV_CODE) rno
				FROM [adw].[2020_tvf_Get_ERVisits] (@KPIStartDate,@KPIEndDate)) b
			ON a.ClientMemberKey = b.SUBSCRIBER_ID
			AND b.rno = 1
		LEFT JOIN [adw].[2020_tvf_Get_PrimarySecondaryDiagCode] ('0','0',@KPIStartDate) c
			ON b.SUBSCRIBER_ID = c.ClientMemberKey
			AND b.SEQ_CLAIM_ID = c.SeqClaimID
		LEFT JOIN [lst].[lstPreferredFacility] d
			ON b.VENDOR_ID = d.NPI
		LEFT JOIN adw.[2020_tvf_Get_DataFromNPPES] (getdate()) vennpi
			ON b.VENDOR_ID = vennpi.NPI
		LEFT JOIN adw.[2020_tvf_Get_DataFromNPPES] (getdate()) svcnpi
			ON b.SVC_PROV_NPI = svcnpi.NPI
		LEFT JOIN adw.[2020_tvf_Get_DataFromNPPES] (getdate()) attnpi
			ON b.ATT_PROV_NPI = attnpi.NPI
		LEFT JOIN [adw].[2020_tvf_Get_ProvSpecialtyFromPhyVisits] (@RunDate) svc
			ON b.[SVC_PROV_NPI] = svc.NPI
		LEFT JOIN [adw].[2020_tvf_Get_ProvSpecialtyFromPhyVisits] (@RunDate) att
			ON b.[ATT_PROV_NPI] = att.NPI
		WHERE b.claim_type <> '60'
		--AND a.DOD = '1900-01-01'

END;												


/***
EXEC [adw].[CalcfctERVisits] 16,'07-13-2020','01-01-2020','03-31-2020','07-13-2020'

SELECT *
FROM [adw].[FctEDVisits]
WHERE ClientMemberKey IN ('1A11X60AE93')
6H11RG1FH36	91331574869
***/
