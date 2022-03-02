


create ProcedURE [adw].[Pdw_ExpAhs_AhsCareOpsToPrograms](    
    @QmBatchDate DATE, 
    @ClientKey INT
)
AS
BEGIN
    --DECLARE @QmBatchDate DATE = '11/15/2021'  
	   -- THIS IS THE Month you are running, it will also be the max loop on the rinse/repeat loop
	   -- it also goes in the adw table as the date the SET is for.
    --DECLARE @QmBatchDate DATE = '05/15/2021';	-- param  for the set to load at final
    
    DECLARE @InitialQmDate DATE; -- = '2021-03-15';  -- this is the first/earliest batch of qm for a client, 
    
    SELECT @InitialQmDate = min(m.QMDate)        
	FROM adw.QM_ResultByMember_History m	 
    WHERE m.ClientKey = @ClientKey 
	   AND m.QMDate > '05/01/2021';

    -- SELECT m.QMDate
    -- FROM adw.QM_ResultByMember_History m
    -- WHERE m.ClientKey = @ClientKey 
    -- GROUP BY m.qmDate

    DECLARE @CurrentBatch Date ; --The batch being loaded currently
    --SELECT @QmBatchDate, @ClientKey, @InitialQmDate    
    
    

    /*** Create and Insert Once ***/    
    --initialize qm list and working tables
    BEGIN           
	   /*  
		  DROP TABLE ast.QmList_Temp
		  CREATE TABLE ast.QmList_Temp ( QmMsrID VARCHAR(50), Invert BIT NOT NULL DEFAULT(0), InContract BIT NOT NULL DEFAULT(1) , EffectiveDate Date NOT NULL, ExpirationDate DATE NOT NULL);
	   */
	   TRUNCATE TABLE ast.QmList_Temp ;	   
	   INSERT INTO ast.QmList_Temp ( QmMsrID, Invert, InContract, EffectiveDate, ExpirationDate)
	   SELECT q.qm, 0, 1, EffectiveDate, ExpirationDate
	   FROM lst.LIST_QM_Mapping q
	   WHERE q.ClientKey = @ClientKey
		  
	  -- SELECT * FROM ast.QmList_Temp;
	   TRUNCATE table ast.qmToProgCurGaps;
	   TRUNCATE table ast.qmToProgBatchLog;
    END;
    
    -- create process management table, holds dates to iterate through, and a state value (0 not procesed, 1 processed)
    BEGIN
	   -- declare @ClientKey int = 3
	   -- DECLARE @InitialQmDate DATE = '2020-03-15';  -- this is the first/earliest batch of qm for a client, 
	   IF OBJECT_ID('tempdb..#tmpProcessDates') IS NOT NULL DROP TABLE #tmpProcessDates	  
	   CREATE TABLE #tmpProcessDates(skey INT NOT NULL IDENTITY(1,1) PRIMARY KEY, QMDate DATE , ProcessedState TINYINT DEFAULT(0));    
	   INSERT INTO #tmpProcessDates(QmDate, ProcessedState)
	   SELECT q.QMDate, 0    
	   FROM	 adw.QM_ResultByMember_History q
	   WHERE q.QMDate >= @InitialQmDate
	      AND q.ClientKey = @ClientKey
	   GROUP BY q.qmdate
	   ORDER BY q.qmdate asc;
	   --SELECT * FROM #tmpProcessDates;
    END;
    /* Initialize Data set */    
    -- SELECT * FROM ast.QmList_Temp ;	   
    --SELECT * FROM #tmpProcessDates;
    BEGIN
	   -- get the first month (@InitialQMDate ) set of qm     
	   INSERT INTO ast.QmToProgCurGaps ( ClientMemberKey	,QmMsrId ,QmCntCat	,QmDate,Addressed,RecStatus,CalcQmCntCat, Srckey, SrcTableName, ClientKey)
	
	   SELECT  QRes.ClientMemberKey, QRes.QmMsrId,  QRes.QmCntCat,QRes.QmDate, ISNULL(QRes.Addressed, 0), 'N' As RecStatus		-- Initial Set
	       ,CASE WHEN ((QRes.QmCntCat = 'NUM') AND (QmList.Invert = 1)) THEN 'COP'			 
	   			 WHEN (QRes.QmCntCat = 'COP') THEN 'COP'
	   			 ELSE 'NUM' 
	   		  END As CalcQmCntCat
	       , QRes.QM_ResultByMbr_HistoryKey AS SrcKey
	       , 'adw.QM_ResultByMember_History' AS SrcTable
	       , QRes.ClientKey
	   FROM adw.QM_ResultByMember_History QRes
	       LEFT JOIN ast.QmList_Temp QmList ON QRes.QmMsrId = QmList.QmMsrID	  
	   WHERE QRes.QMDate		= @InitialQmDate
		  AND @InitialQmDate between QmList.EffectiveDate and QmList.ExpirationDate
	       AND QmList.InContract = 1
	       AND	((QmList.Invert = 0 AND QRes.QmCntCat		= 'COP') Or (QmList.Invert = 1 and QmCntCat ='NUM'))    
	       --and QRes.QmMsrId = 'ACE_HEDIS_ACO_CBP' and QRes.ClientMemberKey = '1EY5GW8HV93'
	   ;	
	   
	   INSERT INTO ast.QmToProgBatchLog (ClientMemberKey,QmMsrId,QmCntCat,QmDate,RecStatus)			
	   	SELECT c.ClientMemberKey, c.QmMsrId, QmCntCat, c.QMDate, RecStatus
	   	FROM ast.QmToProgCurGaps c
			
    END
    --SELECT QmToProgBatchLog.* from ast.QmToProgBatchLog; 
    --SELECT cg.* from ast.QmToProgCurGaps cg 
   

    /*** Iterate from initialQmDate to MaxQmDate : Rinse and Repeat ***/
    -- step 2 Cycle through COP Months
    -- declare @CurrentBatch DATE;
    SELECT @CurrentBatch = Min(pd.QmDate)     
	   FROM #tmpProcessDates pd where pd.ProcessedState = 0;
    --SELECT @CurrentBatch;

    WHILE @CurrentBatch <= @QmBatchDate	   -- do not process a date a second time.
    BEGIN 
        /* clean up working tables */
        IF OBJECT_ID('tempdb..#tmpBatchCop') IS NOT NULL DROP TABLE #tmpBatchCop;
        IF OBJECT_ID('tempdb..#tmpBatchNum') IS NOT NULL DROP TABLE #tmpBatchNum;
        IF OBJECT_ID('tempdb..#tmpCopMatchGap') IS NOT NULL DROP TABLE #tmpCopMatchGap;
        IF OBJECT_ID('tempdb..#tmpNumMatchGap') IS NOT NULL DROP TABLE #tmpNumMatchGap;   
        /* insert WORKING COP */
        SELECT  QRes.ClientMemberKey, QRes.QmMsrId,  QRes.QmCntCat, QRes.QmDate, 'N' as QmStatus, ISNULL(QRes.Addressed, 0) Addressed
            ,CASE WHEN ((QRes.QmCntCat = 'NUM') AND (QmList.Invert = 1)) THEN 'COP'			 
    			 WHEN (QRes.QmCntCat = 'COP') THEN 'COP'
    			 ELSE 'NUM' 
    		  END As CalcQmCntCat
    	   , QRes.QM_ResultByMbr_HistoryKey AS SrcKey
    	   , 'adw.QM_ResultByMember_History' AS SrcTable
    	   , QRes.ClientKey
        INTO #tmpBatchCop	
        FROM adw.QM_ResultByMember_History QRes
    	   JOIN ast.QmList_Temp QmList ON QRes.QmMsrId = QmList.QmMsrID
        WHERE QMDate			= @CurrentBatch    	
	   and @CurrentBatch between QmList.EffectiveDate and QmList.ExpirationDate
    	   AND QmList.InContract = 1
    	   AND	((QmList.Invert = 0 AND QRes.QmCntCat		= 'COP') Or (QmList.Invert = 1 and QmCntCat ='NUM'))
    	   AND	ISNULL(QRes.Addressed, 0)	= 0 	   
    	   ;
    	   
        /* INSERT WORKING NUM */     
        SELECT  ClientMemberKey, QmMsrId,  QmCntCat, QmDate, QmStatus, Addressed, CalcQmCntCat
        INTO #tmpBatchNum		
        FROM (/* get NUMS */
    	   SELECT  qRes.ClientMemberKey, qRes.QmMsrId,  qRes.QmCntCat, qRes.QmDate, 'N' as QmStatus, ISNULL(qRes.Addressed,0) Addressed
    		  ,CASE WHEN ((QRes.QmCntCat = 'COP') AND (QmList.Invert = 1)) THEN 'NUM'			 			 
    			 ELSE 'NUM' 
    		  END As CalcQmCntCat
    	   FROM adw.QM_ResultByMember_History qRes
    		  JOIN ast.QmList_Temp QmList ON QRes.QmMsrId = QmList.QmMsrID
    	   WHERE QMDate			= @CurrentBatch   	   		  
    		  AND ((QmList.Invert = 0 AND QRes.QmCntCat		= 'NUM') Or (QmList.Invert = 1 and QmCntCat ='COP'))    	
    		  AND qRes.Addressed = 0	  
    	   UNION /* get addressed */
    	   SELECT  QRes.ClientMemberKey, QRes.QmMsrId,  qRes.QmCntCat, QRes.QmDate, 'N' as QmStatus, ISNULL(qRes.Addressed,0) Addressed
        		  ,CASE WHEN ((QRes.QmCntCat = 'NUM') AND (QmList.Invert = 1)) THEN 'NUM-A'			 			 
    			 ELSE 'NUM-A' 
    		  END As CalcQmCntCat
    	   FROM adw.QM_ResultByMember_History QRes
    		  JOIN ast.QmList_Temp QmList ON QRes.QmMsrId = QmList.QmMsrID
    	   WHERE QRes.QMDate			= @CurrentBatch   	       	   
        	   AND	QRes.Addressed	= 1
    	   AND ((QmList.Invert = 0 AND QRes.QmCntCat		= 'COP') Or (QmList.Invert = 1 and QmCntCat ='NUM'))    			   
        	) num		
    
    	/* Load working the Batch Num and Batch cop */    
        SELECT  Num.ClientMemberKey, Num.QmMsrId, Num.QMDate
    	   	INTO #tmpNumMatchGap		-- will become C
    	   	FROM #tmpBatchNum Num
    	   	JOIN ast.QmToProgCurGaps	CurGaps
    	   	ON	 Num.ClientMemberKey	= CurGaps.ClientMemberKey
    	   	AND NUM.QmMsrId				= CurGaps.QmMsrId
    	   	WHERE CurGaps.ClientMemberKey IS NOT NULL 		;
    
        /* Process: Find/match incoming gaps for existing, exclued existing that are 'C' closed */
        SELECT  COP.ClientMemberKey, COP.QmMsrId, COP.QMDate
      	   INTO #tmpCopMatchGap		 -- will become E
        	   FROM #tmpBatchCop COP
        	   JOIN ast.QmToProgCurGaps	CurGaps
        	   ON	 CurGaps.ClientMemberKey	= COP.ClientMemberKey
        	   AND CurGaps.QmMsrId				= COP.QmMsrId
        	   WHERE COP.ClientMemberKey IS NOT NULL 
    		  AND CurGaps.RecStatus <> 'C'  -- DO not match Incoming gaps on closed Gaps, only E or N		;
    	    
        /*** Close Gap if already present, Update RecStatus = C and RecStatusDate = Num Date ***/    
        UPDATE CurGap SET CurGap.RecStatus = 'C', CurGap.RecStatusDate = b.QMDate  -- date of NUM  	   
        	   FROM ast.QmToProgCurGaps CurGap
    		  JOIN #tmpNumMatchGap b
        		  ON CurGap.ClientMemberKey = b.ClientMemberKey
        		  AND CurGap.QmMsrId = b.QmMsrId
    	   
        -- Mark E in BatchCop    
        UPDATE BatchCop SET BatchCop.QmStatus = 'E'  --Existing	       
        	   FROM #tmpBatchCop BatchCop	 
    		  JOIN #tmpCopMatchGap MatchGap
    		  ON BatchCop.ClientMemberKey = MatchGap.ClientMemberKey
        			 AND BatchCop.QmMsrId = MatchGap.QmMsrId
        -- Mark E in CurGaps
        UPDATE CurGaps SET CurGaps.RecStatus = 'E', CurGaps.RecStatusDate = b.QMDate	           
        	   FROM ast.QmToProgCurGaps CurGaps 
    		  LEFT JOIN #tmpCopMatchGap b 
        		  ON CurGaps.ClientMemberKey = b.ClientMemberKey
        		  AND CurGaps.QmMsrId = b.QmMsrId
        	   WHERE CurGaps.RecStatus = 'N'
    	   
    	   
        /*** Insert New Gaps : Export to ast from working tables***/
        -- change: gk 11/24 insert new N not Existing E
	   INSERT INTO ast.QmToProgCurGaps (ClientMemberKey,QmMsrId,QmCntCat,QmDate,RecStatus, RecStatusDate, CalcQmCntCat, SrcKey, SrcTableName, ClientKey)			
    	   SELECT c.ClientMemberKey, c.QmMsrId, c.QmCntCat, c.QMDate, 'N', c.QmDate, c.CalcQmCntCat,c.SrcKey, c.SrcTable, c.ClientKey
    	   FROM #tmpBatchCop c
    	   WHERE QmStatus = 'N' --and c.QmMsrId = 'ACE_HEDIS_ACO_CBP' and c.ClientMemberKey = '1EY5GW8HV93'
    	
        
        /*** Log Batch Events ***/
        INSERT INTO ast.QmToProgBatchLog(ClientMemberKey,QmMsrId,QmCntCat,QmDate,RecStatus)			
    	   SELECT c.ClientMemberKey, c.QmMsrId, QmCntCat, c.QMDate, QmStatus           
    	   FROM #tmpBatchCop c
        INSERT INTO ast.QmToProgBatchLog(ClientMemberKey,QmMsrId,QmCntCat,QmDate,RecStatus)			
    	   SELECT c.ClientMemberKey, c.QmMsrId, QmCntCat, c.QMDate, QmStatus
    	   FROM #tmpBatchNum c
        /* update processed flag */
        BEGIN
    		  update pd SET pd.ProcessedState = 1 --- set to YES processed
    		  FROM #TmpProcessDates pd
    		  where pd.QMDate = @CurrentBatch;
        END;
        /* Iterate CurrentBatch forward, and Loop */    
        SELECT @CurrentBatch = Min(pd.QmDate) FROM #tmpProcessDates pd where pd.ProcessedState = 0;
        
    END;  -- end while loop
    

