

CREATE  FUNCTION [adw].[2020_tvf_Get_DataFromNPPES]
	(
	@EffCodeDate DATE
	)
RETURNS TABLE
AS RETURN
(
		SELECT DISTINCT 
			 NPI
			,CASE LEN([LBN]) WHEN 0											   
			THEN [LBN_Name]		   
			ELSE LEFT(RTRIM([LBN]),100)										   
			END AS LegalBusinessName
		FROM [AceMasterData].[adi].[LIST_NPPES_NPI] 
		WHERE [NPI] IN (SELECT DISTINCT VENDOR_ID FROM adw.Claims_Headers UNION SELECT DISTINCT SVC_PROV_NPI FROM adw.Claims_Headers) 
		AND DataDate = (SELECT MAX(DataDate) FROM [AceMasterData].[adi].[LIST_NPPES_NPI])

)

/***
SELECT * FROM [adw].[2020_tvf_Get_DataFromNPPES] ('05-01-2020')

***/
