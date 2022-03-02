



CREATE PROCEDURE [adw].[CalcfctHHAVisits]
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

INSERT INTO [adw].[FctHHAVisits]
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
           ,[VendorID]
           ,[VendorName]
           ,[FacilityPrefferedFlag]
           ,[LOS]
           ,[ClaimType]
           ,[BillType]
           ,[AttribNPI]
           ,[AttribTIN]
           ,[DetailServiceDate]
           ,[CPTCode]
           ,[RevCode])
	SELECT  CONCAT('[adw].[CalcfctHHAVisits]',@KPIStartDate,'-',@KPIEndDate)				
			,GETDATE()
			,@RunDate
			,a.ClientKey
			,a.ClientMemberKey
			,@RunDate
			,b.SEQ_CLAIM_ID
			,b.PRIMARY_SVC_DATE
			,b.ADMISSION_DATE
			,b.SVC_TO_DATE
			,b.VENDOR_ID
			,''--vennpi.LegalBusinessName 
			,CASE WHEN e.FacilityName IS NOT NULL THEN 1 ELSE 0 END as PreferredFacilicyFlg
			,CASE WHEN DATEDIFF(dd, b.PRIMARY_SVC_DATE, b.SVC_TO_DATE) = 0 THEN 1 ELSE DATEDIFF(dd, b.PRIMARY_SVC_DATE, b.SVC_TO_DATE) END AS LOS
			,b.CLAIM_TYPE
			,b.BILL_TYPE
			,a.NPI 
			,a.PcpPracticeTIN
			,b.DETAIL_SVC_DATE
			,b.CPT_CODE
			,b.REVENUE_CODE
		FROM [adw].[2020_tvf_Get_ActiveMembersFull]	(@MbrEffectiveDate) a
		JOIN [adw].[2020_tvf_Get_HHAVisits] (@KPIStartDate,DATEADD(month, 3, @KPIEndDate)) b
			ON a.ClientMemberKey = b.SUBSCRIBER_ID
		LEFT JOIN [lst].[lstPreferredFacility] e
			ON b.VENDOR_ID = e.NPI
		LEFT JOIN adw.[2020_tvf_Get_DataFromNPPES] (getdate()) vennpi
			ON b.VENDOR_ID = vennpi.NPI
END;												


/***
EXEC [adw].[CalcfctHHAVisits] 25,'03-02-2022','01-01-2021','06-30-2021','07-15-2021'

SELECT @EffectiveAsOfDate AS EffectiveAsOfDate, SUBSCRIBER_ID AS ClientMemberKey, YEAR(DETAIL_SVC_DATE) AS DetailSvcYr, MONTH(DETAIL_SVC_DATE) AS DetailSvcMth
	,count(distinct DETAIL_SVC_DATE) as CntVisits
FROM [adw].[2020_tvf_Get_HHAVisits] (@PrimarySvcDate_Start,@PrimarySvcDate_End)
GROUP BY SUBSCRIBER_ID, YEAR(DETAIL_SVC_DATE), MONTH(DETAIL_SVC_DATE) 
ORDER BY SUBSCRIBER_ID, YEAR(DETAIL_SVC_DATE) DESC, MONTH(DETAIL_SVC_DATE) DESC
***/