-- SELECT cg.QmDate, cg.SendFlg,COUNT(*) 
-- FROM ast.QmToProgCurGaps cg 
-- group by cg.QmDate , cg.SendFlg
-- order by cg.QmDate

    /* After processing all COP, evaluate and set this months SendFlag */
    BEGIN--Step 3 Set SendFlag FOR NOT CLOSED Records
        UPDATE C set c.SendFlg = 0
        FROM ast.QmToProgCurGaps c
        WHERE c.SendFlg = 1;
    
        /* Update SendFlag */
        UPDATE CG SET CG.SendFlg = 1
        FROM(SELECT CurGaps.QmToProgCurCapKey, CurGaps.ClientMemberKey, CurGaps.QmMsrId, 
    			 CurGaps.CalcQmCntCat, CurGaps.RecStatus, CurGaps.QmDate, 
    			 ROW_NUMBER() OVER(PARTITION BY CurGaps.ClientMemberKey, CurGaps.QmMsrId, CurGaps.CalcQmCntCat ORDER BY CurGaps.QmDate ASC) AS aRowNumber, 
    			 CurGaps.QmCntCat, CurGaps.Addressed, CurGaps.RecStatusDate, CurGaps.SendFlg
    		  FROM ast.QmToProgCurGaps CurGaps
    		  WHERE CurGaps.RecStatus <> 'C'			  
    	   ) Curgaps
    	   JOIN ast.QmToProgCurGaps CG ON CurGaps.QmToProgCurCapKey = CG.QmToProgCurCapKey
        WHERE Curgaps.aRowNumber = 1;
    END;




