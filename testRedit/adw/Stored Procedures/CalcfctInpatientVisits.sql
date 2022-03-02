


CREATE PROCEDURE [adw].[CalcfctInpatientVisits]
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

	INSERT INTO [adw].[FctInpatientVisits]
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
         ,[AttProviderID]
         ,[AttProviderFullName]
         ,[SNFPreferredFlag]
         ,[FacilityPrefferedFlag]
         ,[LOS]
         ,[ClaimType]
		   ,[BillType]
		   ,[AttribNPI]
		   ,[AttribTIN]
		   ,[InstType]
		   ,[SvcNPISpecialty]
         ,[AttNPISpecialty])
	SELECT  CONCAT('[adw].[CalcfctInpatientVisits]',@KPIStartDate,'-',@KPIEndDate)
			,GETDATE()
			,@RunDate
			,a.ClientKey
			,a.ClientMemberKey
			,@RunDate
			,b.SEQ_CLAIM_ID
			,b.PRIMARY_SVC_DATE
			,b.ADMISSION_DATE
			,b.SVC_TO_DATE
			,b.DISCHARGE_DISPO
			,b.DRG_CODE
			,c.PrimaryDiagCode + ' ' + LEFT(c.PrimaryDiagDescription,75)
			,b.VENDOR_ID
			,vennpi.LegalBusinessName 
			,b.SVC_PROV_NPI
			,svcnpi.LegalBusinessName
			,b.ATT_PROV_NPI
			,attnpi.LegalBusinessName
			,CASE WHEN d.FacilityName IS NOT NULL THEN 1 ELSE 0 END as SNFPreferredFlg
			,CASE WHEN e.FacilityName IS NOT NULL THEN 1 ELSE 0 END as PreferredFacilicyFlg
			,b.LOS
			,b.CLAIM_TYPE
			,b.BILL_TYPE
			,a.NPI 
			,a.PcpPracticeTIN
			,CASE WHEN LEFT(RIGHT(b.[CMS_CertificationNumber],4),2) IN ('20','21','22') AND Claim_Type in ('60','61') THEN 'LTAC' 
			    WHEN LEFT(RIGHT(b.[CMS_CertificationNumber],4),2) IN ('13') AND Claim_Type in ('60','61') THEN 'IP-CAH' 
			    WHEN LEFT(RIGHT(b.[CMS_CertificationNumber],4),2) IN ('00','01','02','03','04','05','06','07','08') AND Claim_Type in ('60','61') THEN 'ACUTE' 		
				WHEN CLAIM_TYPE in ('60','61')
				AND (RIGHT(LEFT(b.[CMS_CertificationNumber],3),1) IN ('R','T') 
				OR RIGHT([CMS_CertificationNumber],4) IN 
				('3025','3035','3045','3055','3065','3075','3085','3095'
				,'3026','3036','3046','3056','3066','3076','3086','3096'
				,'3027','3037','3047','3057','3067','3077','3087','3097'
				,'3028','3038','3048','3058','3068','3078','3088','3098'
				,'3029','3039','3049','3059','3069','3079','3089','3099'
				,'3030','3040','3050','3060','3070','3080','3090'	
				,'3031','3041','3051','3061','3071','3081','3091'	
				,'3032','3042','3052','3062','3072','3082','3092'	
				,'3033','3043','3053','3063','3073','3083','3093'	
				,'3034','3044','3054','3064','3074','3084','3094'))	
				THEN 'IRF' 
				WHEN CLAIM_TYPE IN ('50')			THEN 'HOSPICE'
				WHEN CLAIM_TYPE IN ('20','30')	THEN 'SNF'
				WHEN CLAIM_TYPE IN ('10')			THEN 'HHA'
				ELSE 'OTHER' END as InstType
			,LEFT(svc.SpecDesc,30) as SVCSpecialty
			,LEFT(att.SpecDesc,30) as ATTSpecialty
		FROM [adw].[2020_tvf_Get_ActiveMembersFull]	(@MbrEffectiveDate) a
		JOIN [adw].[2020_tvf_Get_IPVisits] (@KPIStartDate,@KPIEndDate) b
				ON a.ClientMemberKey = b.SUBSCRIBER_ID
		LEFT JOIN [adw].[2020_tvf_Get_PrimarySecondaryDiagCode] ('0','0',@KPIStartDate) c
			ON b.SUBSCRIBER_ID = c.ClientMemberKey
			AND b.SEQ_CLAIM_ID = c.SeqClaimID
		LEFT JOIN [lst].[lstPreferredFacility] d
			ON b.VENDOR_ID = d.NPI
			AND d.FacilityType = 'SNF'
		LEFT JOIN [lst].[lstPreferredFacility] e
			ON b.VENDOR_ID = e.NPI
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

		--WHERE a.DOD = '1900-01-01'
END;												


/***
EXEC [adw].[CalcfctInpatientVisits] 16,'05-15-2020','01-01-2019','02-29-2020','05-15-2020'

SELECT *
FROM [adw].[FctInpatientVisits]
WHERE InstType = 'SNF'
***/


