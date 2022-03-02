
/* Process pdw */
CREATE PROCEDURE [adw].[Load_Pdw_00_LoadManagementTables]
    ( @LatestDataDate DATE = '12/31/2099')
AS  
    BEGIN
    --declare @LatestDataDate date = '01/01/2021'        
    -- 1. Get unique list of the claims Header     :: all claims headers Inst, Prof,Pharm
    EXEC adw.Load_Pdw_01_ClaimHeader_01_Deduplicate @LatestDataDate;
    -- 2. Create a SKey for the Claims Headers, this is used to join all of the other entities.    
    EXEC adw.Load_Pdw_02_ClaimsSuperKey  @LatestDataDate;
    -- 3. Get latest Header for a specific claim.    
    EXEC adw.Load_Pdw_03_LatestEffectiveClmsHeader  @LatestDataDate;
    -- 4. de dup claims details
    EXEC adw.Load_Pdw_04_InstClaimDetails @LatestDataDate;
    -- 5. de dup procedures 
    EXEC adw.Load_Pdw_05_DeDupPartAProcs  @LatestDataDate;
    -- de dup diags        
    EXEC adw.Load_Pdw_06_DeDupPartADiags  @LatestDataDate;

    END;