/* FUTURE SET SEND FLAG FOR CLosed */
/* if it is closed, do we send term?

SELECT CurGaps.QmToProgCurCapKey, CurGaps.ClientMemberKey, CurGaps.QmMsrId, 
    CurGaps.CalcQmCntCat, CurGaps.RecStatus, CurGaps.QmDate, 
    ROW_NUMBER() OVER(PARTITION BY CurGaps.ClientMemberKey, CurGaps.QmMsrId, CurGaps.CalcQmCntCat ORDER BY CurGaps.QmDate ASC) AS aRowNumber, 
    CurGaps.QmCntCat, CurGaps.Addressed, CurGaps.RecStatusDate, CurGaps.SendFlg
    , CareOpToProg.CareOpsProgramKey InAdw
FROM ast.QmToProgCurGaps CurGaps
    JOIN (SELECT CO.ClientKey, co.ClientMemberKey, co.QmMsrId, co.CareOpsProgramKey
	   FROM adw.CareOpsToPrograms CO
	   WHERE CO.ClientKey = 16 
		  AND CO.LoadDate = (SELECT MAX(LoadDATE) FROM adw.CareOpsToPrograms)
		 -- AND CO.
		  ) CareOpToProg
	   ON CurGaps.ClientKey = CareOpToProg.ClientKey
		  and CurGaps.ClientMemberKey = CareOpToProg.ClientMemberKey
		  and CurGaps.QmMsrId = CareOpToProg.QmMsrId
WHERE CurGaps.RecStatus = 'C'		
    and clientMemberKey = cmk
ORDER BY ClientMemberKey, QmMsrId
*/


