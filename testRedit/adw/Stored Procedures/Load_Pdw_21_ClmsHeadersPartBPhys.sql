				 
CREATE PROCEDURE [adw].[Load_Pdw_21_ClmsHeadersPartBPhys]
AS 
	/* prepare logging */
	DECLARE @AuditId INT;    
	DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
	DECLARE @JobType SmallInt = 8	  -- ADW load
	DECLARE @ClientKey INT	 = 25;		-- ipan
	DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF5'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Headers'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
    SELECT @InpCnt = COUNT(distinct hdr.CUR_CLM_UNIQ_ID) 
	FROM ast.pstDeDupClms_PartBPhys ast
		JOIN (SELECT ast.CUR_CLM_UNIQ_ID, MIN(ast.CLM_LINE_NUM)	   CLM_LINE_NUM
				FROM ast.pstDeDupClms_PartBPhys ast
				GROUP BY ast.CUR_CLM_UNIQ_ID) Hdr 
			ON ast.CUR_CLM_UNIQ_ID = Hdr.CUR_CLM_UNIQ_ID 
			AND ast.CLM_LINE_NUM = Hdr.CLM_LINE_NUM
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
	IF OBJECT_ID(N'tempdb..#OutputTbl') IS NOT NULL
		DROP TABLE #OutputTbl
	CREATE TABLE #OutputTbl (ID NUMERIC(18) NOT NULL PRIMARY KEY);	

    INSERT INTO adw.Claims_Headers
           ( SEQ_CLAIM_ID							
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
			,SrcAdiTableName
			,SrcAdiKey              					
			,LoadDate								
           )    
	OUTPUT Inserted.SEQ_CLAIM_ID INTO #OutputTbl(ID)
    SELECT		
	    ch.CUR_CLM_UNIQ_ID									AS	SEQ_CLAIM_ID								-- SEQ_CLAIM_ID									 
		,ch.BENE_MBI_ID										AS	SUBSCRIBER_ID          		     			--,SUBSCRIBER_ID          						 
		,ch.CUR_CLM_UNIQ_ID									AS	CLAIM_NUMBER           		     			--,CLAIM_NUMBER           						 
		,CASE ch.CLM_TYPE_CD																				
			WHEN 10 THEN 'OTHER'																			
			WHEN 20 THEN 'OTHER'																			
			WHEN 30 THEN 'OTHER'																			
			WHEN 40 THEN 'OUTPATIENT'																		
			WHEN 50 THEN 'HOSPICE'																			
			WHEN 60 THEN 'INPATIENT'																		
			WHEN 70 THEN 'PHYSICIAN'																		
			WHEN 71 THEN 'PHYSICIAN'																		
			WHEN 72 THEN 'PHYSICIAN'																		
			WHEN 81 THEN 'PHYSICIAN DME'																	
			WHEN 81 THEN 'PHYSICIAN DME'																	
			ELSE 'Unkn: '																					
				+ CONVERT(VARCHAR(10), ch.CLM_TYPE_CD)	END AS	CATEGORY_OF_SVC        						--,CATEGORY_OF_SVC  
		,''								   					AS	PAT_CONTROL_NO								--,PAT_CONTROL_NO										 
		,''													AS	ICD_PRIM_DIAG          						--,ICD_PRIM_DIAG          
		,ch.CLM_LINE_FROM_DT									    AS	PRIMARY_SVC_DATE       						--,PRIMARY_SVC_DATE       
		,ch.CLM_LINE_THRU_DT									    AS	SVC_TO_DATE            						--,SVC_TO_DATE   
		,ch.CLM_THRU_DT									    AS	CLAIM_THRU_DATE        						--,CLAIM_THRU_DATE        										 
		,'01/01/1900'									    AS	POST_DATE              						--,POST_DATE 										 
		,'01/01/1900'										AS	CHECK_DATE             			 			--,CHECK_DATE             
		,''													AS	CHECK_NUMBER           			 			--,CHECK_NUMBER           
		,'01/01/1900'										AS	DATE_RECEIVED          			    		--,DATE_RECEIVED          
		,'01/01/1900'										AS	ADJUD_DATE             			 			--,ADJUD_DATE             
		, ''					 							AS   CMS_CertNum								--,CMS_CertificationNumber
		,''												AS	SVC_PROV_ID            							--,SVC_PROV_ID            
		,''												AS	SVC_PROV_FULL_NAME     							--,SVC_PROV_FULL_NAME     
		,ch.RNDRG_PRVDR_NPI_NUM	    					AS	SVC_PROV_NPI           							--,SVC_PROV_NPI           
		,ch.CLM_PRVDR_SPCLTY_CD				   			AS	PROV_SPEC              							--,PROV_SPEC              
		,ch.RNDRG_PRVDR_TYPE_CD		    		  		AS	PROV_TYPE              							--,PROV_TYPE              
		,''												AS	PROVIDER_PAR_STAT      							--,PROVIDER_PAR_STAT      
		,''												AS	ATT_PROV_ID            							--,ATT_PROV_ID            
		,''												AS	ATT_PROV_FULL_NAME     							--,ATT_PROV_FULL_NAME     
		,''			   									AS	ATT_PROV_NPI           							--,ATT_PROV_NPI           
		,''												AS	REF_PROV_ID            							--,REF_PROV_ID            
		,''												AS	REF_PROV_FULL_NAME     							--,REF_PROV_FULL_NAME     
		,ch.RNDRG_PRVDR_NPI_NUM							AS	VENDOR_ID              							--,VENDOR_ID              
		,''												AS	VEND_FULL_NAME      		 					--,VEND_FULL_NAME         
		,ch.CLM_RNDRG_PRVDR_TAX_NUM						AS	IRS_TAX_ID             							--,IRS_TAX_ID             
		,''	    										AS	DRG_CODE               							--,DRG_CODE 
		,''									 			AS	BILL_TYPE              							--,BILL_TYPE
		,'01/01/1900'									AS	ADMISSION_DATE         							--,ADMISSION_DATE         
		,''												AS	AUTH_NUMBER            							--,AUTH_NUMBER            
		,''												AS	ADMIT_SOURCE_CODE      							--,ADMIT_SOURCE_CODE      
		,''												AS	ADMIT_HOUR             							--,ADMIT_HOUR             
		,''												AS	DISCHARGE_HOUR         							--,DISCHARGE_HOUR         
		,''												AS	PATIENT_STATUS         							--,PATIENT_STATUS         
		,ch.CLM_CARR_PMT_DNL_CD							AS	CLAIM_STATUS           							--,CLAIM_STATUS           
		,''												AS	PROCESSING_STATUS      							--,PROCESSING_STATUS      
	    ,ch.CLM_TYPE_CD									AS	CLAIM_TYPE             							--,CLAIM_TYPE             
		,0 												AS	TOTAL_BILLED_AMT       							--,TOTAL_BILLED_AMT       
		,0												AS	TOTAL_PAID_AMT         							--,TOTAL_PAID_AMT         
		,0	 											AS	CalcdTotalBilledAmount 							--,CalcdTotalBilledAmount 
		,''												AS	BENE_PTNT_STUS_CD      							--,BENE_PTNT_STUS_CD      
		,''				  								AS  discharge_Dispo									--,DISCHARGE_DISPO	
		, @SrcName										AS  SrcAdiTableName									--,SrcAdiTableName									 
		,ch.URN											AS	SrcAdiKey              		              		--,SrcAdiKey              								 
		,GetDate()										AS	LoadDate               							--,LoadDate	
	FROM adi.CCLF5 ch
	   JOIN (SELECT ast.srcAdiKey, ast.CUR_CLM_UNIQ_ID, ast.CLM_FROM_DT, ast.CLM_THRU_DT, ast.BENE_MBI_ID, ast.CLM_LINE_NUM
				FROM ast.pstDeDupClms_PartBPhys ast
				JOIN (SELECT ast.CUR_CLM_UNIQ_ID, MIN(ast.CLM_LINE_NUM)	   CLM_LINE_NUM
						FROM ast.pstDeDupClms_PartBPhys ast
						GROUP BY ast.CUR_CLM_UNIQ_ID) Hdr 
						ON ast.CUR_CLM_UNIQ_ID = Hdr.CUR_CLM_UNIQ_ID 
							AND ast.CLM_LINE_NUM = Hdr.CLM_LINE_NUM
					) Hdr			
		ON ch.URN = hdr.srcAdiKey			
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
			 

	-- UPdate Totally billed
	/*
	UPDATE v set v.TOTAL_BILLED_AMT = isNULL(tb.TotalBilled, 0)
	FROM adw.Claims_Headers  v
	jOIN (	SELECT sum(v.LineBilled) TotalBilled, v.Amerigroup_MedClaimDetlKey
				FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimDetl]  v
				GROUP BY  v.Amerigroup_MedClaimDetlKey
				) TB ON v.SrcAdiKey  = tb.Amerigroup_MedClaimDetlKey
				
-- Update total Paid
UPDATE v set v.TOTAL_PAID_AMT = isNULL(tp.TotalPaid, 0)
	FROM adw.Claims_Headers  v
	jOIN (SELECT sum(v.LinePaid) TotalPaid, v.Amerigroup_MedClaimDetlKey
				FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimDetl]  v
				GROUP BY  v.Amerigroup_MedClaimDetlKey
				) Tp ON v.SrcAdiKey  = tp.Amerigroup_MedClaimDetlKey

-- update status code
UPDATE v set v.CLAIM_STATUS = isNULL(sc.StatusCode, 0)
	FROM adw.Claims_Headers  v
	jOIN (SELECT v.StatusCode StatusCode, v.Amerigroup_MedClaimDetlKey
				FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimDetl]  v
								) sc ON v.SrcAdiKey  = sc.Amerigroup_MedClaimDetlKey
--JOIN [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_MedClaimDetl] cd
--		  ON ch.ClaimNbr = cd.ClaimNbr
--		  AND ch.DataDate = cd.DataDate

*/