


CREATE  VIEW [dbo].[vw_Exp_AH_Eligibility]
AS

    SELECT 
	   /* this columns are for export */
	  ahs.Exp_MEMBER_ID					   as MEMBER_ID					 , 
       ahs.Exp_LOB						   as LOB						 , 
       ahs.[Exp_BENEFIT PLAN]				   as [BENEFIT PLAN]				 , 
       ahs.[Exp_INTERNAL/EXTERNAL INDICATOR]	   as [INTERNAL/EXTERNAL INDICATOR]	 , 
       ahs.Exp_START_DATE				   as START_DATE				 , 
       ahs.Exp_END_DATE					   as END_DATE					 , 
       /* these columns are businesskeys and meta data */
	   ahs.AhsExpEligibilityKey AS SKey, 
       ahs.Exported, 
       ahs.ExportedDate, 
       ahs.ClientMemberKey, 
       ahs.ClientKey, 
       ahs.fctMembershipKey, 
       ahs.LoadDate
    FROM adw.AhsExpEligiblity ahs
    where ahs.exported	= 0;
