
CREATE FUNCTION [adw].[tvf_AllClient_ProviderRoster](
       @clientkey int, @AsOfDate date, @active tinyint = 1
	)
RETURNS TABLE
    
AS RETURN    

   SELECT Src.NPI, Src.LastName, Src.FirstName, 
       Src.AttribTIN, Src.AttribTINName, Src.AccountType, 
       Src.Chapter, Src.PrimaryCounty, Src.ProviderType, Src.ProviderSpecialty, Src.ProviderSubSpecialty, Src.ClientKey, Src.MbrHealthPlan, Src.ClientProviderID,
	  Src.NetworkContact, 
       Src.TINHealthPlan, Src.TinLOB, Src.TinHPEffectiveDate, Src.TinHPExpirationDate, 
       Src.NpiHealthPlan, Src.NpiLOB, Src.NpiHpEffectiveDate, Src.NpiHpExpirationDate, 
       Src.LastUpdatedDate, src.IsActive,
       Src.RowEffectiveDate, Src.RowExpirationDate,Src.ARN, src.fctProviderRosterSkey
    FROM (SELECT 
           pr.NPI, 
           pr.LastName, 
           FirstName, 
           TIN AS AttribTIN, 
           GroupName AS AttribTINName,
           CASE WHEN AccountType IN('SHCN_SMG', 'SHCN_AFF') THEN AccountType
               ELSE CONCAT('ACE-', AccountType) END AS AccountType,
           CASE WHEN pr.PrvdrHealthPlan = 'Aetna'AND pr.PrvdrLOB LIKE '%Commercial%'	   THEN 'AETCOM'
			 WHEN pr.PrvdrHealthPlan = 'Aetna'AND pr.PrvdrLOB LIKE '%Advantage%'	   THEN 'AET'
			 WHEN pr.PrvdrHealthPlan = 'Amerigroup'							   THEN 'AMG'
			 WHEN pr.PrvdrHealthPlan = 'Cigna'AND pr.PrvdrLOB LIKE '%Commercial%'	   THEN 'CIGNA_COM'
			 WHEN pr.PrvdrHealthPlan = 'Cigna'AND pr.PrvdrLOB LIKE '%Advantage%'	   THEN 'CIGNA_MA'
			 WHEN pr.PrvdrHealthPlan = 'SHCN_MSSP'							   THEN 'SHCN_MSSP'
			 WHEN pr.PrvdrHealthPlan = 'SHCN_BCBS'							   THEN 'SHCN_BCBS'
			 WHEN pr.PrvdrHealthPlan = 'UHC'								   THEN 'UHC'
			 WHEN pr.PrvdrHealthPlan = 'Wellcare'							   THEN 'WLC'
			 WHEN pr.PrvdrHealthPlan = 'Oscar'								   THEN 'Oscar'
			 WHEN pr.PrvdrHealthPlan = 'Devoted'							   THEN 'DHTX'
 			 WHEN pr.PrvdrHealthPlan = 'IPANS'							   THEN 'IPANS'
			 ELSE 'Other'			    END AS MbrHealthPlan, 
           Pr.Chapter AS Chapter, 
           Pr.PrimaryCounty , 
           Pr.ClientKey AS ClientKey, 		 
		 Pr.ProviderType	, 
		 Pr.PrimarySpeciality  AS ProviderSpecialty, 
		 Pr.Sub_Speciality	  AS ProviderSubSpecialty,
		 Pr.NetworkContact, 
		 pr.TinClientKey,
           Pr.TinHealthPlan AS TINHealthPlan, 			  
           Pr.TinLOB, 
           pr.RowEffectiveDate AS RowEffectiveDate, 
           pr.RowExpirationDate AS RowExpirationDate, 
           pr.TinHpEffDate AS TinHPEffectiveDate, 
           pr.TinHpExpDate AS TinHPExpirationDate, 
		 pr.PrvdrClientKey AS NpiClientKey, 
           pr.PrvdrHealthPlan AS NpiHealthPlan, 
           pr.PrvdrLOB		  AS NpiLOB, 
           pr.PrvdrHpEffDate AS NpiHpEffectiveDate, 
           pr.PrvdrHpExpDate AS NpiHpExpirationDate, 
		 pr.ClientProviderID,		 
           pr.LastUpdatedDate, 
           ROW_NUMBER() OVER(PARTITION BY NPI, TIN, PrvdrHealthplan, PrvdrLOB ORDER BY PrvdrHpEffDate asc, PrvdrHpExpDate DESC) AS ARN    
    		, pr.fctProviderRosterSkey		
		, pr.IsActive						 
    FROM adw.fctProviderRoster_DevPR PR
    WHERE((@ClientKey = 0) or pr.ClientKey = @ClientKey)			
	   AND @AsOfDate BETWEEN pr.RowEffectiveDate AND pr.RowExpirationDate		    
	   AND ((@active = 0) or ((@active = 1) and (pr.IsActive =  1))) 
    ) Src
    WHERE src.ARN = 1;


