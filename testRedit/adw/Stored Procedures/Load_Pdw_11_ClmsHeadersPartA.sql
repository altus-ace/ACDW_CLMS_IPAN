



CREATE PROCEDURE [adw].[Load_Pdw_11_ClmsHeadersPartA]
AS    

	/* prepare logging */
	DECLARE @AuditId INT;    
	DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
	DECLARE @JobType SmallInt = 8	  -- AST load
	DECLARE @ClientKey INT	 = 25; -- ipan
	DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF1'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Headers'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
    SELECT @InpCnt = COUNT(*) 
	FROM adi.CCLF1  ch
	   JOIN ast.Claim_03_Header_LatestEffective lr 
		ON ch.URN = lr.LatestClaimAdiKey
			AND lr.LatestClaimAdiKey = lr.ReplacesAdiKey
			and lr.SrcClaimType = 'INST';

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

	CREATE TABLE #OutputTbl (Seq_claim_ID VARCHAR(50) PRIMARY KEY NOT NULL);	
	
    -- 1. Insert cliams Using LastClmRow set 
    BEGIN TRAN LoadPartAHeader
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
	OUTPUT INSERTED.SEQ_CLAIM_ID INTO #OutputTbl(Seq_claim_ID)			
     SELECT		
	    ch.CUR_CLM_UNIQ_ID									AS	SEQ_CLAIM_ID				--SEQ_CLAIM_ID			
		,ch.BENE_MBI_ID										AS	SUBSCRIBER_ID          		--,SUBSCRIBER_ID          
		,leff.clmSKey										AS	CLAIM_NUMBER           		--,CLAIM_NUMBER           		
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
		,ch.BENE_PTNT_STUS_CD 						AS	BENE_PTNT_STUS_CD      		--,BENE_PTNT_STUS_CD      
		,ch.BENE_PTNT_STUS_CD 						AS  discharge_Dispo				--,DISCHARGE_DISPO
		, 'adi.cclf1'									AS  SrcAdiTableName
		,Leff.LatestClaimAdiKey							AS	SrcAdiKey              		--,SrcAdiKey              
		,GetDate()										AS	LoadDate               		--,LoadDate
	 FROM  [adi].CCLF1 ch
		JOIN ast.Claim_03_Header_LatestEffective LEff
    		ON ch.URN = LEff.LatestClaimAdiKey
				AND LEff.LatestClaimAdiKey = LEff.ReplacesAdiKey
    			AND lEff.SrcClaimType = 'INST'
	;		
				
    ;--select dt.LineBilled,dt.LinePaid from [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimDetl] dt --ast.Claim_04_Detail_Dedup
	   	 
	COMMIT TRAN LoadPartAHeader;

	-- get total paid

	-- Update total Paid -- REVIEW DETAILS< CAN WE SUM TO HEADER< move to tranform function
/*
    UPDATE v set v.TOTAL_PAID_AMT = isNULL(tp.TotalPaid, 0)
	FROM adw.Claims_Headers  v
	   jOIN (SELECT sum(v.) TotalPaid, v.Amerigroup_MedClaimDetlKey
				FROM [adi].[CCLF2]  v
				GROUP BY  v.CUR_CLM_UNIQ_ID
				) Tp ON v.SrcAdiKey  = tp.Amerigroup_MedClaimDetlKey
	-- get total billed
	UPDATE h set h.TOTAL_BILLED_AMT = src_Tba.TotBillAmnt	--
	   FROM adw.Claims_Headers H	
		JOIN (SELECT H.SEQ_CLAIM_ID, SUM(cd.LineBilled) TotBillAmnt
			FROM adw.Claims_Headers H	
				JOIN ast.Claim_04_Detail_Dedup dd ON H.SEQ_CLAIM_ID = dd.ClaimSeqClaimId    			 
				JOIN adi.Amerigroup_MedClaimDetl cd ON dd.ClaimDetailSrcAdiKey = cd.Amerigroup_MedClaimDetlKey
			GROUP BY H.SEQ_CLAIM_ID
			) src_Tba on H.SEQ_CLAIM_ID = src_Tba.SEQ_CLAIM_ID;
*/    			 

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
