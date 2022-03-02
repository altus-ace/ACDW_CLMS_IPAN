
CREATE FUNCTION [adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions]
(@EffDate		DATE
)
RETURNS TABLE
AS
RETURN

( 
SELECT 
			DISTINCT ClientKey, ClientMemberKey AS SUBSCRIBER_ID,
			CASE WHEN Gender = 'M' THEN 'M' 
				 WHEN Gender = 'F' THEN 'F' 
				 WHEN Gender = '1' THEN 'M' 
				 WHEN Gender = '2' THEN 'F' 
				 WHEN Gender = '' THEN 'U' 
				 WHEN Gender = 'U' THEN 'U' ELSE Gender END AS Gender,
			DOB, 
			DOD,
			DATEDIFF(yy, DOB, CONVERT(DATE, @EffDate, 101)) AS AGE,
			CurrentAge,
			RwEffectiveDate,
			RwExpirationDate
FROM 
	(
	SELECT
			[ClientKey]
			,[Ace_ID]
			,[ClientMemberKey]
			,[Gender]
			,[DOB]
			,[DOD]
			,[CurrentAge]
			,[RwEffectiveDate]
			,[RwExpirationDate]
	  FROM 	[adw].[2020_tvf_Get_ActiveMembersFull]	(@EffDate)
	  --WHERE	DOD = '1900-01-01'
	) a

)
/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions] ('12/15/2020') 
***/

