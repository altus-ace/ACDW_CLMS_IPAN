


CREATE PROCEDURE [adw].[Load_MasterJob_Membership](
				 @LoadDate DATE
				 ,@ClientID INT
				 ,@DataDate DATE
				 ,@DemoCrswlkLoadDate DATE
				 ,@EffectiveDate DATE
				 ,@LoadType CHAR(1)
				 ,@RwExpirationDate DATE
				 )
AS


BEGIN
		EXEC [adi].[ValidateMemberShip]
END
BEGIN
	/**Process into staging*/
	EXECUTE [ast].[stg_01_pls_ProcessMbrMemberLoadFrmStaging] @LoadDate, @EffectiveDate 
	
END

BEGIN
	/*Perform Transformation in staging*/
	EXECUTE [ast].[stg_02_Pts_ProcessMbrMemberTransformationInStaging] @EffectiveDate,@DataDate

END

/*
BEGIN
	/*NOT REQUIRED FOR IPAN: Process Members MRN*/
	/*	EXECUTE [ast].[stg_03_Pts_RunMpiForMbrMember]*/

END
*/
BEGIN
		--Process Load DIMs
		EXECUTE	[adw].[PdwMbr_01_LoadHistory]@DaTaDate,@LoadType,@ClientID;
		EXECUTE	[adw].[PdwMbr_02_LoadMember]@DaTaDate,@LoadType,@ClientID,@EffectiveDate;
		EXECUTE	[adw].[PdwMbr_03_LoadDemo]@DaTaDate,@ClientID;
		EXECUTE	[adw].[PdwMbr_04_LoadPhone]@DaTaDate,@ClientID;
		EXECUTE	[adw].[PdwMbr_05_LoadAddress]@DaTaDate,@ClientID;
		EXECUTE	[adw].[PdwMbr_06_LoadPcp]@DaTaDate,@ClientID;
		EXECUTE	[adw].[PdwMbr_08_LoadPlan]@DaTaDate,@ClientID;
		EXECUTE	[adw].[PdwMbr_09_LoadCSPlan]@DaTaDate,@ClientID;
		EXECUTE	[adw].[PdwMbr_11_LoadEmail] @DaTaDate,@ClientID;
	
	END

	/*Process Vals*/
	BEGIN
		EXEC [ast].[stg_04_Validate_stg_Membership] @DataDate, @EffectiveDate
	END
	BEGIN
		
		 /*Process from Dims into DW*/
		EXECUTE [adw].[p_Pdw_Master_ProcessFctMembership]  
									@EffectiveDate
									,@ClientID
									, @DataDate 
									,@LoadDate
									,@RwExpirationDate 
	
	
	END

	BEGIN
	/*Updating staging*/
		EXECUTE [ast].[stg_05_PupdAllLineageRowsInAdiAndStg]@EffectiveDate
	END




