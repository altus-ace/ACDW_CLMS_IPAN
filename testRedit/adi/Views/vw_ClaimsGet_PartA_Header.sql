CREATE View adi.vw_ClaimsGet_PartA_Header
AS 

	SELECT		
	    ch.CUR_CLM_UNIQ_ID									AS	SEQ_CLAIM_ID				--SEQ_CLAIM_ID			
		,ch.BENE_MBI_ID										AS	SUBSCRIBER_ID          		--,SUBSCRIBER_ID          
		,ch.CUR_CLM_UNIQ_ID									AS	CLAIM_NUMBER           		--,CLAIM_NUMBER           		
		,CASE ch.CLM_TYPE_CD
			WHEN '10' THEN 'OTHER'															
			WHEN '20' THEN 'OTHER'															
			WHEN '30' THEN 'OTHER'															
			WHEN '40' THEN 'OUTPATIENT'														
			WHEN '50' THEN 'HOSPICE'														
			WHEN '60' THEN 'INPATIENT'														
			WHEN '70' THEN 'PHYSICIAN'														
			WHEN '71' THEN 'PHYSICIAN'														
			WHEN '72' THEN 'PHYSICIAN'														
			WHEN '81' THEN 'PHYSICIAN DME'													
			WHEN '81' THEN 'PHYSICIAN DME'													
			ELSE 'Unk: ' + 
				TRY_CONVERT(varchar(10), ch.CLM_TYPE_CD	) 
				END 										AS	CATEGORY_OF_SVC        		--,CATEGORY_OF_SVC        
		,''												   	AS	PAT_CONTROL_NO				
		,ch.PRNCPL_DGNS_CD									AS	ICD_PRIM_DIAG          		--,ICD_PRIM_DIAG          
		,ch.[CLM_FROM_DT]									AS	PRIMARY_SVC_DATE       		--,PRIMARY_SVC_DATE       
		,ch.[CLM_THRU_DT]									AS	SVC_TO_DATE            		--,SVC_TO_DATE            
		,ch.[CLM_FROM_DT]									AS	CLAIM_THRU_DATE        		
		,'01/01/1900'									    AS	POST_DATE              		
		,'01/01/1900'										AS	CHECK_DATE             		--,CHECK_DATE             
		,''													AS	CHECK_NUMBER           		--,CHECK_NUMBER           
		,'01/01/1900'										AS	DATE_RECEIVED          		--,DATE_RECEIVED          
		,'01/01/1900'										AS	ADJUD_DATE             		--,ADJUD_DATE             
		,ch.PRVDR_OSCAR_NUM	 							AS  CMS_CertNum					--,CMS_CertificationNumber
		,''													AS	SVC_PROV_ID            		--,SVC_PROV_ID            
		,''													AS	SVC_PROV_FULL_NAME     		--,SVC_PROV_FULL_NAME     
		,ch.OPRTG_PRVDR_NPI_NUM	    						AS	SVC_PROV_NPI           		--,SVC_PROV_NPI           
		,'No Data'											AS	PROV_SPEC              		--,PROV_SPEC              
		,'No Data'											AS	PROV_TYPE              		--,PROV_TYPE              
		,''												AS	PROVIDER_PAR_STAT      		--,PROVIDER_PAR_STAT      
		,''												AS	ATT_PROV_ID            		--,ATT_PROV_ID            
		,''												AS	ATT_PROV_FULL_NAME     		--,ATT_PROV_FULL_NAME     
		,ch.ATNDG_PRVDR_NPI_NUM							AS	ATT_PROV_NPI           		--,ATT_PROV_NPI           
		,''												AS	REF_PROV_ID            		--,REF_PROV_ID            
		,''												AS	REF_PROV_FULL_NAME     		--,REF_PROV_FULL_NAME     
		,ch.FAC_PRVDR_NPI_NUM							AS	VENDOR_ID              		--,VENDOR_ID              
		,''												AS	VEND_FULL_NAME      		--,VEND_FULL_NAME         will be a look up from NPPES   
		,''												AS	IRS_TAX_ID             		--,IRS_TAX_ID             
		,ch.[DGNS_DRG_CD]								AS	DRG_CODE               		--,DRG_CODE               --Remove leading zero						
		,CONCAT(ch.CLM_BILL_FAC_TYPE_CD,ch.CLM_BILL_CLSFCTN_CD,ch.CLM_BILL_FREQ_CD)		AS	BILL_TYPE   
		,ch.[CLM_FROM_DT]								as AdmitDate           				
		,ch.CLM_OP_SRVC_TYPE_CD						AS	AUTH_NUMBER            		--,AUTH_NUMBER            
		,CONCAT(ch.CLM_ADMSN_SRC_CD,'|',ch.CLM_ADMSN_TYPE_CD)							AS	ADMIT_SOURCE_CODE      		--,ADMIT_SOURCE_CODE      
		,''												AS	ADMIT_HOUR             		--,ADMIT_HOUR             
		,''												AS	DISCHARGE_HOUR         		--,DISCHARGE_HOUR         
		,Ch.[BENE_PTNT_STUS_CD]							AS	PATIENT_STATUS         		--,PATIENT_STATUS         
		,CONCAT(ch.CLM_QUERY_CD,'|',ch.CLM_ADJSMT_TYPE_CD)				AS	CLAIM_STATUS           		--,CLAIM_STATUS           
		,'P'											AS	PROCESSING_STATUS      		--,PROCESSING_STATUS      
		,ch.CLM_TYPE_CD									as  CLAIM_TYPE             
		,0												AS	TOTAL_BILLED_AMT
		,ch.CLM_PMT_AMT									AS	TOTAL_PAID_AMT 
		,'' 											AS	CalcdTotalBilledAmount 		--,CalcdTotalBilledAmount 
		,ch.BENE_PTNT_STUS_CD 							AS	BENE_PTNT_STUS_CD      		--,BENE_PTNT_STUS_CD      
		,ch.BENE_PTNT_STUS_CD 							AS  discharge_Dispo				--,DISCHARGE_DISPO
		, 'adi.cclf1'									AS  SrcAdiTableName
		, ch.URN										AS	SrcAdiKey              		--,SrcAdiKey              
		, ch.LoadDate									AS	LoadDate               		--,LoadDate
		, 'Inst'										AS srcClaimType
		, 'ch. superKey' AS SUPERKEY
	 FROM  [adi].CCLF1 ch	
	;		
				