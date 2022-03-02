



CREATE VIEW [ast].[vw_EMR_MemberCrosswalk]

AS

WITH CTE_mbrCrsWlk
AS
	(
			SELECT DISTINCT	(SELECT CONVERT(DATE,DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))) AS  EffectiveDate
							, (SELECT ClientKey FROM lst.List_Client)   AS ClientKey
							, '''' + mbr.ClientMemberKey + ''''					    AS [Source]
							, mbr.ClientMemberKey						AS [Target]
			FROM			ACECAREDW.dbo.TmpAllMemberMonths mbr
			WHERE			CLientKey = (SELECT ClientKey FROM lst.List_Client)
					
	
	)
	
	SELECT	EffectiveDate
			,ClientKey
			,[Source]
			,[Target]
	FROM	CTE_mbrCrsWlk
			
