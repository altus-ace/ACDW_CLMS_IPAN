CREATE VIEW [adw].[vw_Dashboard_ED_Details]

AS

SELECT      
              ED.DataDate
            , ED.ClientKey
			, ED.ClientMemberKey
			, ED.EffectiveAsOfDate
			, ED.SEQ_ClaimID 
            , ED.PrimaryServiceDate
			, ED.PrimaryDiagnosis
			, ED.RevCode
			, ED.VendorID
			, ED.VendorName
			, ED.SVCProviderID
			, ED.SVCProviderFullName
			, ED.AttProviderID
			, ED.AttProviderFullName 
            , ED.LOS
			, ED.ClaimType
			, ED.BillType
			, ED.AttribNPI
			, ED.AttribTIN
            , ED.FacilityPrefferedFlag
			, ED.ERToIPFlag
			, ED.ObvFlag
			, ED.SvcNPISpecialty 
            , ED.AttNPISpecialty
			, CH.CATEGORY_OF_SVC
			, CH.DRG_CODE
			, CH.BILL_TYPE
			, CH.CLAIM_TYPE 
            , CH.TOTAL_BILLED_AMT
			, CH.TOTAL_PAID_AMT
			, concat(mbr.LastName , ', ', mbr.FirstName ) as MemberName
			--, mbr.LastName
			, mbr.DOB
			, mbr.MemberID
			, mbr.PlanName
			, mbr.ProviderChapter
			, mbr.PcpPracticeTIN
			, mbr.ProviderPracticeName
			, mbr.NPI
			, concat(mbr.ProviderLastName , ', ', mbr.ProviderFirstName ) as ProviderName
			, mbr.RiskScoreUtilization
			, mbr.RiskScoreClinical
			, mbr.ClientRiskScore
			, mbr.ClientRiskScoreLevel
			, mbr.RiskScoreHRA
						 
FROM            adw.vw_Dashboard_EDVisits ED left JOIN
                adw.Claims_Headers CH  ON ED.SEQ_ClaimID =   CH.SEQ_CLAIM_ID
				LEFT JOIN adw.vw_Dashboard_Membership mbr on mbr.clientmemberkey = ED.clientmemberkey 
				and mbr.mbryear = year(ED.EffectiveAsOfDate) 
				and mbr.MbrMonth = MONTH(ED.EffectiveAsOfDate)

