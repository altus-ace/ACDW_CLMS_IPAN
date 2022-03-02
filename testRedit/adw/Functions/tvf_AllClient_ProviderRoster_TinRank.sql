
CREATE FUNCTION [adw].[tvf_AllClient_ProviderRoster_TinRank](
       @clientkey int, @AsOfDate date, @active tinyint = 1
	)
RETURNS TABLE
    
AS RETURN    
    SELECT * 
    FROM (SELECT pr.* , ROW_NUMBER() OVER (PARTITION BY pr.NPI, pr.ClientKey ORDER BY pr.AttribTIN ) AS TinRank
		  FROM [adw].[tvf_AllClient_ProviderRoster](@Clientkey, @AsOfDate, @active) pr
	   ) src
    where src.TinRank = 1
    


