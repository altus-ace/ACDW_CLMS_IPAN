CREATE PROCEDURE [adw].[DataAdj_SubscriberId]  
AS
	select 'THis was used in ccaco with HICN, not here with MBI';
/*
    BEGIN TRAN ClmsMbr;

	   MERGE adw.Claims_Member TRG
	   USING (--SELECT all mbrs Sub iD, and Calc new sub ID, where it doesnt join clmsMember	   
	   	   SELECT SUBSCRIBER_ID, LenSubID, SUBSTRING(s.SUBSCRIBER_ID,12, len(s.SUBSCRIBER_ID)) NewSubId
	   		  FROM (SELECT len(SUBSCRIBER_ID) LenSubID, SUBSCRIBER_ID
	   				FROM adw.Claims_Member m
	   				    ) s
	   		  WHERE s.LenSubID > 11
	   	   )src
	   ON TRG.SUBSCRIBER_ID = SRC.SUBSCRIBER_ID
	   WHEN MATCHED THEN 
	       UPDATE SET TRG.SUBSCRIBER_ID = SRC.NewSubId
	       ;
    COMMIT TRAN ClmsMbr;

    -- Diags
    
    BEGIN TRAN ClmsDg;
    
    MERGE adw.Claims_Diags TRG
    USING (SELECT URN, SUBSCRIBER_ID, LenSubID, SUBSTRING(s.SUBSCRIBER_ID,12, len(s.SUBSCRIBER_ID)) NewSubId
    	   FROM (SELECT URN, len(SUBSCRIBER_ID) LenSubID, SUBSCRIBER_ID
    	   	   FROM adw.Claims_Diags m) s
    	   WHERE s.LenSubID > 11) SRC
    ON TRG.URN = SRC.URN
    WHEN MATCHED THEN 
        UPDATE SET TRG.SUBSCRIBER_ID = SRC.NewSubID
        ;
    
    --ROLLBACK TRAN ClmSDg;
    COMMIT TRAN ClmsDg;
    
    --Procs
    BEGIN TRAN ClmsPrc;
    
    MERGE adw.Claims_Procs TRG
    USING (SELECT URN, SUBSCRIBER_ID, LenSubID, SUBSTRING(s.SUBSCRIBER_ID,12, len(s.SUBSCRIBER_ID)) NewSubId
    	   FROM (SELECT URN, len(SUBSCRIBER_ID) LenSubID, SUBSCRIBER_ID
    		  	   FROM adw.Claims_Procs m) s
    	   WHERE s.LenSubID > 11) SRC
    ON TRG.URN = SRC.URN
    WHEN MATCHED THEN 
        UPDATE SET TRG.SUBSCRIBER_ID = SRC.NewSubID
        ;
    
    --ROLLBACK TRAN ClmsPrc;
    COMMIT TRAN ClmsPrc;
    
    --Hdrs
    BEGIN TRAN ClmsHdrs;
    
    MERGE adw.Claims_Headers TRG
    USING (SELECT s.SEQ_CLAIM_ID, SUBSCRIBER_ID, LenSubID, SUBSTRING(s.SUBSCRIBER_ID,12, len(s.SUBSCRIBER_ID)) NewSubId
    	   FROM (SELECT m.SEQ_CLAIM_ID, len(m.SUBSCRIBER_ID) LenSubID, m.SUBSCRIBER_ID	   
    		  	   FROM adw.Claims_Headers m) s
    	   WHERE s.LenSubID > 11) SRC
    ON TRG.SEQ_CLAIM_ID = SRC.SEQ_CLAIM_ID
    WHEN MATCHED THEN 
        UPDATE SET TRG.SUBSCRIBER_ID = SRC.NewSubID
        ;
    
    --ROLLBACK TRAN ClmsHdrs;
    COMMIT TRAN ClmsHdrs;
	*/
