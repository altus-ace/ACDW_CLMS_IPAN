
CREATE PROCEDURE [adw].[Load_MasterJob_CareOpps] 
					(@QMDate DATE,@ClientKey INT,@DataDate DATE)

AS

	/*Validate CareOpps*/

 BEGIN
	EXEC [adi].[ValidateCareopps]
 END

 BEGIN
	-- Get candidate rows with biz rules applied to process into staging
	/*Old version*/
	--EXECUTE [ast].[plsCareopps]@QMDate, @ClientKey, @DataDate

	/**New Version - Process for all Measures*/
	EXECUTE [ast].[plsCareopps_AllMeasures] @QMDate, @ClientKey, @DataDate
	

 END

  BEGIN 

	/*Process GapAdherence Records*/
	EXECUTE [ast].[plsCareopps_GapAdherence] @QMDate, @ClientKey, @DataDate

 END

 BEGIN
		/*Process AWV*/
	EXEC [ast].[plsCareopps_Amerigroup_MA_WellnessVisits] @QMDate, @ClientKey, @DataDate
 END

 BEGIN
	/*Validate Records for processing*/
	EXECUTE [ast].[pstCopValidateStaging]@QMDate, @ClientKey

 END

 BEGIN 

	/*Process records into Data Warehouse*/
	EXECUTE [ast].[pdw_CareOppsStagingToAdw] @QMDate,@ClientKey

 END

 /*Process Failed CareOpps records*/
 BEGIN
	EXEC [ast].[pdw_Load_FailedCareOpps]@QMDate,@ClientKey
 END

 
/* Retired
 BEGIN
		--Get appropriate records from adi for processing
	EXECUTE adi.SplitRowsForProcessingBetweenProductLinesMAandMCD @DataDate

 END*/

 
