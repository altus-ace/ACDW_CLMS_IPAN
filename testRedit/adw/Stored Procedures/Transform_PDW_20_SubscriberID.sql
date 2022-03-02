CREATE PROCEDURE [adw].[Transform_PDW_20_SubscriberID]
AS
BEGIN
    -- set up logging variables
    
    --CREATE TABLE #OutputTbl (ID INT NOT NULL PRIMARY KEY);		
    /* XXXXXXXXXXXXXXXXXX CLAIMS HEADERS  XXXXXXXXXXXXXXXXXXX*/
    BEGIN TRY      
	   BEGIN TRAN      
	   
	   UPDATE hdr SET hdr.SUBSCRIBER_ID = CMKH.CurrentClientMemberKey
	 --  OUTPUT UPDATED.SEQ_CLAIM_ID INTO #OutputTbl(ID)
	   FROM adw.Claims_Headers	 hdr
		  JOIN adw.MbrClientMemberKeyHistory CMKH 
			 ON hdr.SUBSCRIBER_ID = CMKH.PreviousClientMemberKey
	   COMMIT TRAN;        	    
    END TRY      
    BEGIN CATCH      
	   EXEC AceMetaData.amd.TCT_DbErrorWrite;          
	   IF (XACT_STATE()) = -1     		
		  ROLLBACK TRANSACTION          		  		  
	   IF (XACT_STATE()) = 1      		  		  
		  COMMIT TRANSACTION    ;         		  
	   /* write error log close */          
