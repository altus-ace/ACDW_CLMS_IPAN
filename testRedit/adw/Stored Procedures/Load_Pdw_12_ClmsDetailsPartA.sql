
CREATE PROCEDURE [adw].[Load_Pdw_12_ClmsDetailsPartA]
AS
	/* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 8	  -- AST load
    DECLARE @ClientKey INT	 = 25; -- ipan
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF2'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Details'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;		
	
    SELECT @InpCnt = COUNT(DISTINCT ast.ClaimDetailSrcAdiKey)    
    FROM ast.Claim_04_Detail_Dedup ast	-- THESE ARE THE DETAIL ROWS THAT SHOULD BE LOADED    
	WHERE ast.SrcClaimType = 'INST'
    ;

	EXEC amd.sp_AceEtlAudit_Open 
        @AuditID = @AuditID OUTPUT
        , @AuditStatus = @JobStatus
        , @JobType = @JobType
        , @ClientKey = @ClientKey
        , @JobName = @JobName
        , @ActionStartTime = @ActionStart
        , @InputSourceName = @SrcName
        , @DestinationName = @DestName
        , @ErrorName = @ErrorName
        ;
    CREATE TABLE #OutputTbl (ID INT NOT NULL PRIMARY KEY);	

    INSERT INTO adw.Claims_Details
		  (SEQ_CLAIM_ID,
			CLAIM_NUMBER,
			LINE_NUMBER,
			SUB_LINE_CODE,
			[SUBSCRIBER_ID],
			DETAIL_SVC_DATE,
			SVC_TO_DATE,
			REVENUE_CODE,
			QUANTITY,
			PAID_AMT,
			BILLED_AMT,
			PROCEDURE_CODE,
			MODIFIER_CODE_1,
			MODIFIER_CODE_2,
			MODIFIER_CODE_3,
			MODIFIER_CODE_4,
			PLACE_OF_SVC_CODE1,
			PLACE_OF_SVC_CODE2,
			PLACE_OF_SVC_CODE3,
			NDC_CODE,
			RX_GENERIC_BRAND_IND,
			RX_SUPPLY_DAYS,
			RX_DISPENSING_FEE_AMT,
			RX_INGREDIENT_AMT,
			RX_FORMULARY_IND,
			RX_DATE_PRESCRIPTION_WRITTEN,
			RX_DATE_PRESCRIPTION_FILLED,
			PRESCRIBING_PROV_TYPE_ID,	
			PRESCRIBING_PROV_ID,
			BRAND_NAME,
			DRUG_STRENGTH_DESC,
			GPI,
			GPI_DESC,
			CONTROLLED_DRUG_IND,
			COMPOUND_CODE,
			SrcAdiTableName,
			SrcAdiKey,
			LoadDate)		  
		OUTPUT Inserted.ClaimsDetailsKey INTO #OutputTbl(ID)
		SELECT cd.CUR_CLM_UNIQ_ID					AS seq_Claim_ID				--SEQ_CLAIM_ID,					
			, cHdrLatest.clmSKey					AS claim_number 			--CLAIM_NUMBER,					
			, ast.ClaimDetailLineNumber				AS line_Number 				--LINE_NUMBER,					
			, ch.CLM_ADJSMT_TYPE_CD  				AS SUB_LINE_CODE 			--SUB_LINE_CODE,				
			, ch.BENE_MBI_ID			    		AS Subscriber_ID			--[SUBSCRIBER_ID],				
			, cd.CLM_LINE_FROM_DT					AS DETAIL_SVC_DATE 			--DETAIL_SVC_DATE,				
			, cd.CLM_LINE_THRU_DT					AS SVC_TO_DATE 				--SVC_TO_DATE,						
			, cd.CLM_LINE_PROD_REV_CTR_CD			AS REVENUE_CODE				--REVENUE_CODE,								
			, cd.CLM_LINE_SRVC_UNIT_QTY				AS QUANTITY					--QUANTITY,							
			, CLM_LINE_CVRD_PD_AMT					AS Paid_amt      			--PAID_AMT,									
			, ''									AS BILLED_AMT				--BILLED_AMT,				
			, cd.CLM_LINE_HCPCS_CD  /*ch.ProcedureCode1*/			 AS PROCEDURE_CODE				--PROCEDURE_CODE,				
			, cd.HCPCS_1_MDFR_CD					AS MODIFIER_CODE_1 				--MODIFIER_CODE_1,				
			, cd.HCPCS_2_MDFR_CD					AS MODIFIER_CODE_2 				--MODIFIER_CODE_2,				
		  	, cd.HCPCS_3_MDFR_CD					AS MODIFIER_CODE_3 				--MODIFIER_CODE_3,				
			, cd.HCPCS_4_MDFR_CD					AS MODIFIER_CODE_4 				--MODIFIER_CODE_4,							
			,''										AS PLACE_OF_SVC_CODE1			--PLACE_OF_SVC_CODE1,																			
			,''										AS PLACE_OF_SVC_CODE2 			--PLACE_OF_SVC_CODE2,				
			,''										AS PLACE_OF_SVC_CODE3			--PLACE_OF_SVC_CODE3,			
			,''										AS NDC_CODE						--NDC_CODE,				
			,''										AS RX_GENERIC_BRAND_IND			--RX_GENERIC_BRAND_IND,
			,''										AS RX_SUPPLY_DAYS				--RX_SUPPLY_DAYS,			
			,''										AS RX_DISPENSING_FEE_AMT		--RX_DISPENSING_FEE_AMT,																			
			,''										AS RX_INGREDIENT_AMT			--RX_INGREDIENT_AMT,			
			,''										AS RX_FORMULARY_IND				--RX_FORMULARY_IND,				
			,''										AS RX_DATE_PRESCRIPTION_WRITTEN --RX_DATE_PRESCRIPTION_WRITTEN,	
			,''										AS RX_DATE_PRESCRIPTION_FILLED	--RX_DATE_PRESCRIPTION_FILLED
			,''										AS PRESCRIBING_PROV_TYPE_ID		--PRESCRIBING_PROV_TYPE_ID	   
			,''										AS PRESCRIBING_PROV_ID			--PRESCRIBING_PROV_ID			   
			,''										AS BRAND_NAME					--BRAND_NAME,					
			,''										AS DRUG_STRENGTH_DESC			--DRUG_STRENGTH_DESC,			
			,''										AS GPI							--GPI,							
			,''										AS GPI_DESC						--GPI_DESC,						
			,''										AS CONTROLLED_DRUG_IND			--CONTROLLED_DRUG_IND,			
			,''										AS COMPOUND_CODE				--COMPOUND_CODE,				
			,'adi.CCLF2'							AS SrcAdiTableName
			, cd.URN									AS SrcAdiKey					--SrcAdiKey,					
			,GetDate()								AS LoadDate					--LoadDate							  
	  FROM ast.Claim_04_Detail_Dedup ast							-- set of details to load
		JOIN ast.Claim_03_Header_LatestEffective cHdrLatest			-- Set headers to load needed to get detial line data
			ON ast.ClaimSeqClaimId = cHdrLatest.LatestClaimID		
		JOIN adi.CCLF2 cd												
			ON  ast.ClaimDetailSrcAdiKey = CD.URN			
		JOIN adi.CCLF1 ch 
			ON cHdrLatest.LatestClaimAdiKey = ch.URN  	
		where ast.SrcClaimType = 'INST' and cHdrLatest.SrcClaimType = 'INST'
		ORDER BY cd.CUR_CLM_UNIQ_ID, cd.CLM_LINE_NUM
	   ;

	-- if this fails it just stops. How should this work, structure from the WLC or AET COM care Op load, acedw do this soon.
	SELECT @OutCnt = COUNT(*) FROM #OutputTbl; 
	SET @ActionStart = GETDATE();    
	SET @JobStatus =2  -- complete
    
	EXEC amd.sp_AceEtlAudit_Close 
        @AuditId = @AuditID
        , @ActionStopTime = @ActionStart
        , @SourceCount = @InpCnt		  
        , @DestinationCount = @OutCnt
        , @ErrorCount = @ErrCnt
        , @JobStatus = @JobStatus
	   ;


