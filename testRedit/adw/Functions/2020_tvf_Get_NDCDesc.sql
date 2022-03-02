





CREATE  FUNCTION [adw].[2020_tvf_Get_NDCDesc]
(
 @CodesetEffDate	VARCHAR(20)
)
RETURNS TABLE
AS RETURN
(
	SELECT DISTINCT a.productndc as ProductNDC
		,b.ndcpackagecode_clean as ClaimsNDC
		,adi.udf_ConvertToCamelCase(a.PROPRIETARYNAME) as Brand
		,adi.udf_ConvertToCamelCase(a.NONPROPRIETARYNAME) as NonBrand 
		FROM ACEMASTERDATa.[lst].[lstNdcDrugProduct] a
	INNER JOIN  lst.lstNdcDrugPackage b
	ON a.productndc = b.productndc
	WHERE @CodesetEffDate BETWEEN a.EffectiveDate and a.ExpirationDate
	AND @CodesetEffDate BETWEEN b.EffectiveDate and b.ExpirationDate


)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_NDCDesc] ('01/01/2019')
***/

