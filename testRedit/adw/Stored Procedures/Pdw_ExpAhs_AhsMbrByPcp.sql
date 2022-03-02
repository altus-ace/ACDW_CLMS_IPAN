
--exec [adw].[Pdw_ExpAhs_AhsMbrByPcp] 1
CREATE PROCEDURE [adw].[Pdw_ExpAhs_AhsMbrByPcp](
    @ClientKey INT
    , @Debug TINYINT = 0)
AS 

	--DECLARE @OutputTbl TABLE (ID INT); 
	DECLARE @LoadDate Date = CONVERT(date, GETDATE()) ;   
	DECLARE @AuditID INT 
    DECLARE @AuditStatus SmallInt= 1 -- 1 in process , 2 Completed
    DECLARE @JobType SmallInt     ;
    DECLARE @JobStatus tinyInt = 1	;
    DECLARE @JobName VARCHAR(200) ;
    DECLARE @ActionStartTime DATETIME = getdate();
    DECLARE @ActionStopTime DATETIME = getdate()
    DECLARE @InputSourceName VARCHAR(200) = 'No Name given';	   
    DECLARE @DestinationName VARCHAR(200) = 'No Name given';	   
    DECLARE @ErrorName VARCHAR(200)	  = 'No Name given';	   
    DECLARE @SourceCount int = 0;         
    DECLARE @DestinationCount int = 0;    
    DECLARE @ErrorCount int = 0;    
        
    SET @JobType				 = 9	   -- 9 ast load    
    SET @JobName				 = 'Pdw_ExpAhs_AhsMbrByPcp'
	SELECT @InputSourceName		 = DB_NAME() +  ' dbo.vw_Exp_AH_MemberPCP_dev'    
	SELECT @DestinationName		 = DB_NAME() + '.[adw].[AhsExpMemberByPcp]';    
	SELECT @ErrorName			 = DB_NAME() + '.[adw].[AhsExpMemberByPcp]';    
    
    EXEC AceMetaData.amd.sp_AceEtlAudit_Open   
	        
	     @AuditID = @AuditID OUTPUT          
	   , @AuditStatus = @AuditStatus          
	   , @JobType = @JobType          
	   , @ClientKey = @ClientKey          
	   , @JobName = @JobName          
	   , @ActionStartTime = @ActionStartTime          
	   , @InputSourceName = @InputSourceName          
	   , @DestinationName = @DestinationName          
	   , @ErrorName = @ErrorName          ;    


	    BEGIN TRAN      
	   INSERT INTO  [adw].[AhsExpMemberByPcp]
	   (
		 [ClientKey]
		,[ClientMemberKey]
		,[fctMembershipKey]
		,[Exp_MEMBER_ID]						
		,[Exp_PcpNpi]							
		,[Exp_ProviderRelationshipType]		
		,[Exp_LOB]							
		,[Exp_PcpEffectiveDate]				
		,[Exp_PcpTermDate]					
		,[Exp_MemberPcpAdditionalInfo_1]		
		,[LoadDate]
	   )
	   SELECT
	    mbr.ClientKey,
		mbr.ClientMemberKey AS MEMBER_ID, 
		mbr.FctMembershipSkey,
		mbr.ClientMemberKey ,
		mbr.NPI AS MEMBER_PCP , 
		'PCP' AS PROVIDER_RELATIONSHIP_TYPE, 
		lc.CS_Export_LobName AS LOB, 
		EffectiveDate AS PCP_EFFECTIVE_DATE,
		'2099-12-31' AS PCP_TERM_DATE, 
		 'A'  AS MEMBER_PCP_ADDITIONAL_INFORMATION_1
	   , @LoadDate LoadDate		
     FROM [adw].FctMembership mbr
         INNER JOIN lst.[List_Client] lc ON lc.ClientKey = mbr.ClientKey
	    INNER JOIN (SELECT MAX(mbr.RwEffectiveDate) mbrRwEff, Max(mbr.RwExpirationDate) MbrRwExp from Adw.FctMembership mbr) LatestRecords
		  ON mbr.RwEffectiveDate = LatestRecords.mbrRwEff
			 and mbr.RwExpirationDate = LatestRecords.MbrRwExp
    WHERE mbr.Active = 1	 
--	   and mbr.ProviderPOD <> '' mssp filter 
	   and mbr.SubgrpName <> 'COMM_Market is unknown' -- bcbs filter (these members do not have a valid plan)
	   COMMIT TRAN; 
	   
    
    EXEC AceMetaData.amd.sp_AceEtlAudit_Close           
	   @AuditId = @AuditID          
	   , @ActionStopTime = @ActionStopTime          
	   , @SourceCount = @SourceCount              
	   , @DestinationCount = @DestinationCount          
	   , @ErrorCount = @ErrorCount          
	   , @JobStatus = @JobStatus      
	   ;         
     
        
	   BEGIN TRAN      
	   
	   UPDATE adiData      
		  SET adiData.Exported = 1           	   
	   FROM [adw].[AhsExpMemberByPcp] adiData         
	   WHERE adidata.Exported = 0
	   COMMIT TRAN  ;    
       
   

 /*           
	
begin
    if  @ClientKey = 1
    begin	  
    -- do uhc	 
	   SELECT 1
    end
    else
    begin -- declare @clientkey int = 12
	   SELECT 
		  CONVERT(NVARCHAR(255), RTRIM(mp.[MEMBER_ID])) AS MEMBER_ID,
		  CONVERT(NVARCHAR(255), RTRIM(mp.[MEMBER_PCP])) AS MEMBER_PCP , 
		  CONVERT(NVARCHAR(255), RTRIM(mp.[PROVIDER_RELATIONSHIP_TYPE])) AS PROVIDER_RELATIONSHIP_TYPE, 
		  CONVERT(NVARCHAR(255), RTRIM(mp.[LOB])) AS LOB, 
		  CONVERT(NVARCHAR(255), RTRIM(mp.[PCP_EFFECTIVE_DATE])) AS PCP_EFFECTIVE_DATE,
		  CONVERT(NVARCHAR(255), RTRIM(mp.[PCP_TERM_DATE])) AS PCP_TERM_DATE, 
		  CONVERT(NVARCHAR(255), RTRIM(mp.[MEMBER_PCP_ADDITIONAL_INFORMATION_1])) AS MEMBER_PCP_ADDITIONAL_INFORMATION_1
		 INTO #MbrPcp
	   FROM dbo.vw_Exp_AH_MemberPCP_dev mp 
	   WHERE mp.clientkey = @CLientKey	  
	   ;
    end;
    
    
    SELECT 
	tmbrPcp.MEMBER_ID AS CLientKey,
	@ClientKey, 
	tmbrPcp.MEMBER_ID,
	tmbrPcp.MEMBER_ID, 
	tmbrPcp.MEMBER_PCP, 
	tmbrPcp.PROVIDER_RELATIONSHIP_TYPE, 
	tmbrPcp.LOB.
	tmbrPcp.PCP_EFFECTIVE_DATE, 
	tmbrPcp.PCP_TERM_DATE, 
	tmbrPcp.MEMBER_PCP_ADDITIONAL_INFORMATION_1
	@LoadDate LoadDate
    FROM #MbrPcp tmbrPcp
	   LEFT JOIN adw.AhsExpMemberByPcp Adw  
		  ON tmbrPcp.MEMBER_ID= adw.ClientMemberKey
			 and tmbrPcp.MEMBER_PCP = adw.Exp_PcpNpi
			 and @LoadDate  = adw.LoadDate
    WHERE adw.AhsExpMemberByPcpKey is null
    	
	
end */
