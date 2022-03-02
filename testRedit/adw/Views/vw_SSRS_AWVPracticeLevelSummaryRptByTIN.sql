

CREATE VIEW		[adw].[vw_SSRS_AWVPracticeLevelSummaryRptByTIN]

AS



SELECT          PracticeTIN,PracticeName,NPI,ProviderName,Chapter
                , MemberCount,MemberSeen,MemberswithAWV,KPIEffYear, CONVERT(VARCHAR(20), KPIEffMonth) AS KPIEffMonth
                , CONVERT(DECIMAL(10,4),(CASE WHEN MemberCount = 0 THEN 0 ELSE CAST(MemberSeen as decimal(10,4))/MemberCount END)) AS PercentMembersSeen
                , CONVERT(DECIMAL(10,4),(CASE WHEN MemberCount = 0 THEN 0 ELSE CAST(MemberswithAWV as decimal(10,4))/MemberCount END)) AS PercentAWVMembers
                , CONVERT(DECIMAL(10,4),(CASE WHEN MemberSeen = 0 THEN 0 ELSE CAST(MemberswithAWV as decimal(10,4))/MemberSeen END)) AS PercentofAWVforMembersseen

 FROM (
SELECT			CONVERT(VARCHAR(15),a.AttribTIN)							AS	PracticeTIN
				,a.AttribTINName											AS	PracticeName
				,CONVERT(VARCHAR(15),a.AttribNPI)							AS	NPI
				,a.AttribNPIName											AS	ProviderName
				,a.NPIChapter												AS	Chapter
				,SUM(CASE WHEN KPI_ID = 109 THEN KPIValue ELSE 0 END)		AS  MemberCount
                ,SUM(CASE WHEN KPI_ID = 410 THEN KPIValue ELSE 0 end)		AS  MemberSeen
                ,SUM(CASE WHEN KPI_ID = 401 THEN KPIValue ELSE 0 end)		AS  MembersWithAWV
				,a.KPIEffYear											AS	KPIEffYear
				,a.KPIEffMth											AS	KPIEffMonth						
FROM			adw.vw_Dashboard_ME_KPIByNPI a
WHERE			KPI_ID IN (109, 410,401) 
GROUP BY		a.AttribTIN
				,a.AttribTINName		
				,a.AttribNPI			
				,a.AttribNPIName		
				,a.NPIChapter
				,a.KPIEffYear
				,a.KPIEffMth
				)A	

