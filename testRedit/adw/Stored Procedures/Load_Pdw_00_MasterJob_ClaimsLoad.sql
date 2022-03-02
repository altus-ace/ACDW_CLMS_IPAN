
CREATE PROCEDURE [adw].[Load_Pdw_00_MasterJob_ClaimsLoad]    
    ( @LatestDataDate DATE = '12/31/2099')
AS 
BEGIN   
    -- TO DO: Add calls to the log sp. all the code and tables exist. add before run again.
    
    -- 
    -- 1.truncate normalized model tables
    -- 2. updated stats adi.
    -- 3.do setup
    -- 4.execute each table move
    -- 5.validate
    --declare @LatestDataDate date = '01/01/2021'
    
        
    -- 1. TRUNCATE Normalized Tables: DO NOT MOVE TO PROC, 
	   -- unless you take the backup with it. 
	   -- Best practice is do not delete with out a backup.     This should be hard to run.
    BEGIN
	   TRUNCATE TABLE adw.Claims_Details;
	   TRUNCATE TABLE adw.Claims_Conditions;
	   TRUNCATE TABLE adw.Claims_Diags;
	   TRUNCATE TABLE adw.Claims_Procs;
	   TRUNCATE TABLE adw.Claims_Member;
	   TRUNCATE TABLE adw.Claims_Headers; 
    END;
	
    -- 2. update stats adi
	/* not currently needed 
    BEGIN
	   EXEC sP_updateStats;
    END;
	*/
    --3. Load the staging tables- Select which adi rows will be inserted
	 --Process set of SP when filtering by filedate as cummulative date is needed to be processed
    -- EXEC adw.Load_Pdw_00_LoadManagementTables @LatestDataDate;
	  BEGIN
		--declare @LatestDataDate date = '12/31/2099'        
	    -- 1. Get unique list of the claims Header     :: all claims headers Inst, Prof,Pharm
	    EXEC adw.Load_Pdw_01_ClaimHeader_01_Deduplicate @LatestDataDate;
	    -- 2. Create a SKey for the Claims Headers, this is used to join all of the other entities.    
	    EXEC adw.Load_Pdw_02_ClaimsSuperKey  @LatestDataDate;
	    -- 3. Get latest Header for a specific claim.    
	    EXEC adw.Load_Pdw_03_LatestEffectiveClmsHeader  @LatestDataDate;
		-- 7. EXEC adw.Load_Pdw_07_DeDupCclf5 @latestDataDate;
		EXEC adw.Load_Pdw_07_DeDupCclf5 @latestDataDate;
	    -- 4. de dup claims details		
	    EXEC adw.Load_Pdw_04_InstClaimDetails @LatestDataDate;
	    -- 5. de dup procedures 
	    EXEC adw.Load_Pdw_05_DeDupPartAProcs  @LatestDataDate;
	    -- de dup diags        
	    EXEC adw.Load_Pdw_06_DeDupPartADiags  @LatestDataDate;

		
    END;

    -- 4. Execute TABLE moves.
    BEGIN    
	--SELECT 'No Mapping currently, remove this querry when mapping is built';
	   -- Inst
	   EXEC adw.Load_Pdw_11_ClmsHeadersPartA;
	   EXEC adw.Load_Pdw_12_ClmsDetailsPartA;
	   EXEC adw.Load_Pdw_13_ClmsProcsCclf3;
	   EXEC adw.Load_Pdw_14_ClmsDiagsCclf4;
	   --declare @LatestDataDate date = '12/31/2099'    	   
	   EXEC adw.Load_Pdw_15_ClmsMemsCCLF8 @LatestDataDate;--Check this for file date
--	   -- prof
	   EXEC adw.Load_Pdw_21_ClmsHeadersPartBPhys; 
	   EXEC adw.Load_Pdw_22_ClmsDetailsPartBPhys;
	   EXEC adw.Load_Pdw_24_ClmsDiagsPartBPhys;
--	   -- rx
	   EXEC adw.Load_Pdw_31_ClmsHeadersPartdPharma;
	   EXEC adw.Load_Pdw_32_ClmsDetailsPartDPharma;
    END;

    -- 6. Data normalization
    EXEC adw.Transfrom_Pdw_00_Master;

    -- 7. UPdate statistics following dim load
    EXEC sP_updateStats;
	
	EXEC [ast].[ValidateClaimsTables] 
	EXEC adw.ValidateClaimsTables
	

	SELECT c.SrcAdiTableName, COUNT(*)  FROM adw.Claims_Headers c group by c.SrcAdiTableName
	SELECT c.SrcAdiTableName, COUNT(*)  FROM adw.Claims_Details c group by c.SrcAdiTableName
	SELECT c.SrcAdiTableName, COUNT(*)  FROM adw.Claims_Diags c group by c.SrcAdiTableName
	SELECT c.SrcAdiTableName, COUNT(*)  FROM adw.Claims_Procs c group by c.SrcAdiTableName
	SELECT c.SrcAdiTableName, COUNT(*)  FROM adw.Claims_Member c group by c.SrcAdiTableName
	SELECT c.SrcAdiTableName, COUNT(*)  FROM adw.Claims_Conditions c group by c.SrcAdiTableName


END;	