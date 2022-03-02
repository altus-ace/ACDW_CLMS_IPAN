/****** Object:  StoredProcedure [adw].[DataAdj_RevCodeLength]    Script Date: 10/26/2018 3:29:44 PM ******/
CREATE PROCEDURE [adw].[Transfrom_Pdw_00_Master]
AS

    /* these jobs need to be folded into the ETL to the model. */

    EXEC	 adw.Transfrom_Pdw_01_DiagDot ;
    EXEC	 adw.Transfrom_Pdw_02_DrgCode;
    EXEC	 adw.Transfrom_Pdw_03_RevCodeLength;
	EXEC	 adw.Transform_Pdw_HdrsAggPaidFromPartDDetail;		
	
    --EXEC	  adw.DataAdj_SubscriberId;
    -- EXEC	  adw.Transform_Pdw_11_HdrsAggPaidFromPartBDetail;   provided Header level Fields used for now
	-- EXEC   adw.Transform_Pdw_HdrsAggProvSpecFromDetail   

    -- EXEC	  adw.Transform_PDW_20_SubscriberID;			-- Need not found currently, member PatientIds are not versioned enough to cause this issue


