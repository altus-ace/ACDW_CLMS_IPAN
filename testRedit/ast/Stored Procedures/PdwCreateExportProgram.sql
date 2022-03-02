/*
declare @d date = '10/13/2021'
exec ast.PdwCreateExportProgram @d, 21, 22
*/
CREATE PROCEDURE [ast].[PdwCreateExportProgram]
    (@LoadDate date 
	, @clientKey INT
	, @ProgramID INT
	, @ExpActive VARCHAR(20) = 'ACTIVE')
AS
BEGIN
    -- DECLARE @LoadDate DATE = '10/13/2021'--GETDATE(); -- what month process are we loading  Newly enrolled for
    -- DECLARE @ProgramID INT = 22; 
	-- DECLARE @clientkey int = 21
    DECLARE @ProgramName VARCHAR(100);
    DECLARE @EnrollDate DATE = DATEFROMPARTS(YEAR(@LoadDate), Month(@loadDate), 1);
    DEClare @EndDate DATE = DATEADD(day, 90, @EnrollDate);
    DECLARE @OrigMemberDateForNewMembers date = DATEADD(month, -1, @EnrollDate );
    
    DECLARE @OutputTbl TABLE (ID INT);	    
	DECLARE @MaxLoadDate Date;
    
    /* Log Stag Load */    
    DECLARE @AuditID INT 
    DECLARE @AuditStatus SmallInt= 1 -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 8   -- 8 dw load?        
    DECLARE @JobName VARCHAR(200);
	   SELECT @JobName = OBJECT_NAME(@@PROCID); 
    DECLARE @ActionStartTime DATETIME2 = getdate();
    DECLARE @InputSourceName VARCHAR(200) 
	   SELECT @InputSourceName = DB_NAME() + 'SOME DESTINTATION'	    
    DECLARE @DestinationName VARCHAR(200) = 'No Destination Name Provided'	
	   SELECT @DestinationName = DB_NAME() + '.adw.ExportAhsPrograms';    
    DECLARE @ErrorName VARCHAR(200) = 'No Error Name Provided'	
    	
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
    
    /* this should be a validation: if there is not a record match fail out*/
    SELECT @ProgramName =  cp.ProgramName
    FROM lst.lstClinicalPrograms cp
    where cp.lstAhsProgramsKey = @ProgramID;
    
	SELECT @MaxLoadDate = Max(m.LoadDate) 
	FROM adw.FctMembership m ;	

	/* get new members */
	IF OBJECT_ID(N'tempdb..#tmpNewMembers ') IS NOT NULL
		DROP TABLE #tmpNewMembers;	
	CREATE TABLE #tmpNewMembers (clientkey INT, ClientMemberKey VARCHAR(50), PRIMARY KEY (ClientKey, ClientMemberKey))
	
	INSERT INTO #tmpNewMembers(clientkey, ClientMemberKey)
	SELECT CurMbrs.ClientKey, CurMbrs.ClientMemberKey 	
	FROM adw.FctMembership CurMbrs 	
	WHERE CurMbrs.LoadDate = @MaxLoadDate 
		and CurMbrs.ClientKey = @clientKey	
	EXCEPT
	 SELECT CurMbrs.ClientKey, CurMbrs.ClientMemberKey 	
	 FROM adw.FctMembership CurMbrs 	
	 WHERE CurMbrs.LoadDate < @MaxLoadDate 
		and CurMbrs.ClientKey = @ClientKey
	
	    
    /* exception, etc */
    --SELECT  @ProgramID, @ProgramName, @LoadDate, @OrigMemberDateForNewMembers, @EndDate, @EnrollDate

    /* insert into */
    INSERT INTO adw.ExportAhsPrograms (LoadDate, ClientKey,ClientMemberKey, ProgramID, ExpLobName	  
		  ,ExpProgram_Name, ExpEnrollDate, ExpCreateDate, ExpMemberID
		  , ExpEnrollEndDate, ExpProgramstatus, ExpReasonDescription
		  , ExpReferalType    
		  )
    OUTPUT inserted.ExportAhsProgramsKey INTO @OutputTbl(ID)     
    SELECT @LoadDate LoadDate, am.ClientKey , am.MEMBER_ID , @ProgramID AS ProgramID, client.CS_Export_LobName
	   	, @ProgramName as ExpProgram_Name, @EnrollDate as ExpEnrollDate, @EnrollDate as ExpCreateDate, am.MEMBER_ID AS ExpMemberID
		, @EndDate as ExpEnrollEndDate, @ExpActive as ExpProgramstatus, 'Enrolled in a Program' as ExpReasonDescription
		, 'External' as ExpReferalType			
	FROM ACECAREDW.dbo.vw_activeMembers am
		JOIN #tmpNewMembers NewMbr ON am.clientKey = NewMbr.clientkey and am.CLIENT_SUBSCRIBER_ID = NewMbr.ClientMemberKey
		JOIN lst.List_Client Client ON am.clientKey = Client.ClientKey
		LEFT JOIN ACECAREDW.adw.ExportAhsPrograms ep 
			ON am.Member_ID = ep.clientmemberKey 
				and am.clientKey = ep.ClientKey
				and @ProgramId = ep.ProgramID
				and ep.ExpEnrollDate >= DateFROMParts(Year(@EnrollDate), 1,1)
		LEFT JOIN (SELECT pe.ProgramName, pe.ClientMemberKey, pe.StartDate, pe.EndDate, client.ClientKey
					FROM ACECAREDW.dbo.tmp_Ahs_ProgramEnrollments pe
						JOIN (SELECT max(pe.LoadDate) MaxLoadDate
								FROM AceCareDW.dbo.tmp_Ahs_ProgramEnrollments pe) mx 
							ON pe.LoadDate = mx.Maxloaddate
						JOIN lst.List_Client client 
							ON pe.LOB = client.CS_Export_LobName
					WHERE pe.ProgramName = @ProgramName 
						AND pe.StartDate >= DATEFROMPARTS(Year(Getdate()), 1,1)
					) AhsPe ON am.clientKey = AhsPe.ClientKey
						and am.MEMBER_ID = AhsPe.ClientMemberKey
						and @ProgramName = AhsPe.ProgramName
		WHERE am.clientKey = @ClientKey
			and ep.ExportAhsProgramsKey is null
			and AhsPe.ClientMemberKey is null;

     /* close load Staging Log record */    
    DECLARE @ActionStopTime DATETIME = getdate()
    DECLARE @SourceCount int; --= 25
	   SELECT @SourceCount = COUNT(ID) FROM @OutputTbl;
    DECLARE @DestinationCount int; -- = 23
	   SELECT @SourceCount = COUNT(ID) FROM @OutputTbl;
    DECLARE @ErrorCount int = 0
    DECLARE @JobStatus tinyInt = 2

    EXEC AceMetaData.amd.sp_AceEtlAudit_Close 
        @AuditId = @AuditID
        , @ActionStopTime = @ActionStopTime
        , @SourceCount = @SourceCount		  
        , @DestinationCount = @DestinationCount
        , @ErrorCount = @ErrorCount
        , @JobStatus = @JobStatus
	   ;
END 


