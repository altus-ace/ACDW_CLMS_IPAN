
CREATE PROCEDURE [adw].[Load_Pdw_31_ClmsHeadersPartdPharma]
AS 
	/* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 8	  -- ADW load
    DECLARE @ClientKey INT	 = 16; -- mssp
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF7'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Headers'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
	SELECT @InpCnt = COUNT(*) 
	FROM adi.CCLF7 ch		
	   JOIN ast.Claim_03_Header_LatestEffective LEff
			ON ch.adiCCLF7_SKey = LEff.LatestClaimAdiKey
				AND LEff.LatestClaimAdiKey = LEff.ReplacesAdiKey
				and lEff.SrcClaimType = 'RX'
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
	CREATE TABLE #OutputTbl (ID VARCHAR(50) NOT NULL PRIMARY KEY);	

    -- Insert claims headers for Steward_MSSPPartBPhysicianClaimLineItem
    INSERT INTO adw.Claims_Headers(		
		SEQ_CLAIM_ID					
		,SUBSCRIBER_ID          
		,CLAIM_NUMBER           
		,CATEGORY_OF_SVC        
		,PAT_CONTROL_NO
		,ICD_PRIM_DIAG          
		,PRIMARY_SVC_DATE       
		,SVC_TO_DATE            
		,CLAIM_THRU_DATE        
		,POST_DATE              
		,CHECK_DATE             
		,CHECK_NUMBER           
		,DATE_RECEIVED          
		,ADJUD_DATE             
		,CMS_CertificationNumber
		,SVC_PROV_ID            
		,SVC_PROV_FULL_NAME     
		,SVC_PROV_NPI           
		,PROV_SPEC              
		,PROV_TYPE              
		,PROVIDER_PAR_STAT      
		,ATT_PROV_ID            
		,ATT_PROV_FULL_NAME     
		,ATT_PROV_NPI           
		,REF_PROV_ID            
		,REF_PROV_FULL_NAME     
		,VENDOR_ID              
		,VEND_FULL_NAME         
		,IRS_TAX_ID             
		,DRG_CODE               
		,BILL_TYPE              
		,ADMISSION_DATE         
		,AUTH_NUMBER            
		,ADMIT_SOURCE_CODE      
		,ADMIT_HOUR             
		,DISCHARGE_HOUR         
		,PATIENT_STATUS         
		,CLAIM_STATUS           
		,PROCESSING_STATUS      
		,CLAIM_TYPE             
		,TOTAL_BILLED_AMT       
		,TOTAL_PAID_AMT         
		,CalcdTotalBilledAmount 
		,BENE_PTNT_STUS_CD      
		,DISCHARGE_DISPO
		,srcAdiTableName
		,SrcAdiKey              
		,LoadDate
		)        
    OUTPUT Inserted.[SEQ_CLAIM_ID] INTO #OutputTbl(ID)		   
    SELECT		
	    ch.CUR_CLM_UNIQ_ID								    AS	SEQ_CLAIM_ID				--SEQ_CLAIM_ID			
		,ch.BENE_MBI_ID			 					    AS	SUBSCRIBER_ID          		--,SUBSCRIBER_ID          
		,ch.CUR_CLM_UNIQ_ID								    AS	CLAIM_NUMBER           		--,CLAIM_NUMBER           
		,'PHARMACY'						   		    AS	CATEGORY_OF_SVC        		--,CATEGORY_OF_SVC        
		,''							   			    AS	PAT_CONTROL_NO				--,PAT_CONTROL_NO
		,''										    AS	ICD_PRIM_DIAG          		--,ICD_PRIM_DIAG          
		,ch.CLM_LINE_FROM_DT							    AS	PRIMARY_SVC_DATE       		--,PRIMARY_SVC_DATE       
		,ch.CLM_LINE_FROM_DT							    AS	SVC_TO_DATE            		--,SVC_TO_DATE            
		,ch.CLM_LINE_FROM_DT							    AS	CLAIM_THRU_DATE        		--,CLAIM_THRU_DATE        
		,'01/01/1900'								    AS	POST_DATE              		--,POST_DATE              
		,'01/01/1900'								    AS	CHECK_DATE             		--,CHECK_DATE             
		,''										    AS	CHECK_NUMBER           		--,CHECK_NUMBER           
		,'01/01/1900'								    AS	DATE_RECEIVED          		--,DATE_RECEIVED          
		,'01/01/1900'								    AS	ADJUD_DATE             		--,ADJUD_DATE             
		, ''					 					    AS    CMS_CertNum				--,CMS_CertificationNumber
		,''										    AS	SVC_PROV_ID            		--,SVC_PROV_ID            
		,''										    AS	SVC_PROV_FULL_NAME     		--,SVC_PROV_FULL_NAME     
		,ch.CLM_SRVC_PRVDR_GNRC_ID_NUM		  AS	SVC_PROV_NPI           		--,SVC_PROV_NPI           
		,''										    AS	PROV_SPEC              		--,PROV_SPEC              
		,''										    AS	PROV_TYPE              		--,PROV_TYPE              
		,''										    AS	PROVIDER_PAR_STAT      		--,PROVIDER_PAR_STAT      
		,''										    AS	ATT_PROV_ID            		--,ATT_PROV_ID            
		,''										    AS	ATT_PROV_FULL_NAME     		--,ATT_PROV_FULL_NAME     
		,''			   							    AS	ATT_PROV_NPI           		--,ATT_PROV_NPI           
		,''										    AS	REF_PROV_ID            		--,REF_PROV_ID            
		,''										    AS	REF_PROV_FULL_NAME     		--,REF_PROV_FULL_NAME     
		,''										    AS	VENDOR_ID              		--,VENDOR_ID              
		,''										    AS	VEND_FULL_NAME      		--,VEND_FULL_NAME         
		,''										    AS	IRS_TAX_ID             		--,IRS_TAX_ID             
		,''										    AS	DRG_CODE               		--,DRG_CODE               			
		,''									 	    AS	BILL_TYPE              		--,BILL_TYPE              
		,''										    AS	ADMISSION_DATE         		--,ADMISSION_DATE         
		,''										    AS	AUTH_NUMBER            		--,AUTH_NUMBER            
		,''										    AS	ADMIT_SOURCE_CODE      		--,ADMIT_SOURCE_CODE      
		,''										    AS	ADMIT_HOUR             		--,ADMIT_HOUR             
		,''										    AS	DISCHARGE_HOUR         		--,DISCHARGE_HOUR         
		,''										    AS	PATIENT_STATUS         		--,PATIENT_STATUS         
		,ch.CLM_ADJSMT_TYPE_CD						    AS	CLAIM_STATUS           		--,CLAIM_STATUS           
		,''										    AS	PROCESSING_STATUS      		--,PROCESSING_STATUS      
	   ,ch.CLM_ADJSMT_TYPE_CD							  	 	    AS	CLAIM_TYPE             		--,CLAIM_TYPE             
		,NULL									    AS	TOTAL_BILLED_AMT       		--,TOTAL_BILLED_AMT       
		,ch.CLM_LINE_BENE_PMT_AMT	    							    AS	TOTAL_PAID_AMT         		--,TOTAL_PAID_AMT         
		,'' 										    AS	CalcdTotalBilledAmount 		--,CalcdTotalBilledAmount 
		,'' 										    AS	BENE_PTNT_STUS_CD      		--,BENE_PTNT_STUS_CD      
		,''				  						    AS    discharge_Dispo			--,DISCHARGE_DISPO
		, 'CCLF7'						    AS    SrcAdiTableName			--,srcAdiTableName
		,ch.adiCCLF7_SKey							    AS	SrcAdiKey              		--,SrcAdiKey              
		,GetDate()								    AS	LoadDate               		--,LoadDate
		--	implicitly loaded by defaults: CreatedDate,CreatedBy,LastUpdatedDate,LastUpdatedBy,	
	FROM adi.CCLF7 ch		
	   JOIN ast.Claim_03_Header_LatestEffective LEff
			ON ch.adiCCLF7_SKey = LEff.LatestClaimAdiKey
				AND LEff.LatestClaimAdiKey = LEff.ReplacesAdiKey
				and lEff.SrcClaimType = 'RX'
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


