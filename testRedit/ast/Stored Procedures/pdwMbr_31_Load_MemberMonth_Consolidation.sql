



CREATE PROCEDURE	[ast].[pdwMbr_31_Load_MemberMonth_Consolidation]
					(@RwEffectiveDate DATE, @ClientKey INT)

AS

BEGIN  --  DECLARE @RwEffectiveDate DATE = '2021-07-01' DECLARE @ClientKey INT = 25

		INSERT INTO		 ACDW_CLMS_IPAN.[dbo].[TmpAllMemberMonths]
						([MemberMonth]
						,[CLientKey]
						,[LOB]
						,[ClientMemberKey]
						,[PCP_NPI]
						,[PLAN_ID]
						,[PLAN_CODE]
						,[SUBGRP_ID]
						,[SUBGRP_NAME]
						,[PCP_PRACTICE_TIN]
						,[PCP_PRACTICE_NAME]
						,[MEMBER_FIRST_NAME]
						,[MEMBER_LAST_NAME]
						,[GENDER]
						,[AGE]
						,[DATE_OF_BIRTH]
						,[MEMBER_HOME_ADDRESS]
						,[MEMBER_HOME_ADDRESS2]
						,[MEMBER_HOME_CITY]
						,[MEMBER_HOME_STATE]
						,[MEMBER_HOME_ZIP]
						,[MEMBER_HOME_PHONE]
						,[IPRO_ADMIT_RISK_SCORE]
						,[RunDate]
						,[RunBy])  --  DECLARE @RwEffectiveDate DATE = '2021-11-01'
			 SELECT   
						@RwEffectiveDate		AS MemberMonth
						, fct.CLientKey			AS ClientKey
						, fct.LOB				AS LOB
						, fct.ClientMemberKey	AS ClientMemberKey
						, fct.NPI				AS PCP_NPI
						, FCT.PlanID			AS [PLAN_ID]
						, fct.PlanName			AS  PLAN_CODE
						, fct.SubgrpID			AS  SUBGRP_ID
						, fct.SubgrpName		AS  SUBGRP_NAME
						, fct.PcpPracticeTIN			AS  PCP_PRACTICE_TIN
						, fct.ProviderPracticeName		AS  PCP_PRACTICE_NAME
						, fct.FirstName					AS  MEMBER_FIRST_NAME
						, fct.LastName					AS	MEMBER_LAST_NAME
						, fct.GENDER					AS  Gender
						, fct.CurrentAge				AS  AGE
						, fct.DOB						AS  DATE_OF_BIRTH
						, fct.MemberHomeAddress			AS  MEMBER_HOME_ADDRESS
						, fct.MemberHomeAddress1		AS  MEMBER_HOME_ADDRESS2
						, fct.MemberHomeCity			AS  MEMBER_HOME_CITY
						, fct.MemberHomeState			AS  MEMBER_HOME_STATE
						, fct.MemberHomeZip				AS  MEMBER_HOME_ZIP_C
						, fct.MemberPhone				AS  MEMBER_HOME_PHONE
						, fct.ClientRiskScore			AS  [IPRO_ADMIT_RISK_SCORE]
						, LoadDate						AS	RunDate
						, CreatedBy						AS  CreatedBy 
			FROM		adw.FctMembership fct
			WHERE		RwEffectiveDate = @RwEffectiveDate
			AND			ACTIVE = 1
		
	END

