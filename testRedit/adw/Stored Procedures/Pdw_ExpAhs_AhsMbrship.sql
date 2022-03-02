--exec [adw].[Pdw_ExpAhs_AhsMbrship] 2 SELECT * FROM [adw].[AhsExpMembership]
CREATE PROCEDURE [adw].[Pdw_ExpAhs_AhsMbrship](@ClientKey INT)
AS 

	--DECLARE @OutputTbl TABLE (ID INT); 
	DECLARE @LoadDate Date = GETDATE() ;   
	DECLARE @AuditID INT 
    DECLARE @AuditStatus SmallInt= 1 -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt     ;
    DECLARE @JobStatus tinyInt = 1	;
    DECLARE @JobName VARCHAR(200) ;
    DECLARE @ActionStartTime DATETIME = getdate();
    DECLARE @ActionStopTime DATETIME = getdate()
    DECLARE @InputSourceName VARCHAR(200) = 'No Name given';	   
    DECLARE @DestinationName VARCHAR(200) = 'No Name given';	   
    DECLARE @ErrorName VARCHAR(200)	  = 'No Name given';	   
    DECLARE @SourceCount int = 0;         
    DECLARE @DestinationCount int = 0;    
    DECLARE @ErrorCount int = 0;    
        
    SET @JobType				 = 9	   -- 9 ast load    
    SET @JobName				 = 'Pdw_ExpAhs_AhsMbrByPcp'
	SELECT @InputSourceName		 = DB_NAME() +  ' dbo.vw_Exp_AH_MemberPCP_dev'    
	SELECT @DestinationName		 = DB_NAME() + '.[adw].[AhsExpMemberByPcp]';    
	SELECT @ErrorName			 = DB_NAME() + '.[adw].[AhsExpMemberByPcp]';    
    
    EXEC AceMetaData.amd.sp_AceEtlAudit_Open   
	        
	     @AuditID = @AuditID OUTPUT          
	   , @AuditStatus = @AuditStatus          
	   , @JobType = @JobType          
	   , @ClientKey = @ClientKey          
	   , @JobName = @JobName          
	   , @ActionStartTime = @ActionStartTime          
	   , @InputSourceName = @InputSourceName          
	   , @DestinationName = @DestinationName          
	   , @ErrorName = @ErrorName          ;    


	     
	   BEGIN TRAN      
	   INSERT INTO [adw].[AhsExpMembership]
	   (
			 [ClientMemberKey]							
			,[ClientKey]								
			,[fctMembershipKey]							
			,[Exp_MEMBER_ID]							
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
			,[LoadDate]									
	   )
	  SELECT DISTINCT 
            mbr.clientmemberkey AS Member_id,
			mbr.ClientKey, 
			mbr.FctMembershipSkey AS FctMemberKey,
			mbr.clientMEmberKey as EXP_MemberID,
            lc.CS_Export_LobName AS [CLIENT_ID], 
            'N/A' AS MEDICAID_ID, 
            Mbr.FirstName AS [MEMBER_FIRST_NAME], 
            Mbr.MiddleName AS [MEMBER_MI], 
            Mbr.LastName AS [MEMBER_LAST_NAME], 
            Mbr.DOB AS [DATE_OF_BIRTH], 
            Mbr.Gender AS [MEMBER_GENDER], 
            Mbr.Memberhomeaddress + ' ' + Mbr.Memberhomeaddress1 AS [HOME_ADDRESS], 
            Mbr.MemberhomeCity AS [HOME_CITY], 
            Mbr.MemberHomeState AS [HOME_STATE], 
            Mbr.MemberHomeZip AS [HOME_ZIPCODE],
            CONCAT(mbr.MembermailingAddress , ' ' , mbr.MembermailingAddress1) AS [MAILING_ADDRESS],
            mbr.MemberMailingCity                 AS [MAILING_CITY],
             mbr.MemberMailingState                AS [MAILING_STATE],
           mbr.MemberHomeZip                  AS [MAILING_ZIP], 
            mbr.MemberPhone AS [HOME_PHONE], 
            mbr.MemberHomePhone AS [ADDITIONAL_PHONE], 
            mbr.MemberCellPhone AS [CELL_PHONE], 
            '' AS [LANGUAGE], 
            '' AS [Ethnicity], 
            '' AS [Race], 
			'' AS [Email],             
            mbr.HICN AS [MEDICARE_ID], 
			NULL AS MEMBER_ORG_EFF_DATE	,
			NULL AS MEMBER_CONT_EFF_DATE,
			NULL AS MEMBER_CUR_EFF_DATE	,
			NULL AS MEMBER_CUR_TERM_DATE,
            '' AS [RESP_FIRST_NAME], 
            '' AS [RESP_LAST_NAME], 
            '' AS [RESP_RELATIONSHIP], 
            '' AS [RESP_ADDRESS], 
            '' AS [RESP_ADDRESS2], 
            '' AS [RESP_CITY], 
            '' AS [RESP_STATE], 
            '00000' AS [RESP_ZIP], 
            '000-000-0000' AS [RESP_PHONE], 
            '' AS [PRIMARY_RISK_FACTOR], 
            '' AS [COUNT_OPEN_CARE_OPPS], 
            '' AS [INP_ADMITS_LAST_12_MOS], 
            '' AS [LAST_INP_DISCHARGE], 
            '' AS [POST_DISCHARGE_FUP_VISIT], 
            '' AS [INP_FUP_WITHIN_7_DAYS], 
            '' AS [ER_VISITS_LAST_12_MOS], 
            '' AS [LAST_ER_VISIT], 
            '' AS [POST_ER_FUP_VISIT], 
            '' AS [ER_FUP_WITHIN_7_DAYS], 
            '' AS [LAST_PCP_VISIT], 
            '' AS [LAST_PCP_PRACTICE_SEEN], 
            '' AS [LAST_BH_VISIT], 
            '' AS [LAST_BH_PRACTICE_SEEN], 
            '' AS [TOTAL_COSTS_LAST_12_MOS], 
            '' AS [INP_COSTS_LAST_12_MOS], 
            '' AS [ER_COSTS_LAST_12_MOS], 
            '' AS [OUTP_COSTS_LAST_12_MOS], 
            '' AS [PHARMACY_COSTS_LAST_12_MOS], 
            '' AS [PRIMARY_CARE_COSTS_LAST_12_MOS], 
            '' AS [BEHAVIORAL_COSTS_LAST_12_MOS], 
            '' AS [OTHER_OFFICE_COSTS_LAST_12_MOS], 
            '' AS [NEXT_PREVENTATIVE_VISIT_DUE]
		  , CONVERT(VARCHAR(15), Mbr.Ace_ID)  AS ACE_ID
		  , '' as Carrier_member_id 
		  , @LoadDate
	   FROM [adw].FctMembership mbr
         INNER JOIN lst.[List_Client] lc ON lc.ClientKey = mbr.ClientKey
	    INNER JOIN (SELECT MAX(mbr.RwEffectiveDate) mbrRwEff, Max(mbr.RwExpirationDate) MbrRwExp from Adw.FctMembership mbr) LatestRecords
		  ON mbr.RwEffectiveDate = LatestRecords.mbrRwEff
			 and mbr.RwExpirationDate = LatestRecords.MbrRwExp
    --      WHERE mbr.Active = 1	   don't include this, this export should contain all rows.
    --where mbr.ProviderPOD <> '' mssp filter
    where mbr.SubgrpName <> 'COMM_Market is unknown' -- bcbs filter (these members do not have a valid plan)
	   
	    
	   ;
	   COMMIT TRAN; 
	   
    
    EXEC AceMetaData.amd.sp_AceEtlAudit_Close           
	   @AuditId = @AuditID          
	   , @ActionStopTime = @ActionStopTime          
	   , @SourceCount = @SourceCount              
	   , @DestinationCount = @DestinationCount          
	   , @ErrorCount = @ErrorCount          
	   , @JobStatus = @JobStatus      
	   ;         
     
        
	   