/*	   SET @ActionStop = getdate();              
	   /* get InpCnt  */
	   --SELECT @InpCnt = COUNT(*) FROM SOURCE ;      
	   SELECT @OutCnt = 0;      
	   SET @ErrCnt = @InpCnt;      
	   SET @JobStatus = 3 -- error      
	   EXEC AceMetaData.amd.sp_AceEtlAudit_Close       
		  @AuditId = @AuditID      
		  , @ActionStopTime = @ActionStop
		  , @SourceCount = @InpCnt          
		  , @DestinationCount = @OutCnt
		  , @ErrorCount = @ErrCnt      
		  , @JobStatus = @JobStatus      
		  ;      */
	   ;THROW      
    END CATCH        
    /* XXXXXXXXXXXXXXXXXX CLAIMS_DETIALS XXXXXXXXXXXXXXXXXXXX*/
     BEGIN TRY      
	   BEGIN TRAN      
	   
	   UPDATE dtl SET dtl.SUBSCRIBER_ID = CMKH.CurrentClientMemberKey
	   --  OUTPUT UPDATED.SEQ_CLAIM_ID INTO #OutputTbl(ID)
	   --SELECT dtl.ClaimsDetailsKey, dtl.SEQ_CLAIM_ID, dtl.SUBSCRIBER_ID, CMKH.CurrentClientMemberKey	   
	   FROM adw.Claims_Details	 dtl
		  JOIN adw.MbrClientMemberKeyHistory CMKH 
		  ON dtl.SUBSCRIBER_ID = CMKH.PreviousClientMemberKey

	   COMMIT TRAN;        	    
    END TRY      
    BEGIN CATCH      
	   EXEC AceMetaData.amd.TCT_DbErrorWrite;          
	   IF (XACT_STATE()) = -1     		
		  ROLLBACK TRANSACTION          		  		  
	   IF (XACT_STATE()) = 1      		  		  
		  COMMIT TRANSACTION    ;         		  
	   /* write error log close */          
	   /*	   
		  ;      */
	   ;THROW      
    END CATCH 
    /* XXXXXXXXXXXXXXXXXX Claims Diags   XXXXXXXXXXXXXXXXXXXX */    
     BEGIN TRY      
	   BEGIN TRAN      
	   
	   UPDATE dg SET dg.SUBSCRIBER_ID = CMKH.CurrentClientMemberKey
	   --  OUTPUT UPDATED.SEQ_CLAIM_ID INTO #OutputTbl(ID)
	   --  SELECT dg.URN , dg.SEQ_CLAIM_ID, dg.SUBSCRIBER_ID, CMKH.CurrentClientMemberKey
	   FROM adw.Claims_Diags	 dg
		  JOIN adw.MbrClientMemberKeyHistory CMKH 
			 ON dg.SUBSCRIBER_ID = CMKH.PreviousClientMemberKey
			 ;
	   COMMIT TRAN;        	    
    END TRY      
    BEGIN CATCH      
	   EXEC AceMetaData.amd.TCT_DbErrorWrite;          
	   IF (XACT_STATE()) = -1     		
		  ROLLBACK TRANSACTION          		  		  
	   IF (XACT_STATE()) = 1      		  		  
		  COMMIT TRANSACTION    ;         		  
	   /* write error log close */          
	   /*	   
		  ;      */
	   ;THROW      
    END CATCH 
  
	   /* XXXXXXXXXXXXXXXXXX CLAIMS_Procs XXXXXXXXXXXXXXXXXXXX*/
     BEGIN TRY      
	   BEGIN TRAN      
	   
	   UPDATE prc SET prc.SUBSCRIBER_ID = CMKH.CurrentClientMemberKey
	   --  OUTPUT UPDATED.SEQ_CLAIM_ID INTO #OutputTbl(ID)
	   --SELECT prc.URN, prc.SEQ_CLAIM_ID, prc.SUBSCRIBER_ID, CMKH.CurrentClientMemberKey
	   FROM adw.Claims_Procs	 prc
		  JOIN adw.MbrClientMemberKeyHistory CMKH 
			 ON prc.SUBSCRIBER_ID = CMKH.PreviousClientMemberKey
			 ;
	   COMMIT TRAN;        	    
    END TRY      
    BEGIN CATCH      
	   EXEC AceMetaData.amd.TCT_DbErrorWrite;          
	   IF (XACT_STATE()) = -1     		
		  ROLLBACK TRANSACTION          		  		  
	   IF (XACT_STATE()) = 1      		  		  
		  COMMIT TRANSACTION    ;         		  
	   /* write error log close */          
	   /*	   
		  ;      */
	   ;THROW      
    END CATCH 
    
       /* XXXXXXXXXXXXXXXXXX CLAIMS_Conditions XXXXXXXXXXXXXXXXXXXX*/
     BEGIN TRY      
	   DECLARE @ClmCondCnt INT;
	   SELECT @ClmCondCnt = COUNT(*) FROM adw.Claims_Conditions;

	   IF @ClmCondCnt > 0 
	   BEGIN
		  BEGIN TRAN      
	   
		  UPDATE cnd SET cnd.SUBSCRIBER_ID = CMKH.CurrentClientMemberKey
		  --  OUTPUT UPDATED.SEQ_CLAIM_ID INTO #OutputTbl(ID)
		  --SELECT cnd.URN, cnd.SEQ_CLAIM_ID, cnd.SUBSCRIBER_ID, CMKH.CurrentClientMemberKey
		  FROM adw.Claims_Conditions cnd
			 JOIN adw.MbrClientMemberKeyHistory CMKH 
				ON cnd.SUBSCRIBER_ID = CMKH.PreviousClientMemberKey
				;
		  COMMIT TRAN;        	    
	   END -- if cnt cond > 0
    END TRY      
    BEGIN CATCH      
	   EXEC AceMetaData.amd.TCT_DbErrorWrite;          
	   IF (XACT_STATE()) = -1     		
		  ROLLBACK TRANSACTION          		  		  
	   IF (XACT_STATE()) = 1      		  		  
		  COMMIT TRANSACTION    ;         		  
	   /* write error log close */          
	   /*	   
		  ;      */
	   ;THROW      
    END CATCH 
     /* XXXXXXXXXXXXXXXXXX CLAIMS_Conditions XXXXXXXXXXXXXXXXXXXX*/

    /* DO NOT UPDATE THE CLAIMS members, there is a RECORD for the all Client MemberKeys as is, leave it 
    SELECT mbr.SUBSCRIBER_ID, CMKH.PreviousClientMemberKey, CMKH.CurrentClientMemberKey
    FROM adw.Claims_Member	 mbr
    JOIN adw.MbrClientMemberKeyHistory CMKH 
	   ON mbr.SUBSCRIBER_ID = CMKH.PreviousClientMemberKey;

	   */

END;

