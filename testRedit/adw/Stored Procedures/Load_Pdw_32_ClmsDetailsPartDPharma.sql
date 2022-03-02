
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
CREATE PROCEDURE [adw].[Load_Pdw_32_ClmsDetailsPartDPharma]
AS 
    /* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 8	  -- ADW load
    DECLARE @ClientKey INT	 = 16; -- mssp
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF7'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Details'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
    SELECT @InpCnt = COUNT(cl.adiCCLF7_SKey)    
    FROM ast.Claim_04_Detail_Dedup ast
	   JOIN adi.CCLF7 cl
		  ON ast.ClaimDetailSrcAdiKey = cl.adiCCLF7_SKey
		  and ast.SrcClaimType = 'RX'
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
               (CLAIM_NUMBER                
			,SUBSCRIBER_ID				
			,SEQ_CLAIM_ID                
			,LINE_NUMBER                 
			,SUB_LINE_CODE               
			,DETAIL_SVC_DATE             
			,SVC_TO_DATE                 
			,PROCEDURE_CODE              
			,MODIFIER_CODE_1             
			,MODIFIER_CODE_2             
			,MODIFIER_CODE_3             
			,MODIFIER_CODE_4             
			,REVENUE_CODE                
			,PLACE_OF_SVC_CODE1          
			,PLACE_OF_SVC_CODE2          
			,PLACE_OF_SVC_CODE3          
			,QUANTITY                    
			,BILLED_AMT                  
			,PAID_AMT                    
			,NDC_CODE                    
			,RX_GENERIC_BRAND_IND        
			,RX_SUPPLY_DAYS              
			,RX_DISPENSING_FEE_AMT       
			,RX_INGREDIENT_AMT           
			,RX_FORMULARY_IND            
			,RX_DATE_PRESCRIPTION_WRITTEN
			,RX_DATE_PRESCRIPTION_FILLED
			,PRESCRIBING_PROV_TYPE_ID	   
			,PRESCRIBING_PROV_ID			
			,BRAND_NAME                  
			,DRUG_STRENGTH_DESC          
			,GPI                         
			,GPI_DESC                    
			,CONTROLLED_DRUG_IND         
			,COMPOUND_CODE           
			,srcAdiTableName
			,SrcAdiKey                   
			, LoadDate                    				
				)
    OUTPUT Inserted.ClaimsDetailsKey INTO #OutputTbl(ID)	
	SELECT           
		 cl.CUR_CLM_UNIQ_ID					AS CLAIM_NUMBER					--CLAIM_NUMBER                CLAIM_NUMBER                
		,cl.BENE_MBI_ID		  				AS SUBSCRIBER_ID				--SUBSCRIBER_ID				SUBSCRIBER_ID				
		,cl.CUR_CLM_UNIQ_ID					AS SEQ_CLAIM_ID					--SEQ_CLAIM_ID                SEQ_CLAIM_ID                
		,cl.CLM_LINE_RX_FILL_NUM	 		AS LINE_NUMBER					--LINE_NUMBER                 LINE_NUMBER                 
		,''					 				AS SUB_LINE_CODE				--SUB_LINE_CODE               SUB_LINE_CODE               
		,cl.CLM_LINE_FROM_DT			    AS DETAIL_SVC_DATE				--DETAIL_SVC_DATE             DETAIL_SVC_DATE             
		,cl.CLM_LINE_FROM_DT				AS SVC_TO_DATE					--SVC_TO_DATE                 SVC_TO_DATE                 
		,''									AS PROCEDURE_CODE				--PROCEDURE_CODE              PROCEDURE_CODE              
		,''									AS MODIFIER_CODE_1				--MODIFIER_CODE_1             MODIFIER_CODE_1             
		,''									AS MODIFIER_CODE_2				--MODIFIER_CODE_2             MODIFIER_CODE_2             
		,''									AS MODIFIER_CODE_3				--MODIFIER_CODE_3             MODIFIER_CODE_3             
		,''									AS MODIFIER_CODE_4				--MODIFIER_CODE_4             MODIFIER_CODE_4             
		,''									AS REVENUE_CODE					--REVENUE_CODE                REVENUE_CODE                
		,''									AS PLACE_OF_SVC_CODE1			--PLACE_OF_SVC_CODE1          PLACE_OF_SVC_CODE1          
		,''									AS PLACE_OF_SVC_CODE2			--PLACE_OF_SVC_CODE2          PLACE_OF_SVC_CODE2          
		,''									AS PLACE_OF_SVC_CODE3			--PLACE_OF_SVC_CODE3          PLACE_OF_SVC_CODE3          
		,cl.CLM_LINE_SRVC_UNIT_QTY		   	AS QUANTITY						--QUANTITY                    	   --QUANTITY                    GK I DON't think this is right
		,''									AS BILLED_AMT					--BILLED_AMT                  BILLED_AMT                  
		,cl.CLM_LINE_BENE_PMT_AMT    		AS PAID_AMT						--PAID_AMT                    PAID_AMT                    
		,cl.CLM_LINE_NDC_CD					AS NDC_CODE						--NDC_CODE                    NDC_CODE                    
		,''									AS RX_GENERIC_BRAND_IND			--RX_GENERIC_BRAND_IND        RX_GENERIC_BRAND_IND        
		,cl.CLM_LINE_DAYS_SUPLY_QTY  		AS RX_SUPPLY_DAYS				--RX_SUPPLY_DAYS              RX_SUPPLY_DAYS              
		,''					 				AS RX_DISPENSING_FEE_AMT		--RX_DISPENSING_FEE_AMT       RX_DISPENSING_FEE_AMT       
		,''									AS RX_INGREDIENT_AMT			--RX_INGREDIENT_AMT           RX_INGREDIENT_AMT           
		,''									AS RX_FORMULARY_IND				--RX_FORMULARY_IND            RX_FORMULARY_IND            
		,''									AS RX_DATE_PRESCRIPTION_WRITTEN	--RX_DATE_PRESCRIPTION_WRITTENRX_DATE_PRESCRIPTION_WRITTEN
		,''				    				AS RX_DATE_PRESCRIPTION_FILLED	--RX_DATE_PRESCRIPTION_FILLEDRX_DATE_PRESCRIPTION_FILLED
		,''									AS PRESCRIBING_PROV_TYPE_ID		--PRESCRIBING_PROV_TYPE_ID	   PRESCRIBING_PROV_TYPE_ID	   
		,cl.CLM_SRVC_PRVDR_GNRC_ID_NUM		AS PRESCRIBING_PROV_ID			--PRESCRIBING_PROV_ID			PRESCRIBING_PROV_ID			   
		,''									AS BRAND_NAME					--BRAND_NAME                  BRAND_NAME                  
		,''									AS DRUG_STRENGTH_DESC			--DRUG_STRENGTH_DESC          DRUG_STRENGTH_DESC          
		,''									AS GPI							--GPI                         GPI                         
		,''									AS GPI_DESC						--GPI_DESC                    GPI_DESC                    
		,''									AS CONTROLLED_DRUG_IND			--CONTROLLED_DRUG_IND         CONTROLLED_DRUG_IND         
		,''									AS COMPOUND_CODE				--COMPOUND_CODE           COMPOUND_CODE               
		,'CCLF7'							AS SrcAdiTableName				--srcAdiTableNameSrcAdiTableName
		, cl.adiCCLF7_SKey					AS SrcAdiKey					--SrcAdiKey                      --SrcAdiKey                   	
		, GetDate()							AS LoadDate						--LoadDate                    				LoadDate	 
	 FROM ast.Claim_04_Detail_Dedup ast
	   JOIN adi.CCLF7 cl
		  ON ast.ClaimDetailSrcAdiKey = cl.adiCCLF7_SKey
		  and ast.SrcClaimType = 'RX'
    ;

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

	
