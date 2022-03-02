
CREATE PROCEDURE [adw].[Load_Pdw_15_ClmsMemsCCLF8]
    (@MaxDataDate DATE = '12/31/2099')
AS -- insert Claims.Members
    DECLARE @DataDate Date = @maxDataDate;
	/* prepare logging */
    DECLARE @AuditId INT;    
    DECLARE @JobStatus tinyInt = 1    -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt = 8	  -- Adw load
    DECLARE @ClientKey INT	 = 16; -- mssp
    DECLARE @JobName VARCHAR(100) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
    DECLARE @ActionStart DATETIME2 = GETDATE();
    DECLARE @SrcName VARCHAR(100) = 'adi.CCLF8'
    DECLARE @DestName VARCHAR(100) = 'adw.Claims_Member'
    DECLARE @ErrorName VARCHAR(100) = 'NA';
    DECLARE @InpCnt INT = -1;
    DECLARE @OutCnt INT = -1;
    DECLARE @ErrCnt INT = -1;
	
    SELECT @InpCnt = COUNT(*)     
   FROM adw.vw_Dashboard_Membership mbr
    JOIN (SELECT m.ClientKey, m.ClientMemberKey, Max(m.RwEffectiveDate) rwEffectiveDate
  FROM adw.vw_Dashboard_Membership m
  GROUP BY m.clientKey, m.ClientMemberKey) LatestMember
  ON mbr.ClientKey = LatestMember.ClientKey
AND mbr.ClientMemberKey = LatestMember.ClientMemberKey
AND mbr.RwEffectiveDate = LatestMember.rwEffectiveDate	;

    
     

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
	declare @LoadDate date = getdate();
    INSERT INTO adw.Claims_Member
           (SUBSCRIBER_ID
		   , IsActiveMember
           ,DOB
           ,MEMB_LAST_NAME
           ,MEMB_MIDDLE_INITIAL
           ,MEMB_FIRST_NAME        
		   ,MEDICAID_NO
		   ,MEDICARE_NO
           ,Gender
           ,MEMB_ZIP
		   ,COMPANY_CODE
		   ,LINE_OF_BUSINESS_DESC
		   ,SrcAdiTableName
		   ,SrcAdiKey
		   ,LoadDate
		   )
	OUTPUT inserted.SUBSCRIBER_ID INTO #OutputTbl(ID)
    SELECT 
	   m.BENE_MBI_ID			as SUBSCRIBER_ID		    
	   , 1						as ActiveMember
	   ,m.BENE_DOB			    as DOB				    
	   ,m.BENE_LAST_NAME		as MEMB_LAST_NAME		    
	   ,m.BENE_MIDL_NAME		as MEMB_MIDDLE_INITIAL	    
	   ,m.BENE_1ST_NAME		    as MEMB_FIRST_NAME	    
	   ,''						as  MEDICAID_NO
		, ''					as MEDICARE_NO
	   ,m.BENE_SEX_CD		    as GENDER			    
	   ,m.BENE_ZIP_CD		    as MEMB_ZIP			    
	   , ''						as companyCOde
	   , ''						as lineOfBusDesc
	   , @SrcName				AS srcAdiTableName
	   , m.adiCCLF8_SKey		AS SrcAdiKey
	   , @LoadDate				AS LoadDate
    FROM adi.CCLF8 m    
        JOIN (SELECT c.BENE_MBI_ID, c.adiCCLF8_SKey
				    , row_Number() OVER (PARTITION BY c.BENE_MBI_ID ORDER BY c.FileDate DESC) arn
				    FROM adi.CCLF8 c 
				    ) src
		ON m.adiCCLF8_SKey = src.adiCCLF8_SKey
	WHERE src.arn = 1
	

		   

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
