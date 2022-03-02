




/****** view for exporting to clinical system the Membership information ******/

CREATE VIEW [dbo].[vw_Exp_AH_Membership]
AS

/* version history:
04/26/2020 - Created temp view for AHS initial export - RA
10/19/2020: GK = Added support to use the RwEff/RwExp date to get the latest state of the membership, export active 0 and 1.
	   */

     SELECT DISTINCT 
            [ClientMemberKey]					
			,[Exp_CLIENT_ID]								
			,[Exp_MEDICAID_ID]					
			,[Exp_MEMBER_FIRST_NAME]				
			,[Exp_MEMBER_MI]						
			,[Exp_MEMBER_LAST_NAME]				
			,[Exp_DATE_OF_BIRTH]					
			,[Exp_MEMBER_GENDER]					
			,[Exp_HOME_ADDRESS]					
			,[Exp_HOME_CITY]						
			,[Exp_HOME_STATE]						
			,[Exp_HOME_ZIPCODE]					
			,[Exp_MAILING_ADDRESS]				
			,[Exp_MAILING_CITY]					
			,[Exp_MAILING_STATE]					
			,[Exp_MAILING_ZIP]					
			,[Exp_HOME_PHONE]						
			,[Exp_ADDITIONAL_PHONE]				
			,[Exp_CELL_PHONE]						
			,[Exp_Language]						
			,[Exp_Ethnicity]						
			,[Exp_Race]							
			,[Exp_Email]							
			,[Exp_MEDICARE_ID]					
			,[Exp_MEMBER_ORG_EFF_DATE]			
			,[Exp_MEMBER_CONT_EFF_DATE]			
			,[Exp_MEMBER_CUR_EFF_DATE]			
			,[Exp_MEMBER_CUR_TERM_DATE]			
			,[Exp_RESP_FIRST_NAME]				
			,[Exp_RESP_LAST_NAME]					
			,[Exp_RESP_RELATIONSHIP]				
			,[Exp_RESP_ADDRESS]					
			,[Exp_RESP_ADDRESS2]					
			,[Exp_RESP_CITY]						
			,[Exp_RESP_STATE]						
			,[Exp_RESP_ZIP]						
			,[Exp_RESP_PHONE]						
			,[Exp_PRIMARY_RISK_FACTOR]			
			,[Exp_COUNT_OPEN_CARE_OPPS]			
			,[Exp_INP_ADMITS_LAST_12_MOS]			
			,[Exp_LAST_INP_DISCHARGE]				
			,[Exp_POST_DISCHARGE_FUP_VISIT]		
			,[Exp_INP_FUP_WITHIN_7_DAYS]			
			,[Exp_ER_VISITS_LAST_12_MOS]			
			,[Exp_LAST_ER_VISIT]					
			,[Exp_POST_ER_FUP_VISIT]				
			,[Exp_ER_FUP_WITHIN_7_DAYS]			
			,[Exp_LAST_PCP_VISIT]					
			,[Exp_LAST_PCP_PRACTICE_SEEN]			
			,[Exp_LAST_BH_VISIT]					
			,[Exp_LAST_BH_PRACTICE_SEEN]			
			,[Exp_TOTAL_COSTS_LAST_12_MOS]		
			,[Exp_INP_COSTS_LAST_12_MOS]			
			,[Exp_ER_COSTS_LAST_12_MOS]			
			,[Exp_OUTP_COSTS_LAST_12_MOS]			
			,[Exp_PHARMACY_COSTS_LAST_12_MOS]		
			,[Exp_PRIMARY_CARE_COSTS_LAST_12_MOS]	
			,[Exp_BEHAVIORAL_COSTS_LAST_12_MOS]	
			,[Exp_OTHER_OFFICE_COSTS_LAST_12_MOS]	
			,[Exp_NEXT_PREVENTATIVE_VISIT_DUE]	
			,[Exp_ACE_ID]							
			,[Exp_carrier_Member_ID]		
		  , ClientKey
		  , m.AhsExpMembershipKey SKey
    FROM [adw].[AhsExpMembership] m
    where m.exported	= 0;
