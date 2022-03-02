CREATE PROCEDURE [adw].[Transform_Pdw_HdrsAggProvSpecFromDetail]
AS 
	/* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 12	  -- AST load
    DECLARE @ClientKey INT	 = 25; -- mssp
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.Steward_BCBS_InstitutionalClaim'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Headers'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;

	/* inst */

    SELECT @InpCnt = COUNT(*)		-- count target table    
	FROM adw.Claims_Headers h
	WHERE h.srcadiTablename = 'Steward_BCBS_InstitutionalClaim'	

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
    CREATE TABLE #OutputTbl (ID VARCHAR(50) PRIMARY KEY NOT NULL);	

      
    UPDATE ch			
	   set ch.PROV_SPEC = FromDetails.ServicingProviderSpecialtyDescrip
    OUTPUT inserted.SEQ_CLAIM_ID INTO #OutputTbl(id)
    FROM adw.Claims_Headers ch 
	   JOIN (SELECT src.claimID, src.ServicingProviderSpecialtyDescrip
				FROM (SELECT cl.claimID,  cl.ServicingProviderSpecialtyDescrip, cl.LLDateService
						, ROW_NUMBER() OVER (PARTITION BY cl.claimID ORDER BY cl.LLDateService DESC) AS aRowNum
						FROM adi.Steward_BCBS_InstitutionalClaim cl
							JOIN ast.Claim_04_Detail_Dedup LEff
								 ON cl.InstitutionalClaimKey = LEff.ClaimDetailSrcAdiKey    				    
									AND lEff.SrcClaimType = 'INST'
						WHERE cl.ClaimRecordID = 'LIN'
							AND cl.ServicingProviderSpecialtyDescrip <>  ''
					) src
				WHERE src.aRowNum = 1
			) FromDetails
	    ON CH.seq_claim_id = FromDetails.ClaimID 
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

	/* PROF CLAIMS */
	set @ActionStart = GETDATE();
    set @SrcName = 'adi.Steward_BCBS_InstitutionalClaim'    
    SET @InpCnt = -1;
    SET @OutCnt = -1;
    SET @ErrCnt = -1;
	/* inst */
    SELECT @InpCnt = COUNT(*)		-- count target table    	
	FROM adw.Claims_Headers h
	WHERE h.srcadiTablename = 'Steward_BCBS_ProfessionallClaim'	

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
    truncate table #outputTbl;
	
    UPDATE ch			
	   set ch.PROV_SPEC = FromDetails.ServicingProviderSpecialtyDescrip
    OUTPUT inserted.SEQ_CLAIM_ID INTO #OutputTbl(id)
    FROM adw.Claims_Headers ch 
	   JOIN (SELECT src.claimID, src.ServicingProviderSpecialtyDescrip
				FROM (SELECT cl.claimID,  cl.ServicingProviderSpecialtyDescrip, cl.LLDateService
						, ROW_NUMBER() OVER (PARTITION BY cl.claimID ORDER BY cl.LLDateService DESC) AS aRowNum
						FROM adi.Steward_BCBS_ProfessionallClaim cl
							JOIN ast.Claim_04_Detail_Dedup LEff
								 ON cl.ProfessionalClaimKey = LEff.ClaimDetailSrcAdiKey    				    
									AND lEff.SrcClaimType = 'PROF'
						WHERE cl.ClaimRecordID = 'LIN'
						  and cl.ServicingProviderSpecialtyDescrip <>  ''
					) src
				WHERE src.aRowNum = 1
			) FromDetails
	    ON CH.seq_claim_id = FromDetails.ClaimID 
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