-->IN ADW program Table
--1. load all current and Term 
--    if Current and exists in table do not load
--    if Term and Exists do not load
--    if Term and Current exists in table add
--    if Current and Term exists add into future
-->ON EXPORT:
--1. get records send out all new and terms;
    



/* export to adw */    
--DECLARE @QmBatchDate DATE = '03/15/2021'  -- THIS IS THE Month you are running, it will also be the max loop on the rinse/repeat loop
    BEGIN 
        DECLARE @CopToProgSource VARCHAR(20)
        IF @Clientkey= 20
    		  SET @CopToProgSource = 'AET_MA' 
    	   ELSE  SET @CopToProgSource = 'ACE' 
        
      INSERT INTO adw.AhsExpCareOpsToPrograms (LoadDate, CareOpBatchDate, SrcKey, SrcTableName, ClientKey, ClientMemberKey
          , QmMsrId, QMDate, Addressed, CalcQmCntCat, QmCntCat
          , ActiveMembersIsActive
          , ActiveMembersCsPlanName
          , CareOpToProgActive, DESTINATION_PROGRAM_NAME
          , programStartDate, ProgramCreateDate, ProgramEndDate
          , ProgramStatusCode, ReasonDescription, ReferalType)    	   
        SELECT @QmBatchDate AS LoadDate, @QmBatchDate  AS CareOpBatchDate
    	   , cg.SrcKey, cg.SrcTableName, cg.ClientKey, CG.ClientMemberKey
        	   , CG.QmMsrId, Cg.QmDate, ISNULL(cg.Addressed,0) Addressed, Cg.CalcQmCntCat, cg.QmCntCat
        	   , CASE WHEN (mbr.clientMemberKey is null) then 0 else 1 END AS isActiveMember
        	   , mbr.SUBGRP_NAME as ActiveMbrCsPlanName										   -- fix		   		   
        	   , CoProg.ACTIVE AS IsCareOpToProgActive, CoProg.DESTINATION_PROGRAM_NAME
        	   , DATEFROMPARTS(Year(CG.QmDate), Month(CG.QMDate), 1) AS StartDate	
        	   , DATEFROMPARTS(Year(CG.QmDate), Month(CG.QMDate), 1)  AS CreateDate	
        	   , (SELECT Max(d.dDate) FROM ACDW_CLMS_SHCN_MSSP.adw.dimDate d WHERE d.dYear = YEAR(cg.qmDate)) AS StopDate
        	   , CASE WHEN (CG.RecStatus IN ('E','N')) THEN 'Active'
    			 WHEN (CG.RecStatus = 'C') THEN 'Closed'
    			 ELSE 'Status Name' END as ProgramStatusCode
        	   , 'Enrolled in a Program' as ReasonDescription
        	   , 'Ace CareOpps' AS ReferalType	  
            FROM ast.QmToProgCurGaps CG
        	   JOIN lst.list_Client Client ON cg.ClientKey = Client.ClientKey
        	   LEFT JOIN ACECAREDW.dbo.TmpAllMemberMonths mbr 
        		  ON cg.ClientMemberKey = mbr.ClientMemberKey
				AND cg.ClientKey = mbr.CLientKey
				AND cg.QmDate between  dateFromParts(Year(mbr.MemberMonth ), Month(mbr.MemberMonth ), 1) 
					   AND DATEADD(day, (-1* day(mbr.MemberMonth )), DATEADD(month, 1, mbr.MemberMonth))        		  
        	   JOIN lst.lstMapCareoppsPrograms CoProg 
        		  ON CG.QmMsrId = CoProg.ACE_PROG_ID
				and CG.ClientKey = @ClientKey        			 
        			 AND CG.QmDate BETWEEN CoProg.EffectiveDate and CoProg.ExpirationDate    		  
		  LEFT JOIN (SELECT cop.ClientKey, cop.ClientMemberKey, cop.QmMsrId, cop.CalcQmCntCat, cop.QMDate
    				    FROM adw.AhsExpCareOpsToPrograms cop ) adw 
			 ON cg.ClientMemberKey = adw.ClientMemberKey 
				AND cg.ClientKey = adw.clientKey 
				AND cg.QmMsrId = adw.QmMsrId 
				AND cg.QmDate  = adw.QMDate
            WHERE CG.SendFlg = 1
        		  AND ISNULL(mbr.ClientMemberKey, '') != ''			-- IS the Member Current to Qm Month
    		  AND adw.ClientMemberKey is null
    END;	

/* do some logging ya doofus */

END;

