

CREATE FUNCTION [adw].[2020_tvf_Get_ClaimsTMEByMemberClaimID]
(
 @PrimSvcDate_Start DATE, 
 @PrimSvcDate_End   DATE
)

RETURNS TABLE
AS RETURN
(
		SELECT --DISTINCT @PrimSvcDate_Start as PrimSvcDate_Start,@PrimSvcDate_End as PrimSvcDate_End
			DISTINCT 
			B1.[SUBSCRIBER_ID]								as ClientMemberKey
			,YEAR(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE))	as PrimSvcYr
			,MONTH(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE))	as PrimSvcMth
			,CLAIM_TYPE										as ClaimType
			,VENDOR_ID										as VendorID
			,SVC_PROV_NPI									as SvcProvNPI
			,ATT_PROV_NPI									as AttProvNPI
			,CASE WHEN fac.FacilityName  IS NULL THEN 0 ELSE 1 END  as PrefFacFlg
			,CASE WHEN svc.NPI IS NULL THEN 0 ELSE 1 END		as PrefSvcFlg
			,CASE WHEN att.NPI IS NULL THEN 0 ELSE 1 END		as PrefAttFlg
			,B1.SEQ_CLAIM_ID								as Seq_ClaimID
			,B1.[TOTAL_PAID_AMT]							as TotPaidAmt
			,B1.[TOTAL_BILLED_AMT]							as TotBillAmt
			,CASE WHEN CLAIM_TYPE = '10' THEN B1.[TOTAL_PAID_AMT] ELSE 0 END AS HHAPaidAmt
			,CASE WHEN CLAIM_TYPE = '20' OR CLAIM_TYPE = '30' THEN B1.[TOTAL_PAID_AMT] ELSE 0 END AS SNFPaidAmt
			,CASE WHEN CLAIM_TYPE = '40' THEN B1.[TOTAL_PAID_AMT] ELSE 0 END AS OPPaidAmt
			,CASE WHEN CLAIM_TYPE = '50' THEN B1.[TOTAL_PAID_AMT] ELSE 0 END AS HospicePaidAmt
			,CASE WHEN CLAIM_TYPE = '60' OR CLAIM_TYPE = '61' THEN B1.[TOTAL_PAID_AMT] ELSE 0 END AS IPPaidAmt
			,CASE WHEN CLAIM_TYPE = '71' OR CLAIM_TYPE = '72' THEN B1.[TOTAL_PAID_AMT] ELSE 0 END AS PhyPaidAmt
			,CASE WHEN CLAIM_TYPE NOT IN ('10','20','30','40','50','60','61','71','72') THEN B1.[TOTAL_PAID_AMT] ELSE 0 END AS OtherPaidAmt
		FROM [adw].[Claims_Headers] B1
		LEFT JOIN [lst].[lstPreferredFacility] fac
			ON B1.VENDOR_ID = fac.NPI
		LEFT JOIN (SELECT DISTINCT NPI FROM adw.tvf_AllClient_ProviderRoster (0,getdate(),1)) svc
			ON B1.SVC_PROV_NPI = svc.NPI
		LEFT JOIN (SELECT DISTINCT NPI FROM adw.tvf_AllClient_ProviderRoster (0,getdate(),1)) att
			ON B1.ATT_PROV_NPI = att.NPI
		WHERE CONVERT(DATETIME, B1.PRIMARY_SVC_DATE) BETWEEN DATEADD(yy,DATEDIFF(yy,0,GETDATE())-1,0) AND GETDATE()
		--YEAR(CONVERT(DATETIME, B1.PRIMARY_SVC_DATE)) BETWEEN YEAR(@PrimSvcDate_End)-1 AND YEAR(@PrimSvcDate_End)
			AND B1.CLAIM_TYPE			IN ('10','20','30','40','50','60','61','71','72')
			AND B1.[TOTAL_PAID_AMT] <> 0
			--AND CATEGORY_OF_SVC <> 'PHARMACY'
			--AND B1.PROCESSING_STATUS			= 'P'
			--AND B1.CLAIM_STATUS				= 'P'

)

/***
Usage: 
SELECT PrimSvcYr, PrimSvcMth, ClaimType, count(ClientMemberKey) as Mbrs, count(distinct Seq_ClaimID) as Claims, sum(TotPaidAmt) as PaidAmt
FROM [adw].[2020_tvf_Get_ClaimsTMEByMemberClaimID] ('2020-01-01','2020-05-31') a
GROUP BY   PrimSvcYr, PrimSvcMth, ClaimType
ORDER BY   PrimSvcYr, PrimSvcMth, ClaimType
***/

