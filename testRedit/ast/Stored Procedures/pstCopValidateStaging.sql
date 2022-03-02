



CREATE PROCEDURE [ast].[pstCopValidateStaging]
    (@QMDate DATE, @ClientKey INT)
AS 
    /* Validations: 
	   */
	   
     DECLARE @OutputTbl TABLE (ID INT);	
    --DECLARE @LoadDate Date = CONVERT(date, GETDATE()) ;	

    /* Log Stag Load */    
    DECLARE @AuditID INT 
    DECLARE @AuditStatus SmallInt= 1 -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt     ;
    DECLARE @JobStatus tinyInt = 1	;
    DECLARE @JobName VARCHAR(200) = 'pstCopValidateStaging'
    DECLARE @ActionStartTime DATETIME = getdate();
    DECLARE @ActionStopTime DATETIME = getdate()
    DECLARE @InputSourceName VARCHAR(200) ;
	   SELECT @InputSourceName = DB_NAME() + '.ast.QM_ResultByMember_History'	    
    DECLARE @DestinationName VARCHAR(200) ;
	   SELECT @DestinationName = DB_NAME() + '.ast.QM_ResultByMember_History';    
    DECLARE @ErrorName VARCHAR(200);
	   SELECT @ErrorName = DB_NAME() + '.ast.QM_ResultByMember_History';        
    DECLARE @SourceCount int = 0;         
    DECLARE @DestinationCount int = 0;    
    DECLARE @ErrorCount int = 0;    

    /* XXXXXXXXXXXXXXXXXXXXX Valdation of business rules : refactor to  ast.Pdw_QM_Validate XXXXXXXXXXXXX */
    /* Log validation process*/        
    SET @JobType	= 11	   -- 11 ast validation        
    SET @ActionStartTime = getdate();        
        	
    EXEC AceMetaData.amd.sp_AceEtlAudit_Open 
        @AuditID = @AuditID OUTPUT
        , @AuditStatus = @AuditStatus
        , @JobType = @JobType
        , @ClientKey = @ClientKey
        , @JobName = @JobName
        , @ActionStartTime = @ActionStartTime
        , @InputSourceName = @InputSourceName
        , @DestinationName = @DestinationName
        , @ErrorName = @ErrorName
        ;
	BEGIN TRY
    /* get the count of the source prior to updates */
     SELECT @SourceCount = COUNT(ast.pstQM_ResultByMbr_HistoryKey) 
	   FROM ast.QM_ResultByMember_History ast
	   WHERE ast.ClientKey = @ClientKey 
		  AND ast.QMDate = @QMDate
		  AND ast.astRowStatus IN ('Loaded');
		  
     /* Validate Biz Rules */


		/*Biz Rule1:	Invalidate inactive Members*/
		BEGIN    -- DECLARE @QMDATE DATE = '2021-11-15'  DECLARE @ClientKey INT = 12
		;WITH CTE_MbrActiveFlg
		AS
		(   
		SELECT	  stg.ClientMemberKey
				  ,vw.CLIENT_SUBSCRIBER_ID
				  ,stg.ClientKey
				  ,stg.MbrActiveFlg   
		FROM	  [ast].[QM_ResultByMember_History]  stg
		LEFT JOIN (SELECT  CLIENT_SUBSCRIBER_ID
					FROM   ACECAREDW.dbo.vw_ActiveMembers 
					WHERE  ClientKey = @ClientKey
				  )vw
		ON		  stg.ClientMemberKey = vw.CLIENT_SUBSCRIBER_ID
		WHERE	  stg.ClientKey = @ClientKey
		AND		  stg.QMDate = @QMDATE
		AND		  vw.CLIENT_SUBSCRIBER_ID IS NOT NULL
		)

		UPDATE 	CTE_MbrActiveFlg
		SET MbrActiveFlg = 1	
		  
		END
    		  
		/*Biz Rule 2: Update MbrCOPInContractFlg 
				Measure is not contracted with Ace. Flag contracted Measures as 1 and
				uncontracted as 0*/
		 BEGIN
		 ;With CTE_MbrCOPInContractFlg 
		  AS (
			SELECT	*
			FROM	(
						SELECT		qm.srcQmDescription
									,lst.Source
									,Destination
									,ClientMemberKey
									,QmMsrId
									,QmCntCat
									,MbrCOPInContractFlg
						FROM		ast.QM_ResultByMember_History qm
						JOIN		(SELECT Source,Destination
										FROM lst.ListAceMapping 
										WHERE ClientKey = @ClientKey 
										AND ACTIVE = 'Y'
									) lst
						ON			qm.QmMsrId  = lst.Destination
						WHERE		QMDate = @QMDate
					)src
			) 
			UPDATE	CTE_MbrCOPInContractFlg
			SET MbrCOPInContractFlg = 1

		END		

		/*Biz Rule 3: Update MbrCareOpToPlnFlg 
			Looking for Where Measure ID Exist in QM_ResultByMember_History Table and Plan Name does not exist in CareOpToPlan Table
					, ie QmMsrID IS NOT NULL AND PlanName IS NULL.
					That would mean QM_ID is not mapped to a plan
					*/
		BEGIN
		
		;WITH Cte_MbrCareOpToPlnFlg
		AS
		(
		SELECT	
				QmMsrId
				, MeasureID
				,PlanName
				,qm.MbrCareOpToPlnFlg
				,qm.srcQMID
		FROM	ast.QM_ResultByMember_History qm
		FULL OUTER JOIN 
				(SELECT MeasureID,PlanName 
					FROM lst.lstCareOpToPlan
					WHERE ClientKey = @ClientKey
					AND	ACTIVE = 'Y'
				) careopps
		ON		qm.QmMsrId = careopps.MeasureID
		WHERE	clientKey = @ClientKey
		AND		QMDate = @QMDate
		)
		UPDATE	Cte_MbrCareOpToPlnFlg
		SET MbrCareOpToPlnFlg = (CASE	WHEN QmMsrId IS NOT NULL AND MeasureID IS NOT NULL AND PlanName IS NOT NULL THEN 1
										WHEN QmMsrId IS NULL AND MeasureID IS NULL AND PlanName IS NULL THEN 3
									 ELSE 0 END)
		END
				
		
		/*Update RowStatus. When indices meet criteria, then Valid, else Not Valid*/
		BEGIN
		
		UPDATE	ast.QM_ResultByMember_History
		SET		astRowStatus =  (CASE WHEN MbrActiveFlg = 1 
										AND MbrCOPInContractFlg = 1 
										AND MbrCareOpToPlnFlg = 1 THEN 'Valid'
									ELSE 'Not Valid' END)
		WHERE	QMDate = @QMDate
		
		END


		     
    END TRY
    BEGIN CATCH
	   EXEC AceMetaData.amd.TCT_DbErrorWrite;	   
	   IF (XACT_STATE()) = -1
		  BEGIN
		  ROLLBACK TRANSACTION		  
		  END
	 -- Transaction committable
	   IF (XACT_STATE()) = 1
		  BEGIN
		  COMMIT TRANSACTION    ;		 
		  END 
	   /* write error log close */    
	   SET @ActionStopTime = getdate();    	   	   
	   SELECT @DestinationCount= 0;
	   SET @ErrorCount = @SourceCount;
	   SET @JobStatus = 3 -- error
	   EXEC AceMetaData.amd.sp_AceEtlAudit_Close 
		  @AuditId = @AuditID
		  , @ActionStopTime = @ActionStopTime
		  , @SourceCount = @SourceCount		  
		  , @DestinationCount = @DestinationCount
		  , @ErrorCount = @ErrorCount
		  , @JobStatus = @JobStatus
		  ;
	   ;THROW
    END CATCH

    /* close validate staging Log record */    
    SET @ActionStopTime = getdate();   
    SELECT @DestinationCount= COUNT(ID) FROM @OutputTbl;
    SET @ErrorCount = 0
    SET @JobStatus = 2

    EXEC AceMetaData.amd.sp_AceEtlAudit_Close 
        @AuditId = @AuditID
        , @ActionStopTime = @ActionStopTime
        , @SourceCount = @SourceCount		  
        , @DestinationCount = @DestinationCount
        , @ErrorCount = @ErrorCount
        , @JobStatus = @JobStatus
	   ;



	   /*
	   Retired:
	   ;WITH Cte_MbrCareOpToPlnFlg
		AS

		(
		SELECT		ClientMemberKey
					,QmMsrId
					,QmCntCat
					,srcQMID
					,srcQmDescription
					,MeasureID
					,CLIENT_SUBSCRIBER_ID
					,PLAN_CODE
					,PlanName  
					,MbrCOPInContractFlg,MbrActiveFlg,MbrCareOpToPlnFlg
		FROM		ast.QM_ResultByMember_History qm
		LEFT JOIN		(SELECT	careopps.PlanName
								,careopps.MeasureID
								,activembr.PLAN_CODE
								,activembr.CLIENT_SUBSCRIBER_ID
						 FROM	ACECAREDW.dbo.vw_ActiveMembers  activembr
						 JOIN	(	SELECT PlanName, MeasureID
									FROM   lst.lstCareOpToPlan
									WHERE  ClientKey = @ClientKey
									AND    ACTIVE = 'Y'
						 		)								careopps
						 ON		careopps.PlanName= activembr.PLAN_CODE
						 AND		careopps.PlanName = activembr.PLAN_CODE
						 WHERE	activembr.clientKey = @ClientKey
						 )tmp
		ON			qm.ClientMemberKey = tmp.CLIENT_SUBSCRIBER_ID
		AND			qm.QmMsrId = tmp.MeasureID
		WHERE		QMDate = @QMDate
		)
		UPDATE	Cte_MbrCareOpToPlnFlg
		SET MbrCareOpToPlnFlg = (CASE	WHEN QmMsrId IS NOT NULL THEN 1
										WHEN QmMsrId IS NULL 
											 AND (srcQMID IS NULL OR srcQMID = 'Not Mapped') THEN 3
										 ELSE 0 END)
	   */
