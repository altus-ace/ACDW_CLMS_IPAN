
/*
Brit : 2020-12-16 WIP, Might get more requirements for finish up
*/

CREATE VIEW [adw].[vw_Dashboard_CY_AWV_Needed_LatestProviderVisits]
AS
    SELECT AWV.ClientMemberKey, 
		 AWV.RankNo,       
           AWV.Contract, 
           AWV.PlanName, 
           AWV.AttribNPI, 
           AWV.AttribTIN, 
           AWV.ProviderChapter, 
           AWV.ClientRiskScore, 
           AWV.ClientRiskScoreLevel, 
           AWV.FirstName, 
           AWV.LastName, 
           AWV.CurrentAge, 
           AWV.DOB, 
           AWV.Gender, 
           AWV.MemberHomeAddress, 
           AWV.MemberHomeAddress1, 
           AWV.MemberHomeCity, 
           AWV.MemberHomeState, 
           AWV.MemberHomeZip, 
           AWV.MemberPhone, 
           AWV.MemberCellPhone, 
           AWV.MemberHomePhone, 
           AWV.CompliantStatus, 
           AWV.LstAWVDate, 
           AWV.Expired, 
           AWV.SvcYear, 
           --AWV.Gaps, 
           AWV.EffectiveAsOfDate,             
           MbrLatestVisit.SVCProviderNPI LatestVistSvcProviderNPI, 
           mbrLatestVisit.SVCProviderName LatestVisitSvcProviderName,
           MbrLatestVisit.PrimaryServiceDate LatestVisitSvcDate,      
           LatestVistWithAtttribNPI.PrimaryServiceDate LatestSvcDateWithAttribNpi,
		 MbrAttNpiVisitCount.MbrAttNpiVisitCount
    FROM adw.vw_Dashboard_CY_AWV_Needed AWV 
        LEFT JOIN (
		  SELECT src.ClientMemberKey,              
                 src.SVCProviderNPI, 
                 src.PrimaryServiceDate, 
                 src.aRN,
                 src.SVCProviderName
              FROM
              (
                  SELECT pv.ClientMemberKey, 
                         pv.AttribNPI, 
                         pv.AttribTIN, 
                         pv.SVCProviderNPI, 
                         pv.PrimaryServiceDate, 
                         pv.SVCProviderName,
                         ROW_NUMBER() OVER(PARTITION BY pv.ClientMemberKey ORDER BY pv.PrimaryServiceDate DESC) aRN
               FROM adw.FctPhysicianVisits PV
		  ) src
		  WHERE src.aRN = 1
	   ) MbrLatestVisit
            ON awv.ClientMemberKey = MbrLatestVisit.ClientMemberKey       
        LEFT JOIN (
		  SELECT src.ClientMemberKey,              
                     src.SVCProviderNPI, 
                     src.PrimaryServiceDate, 
                     src.aRN,
                     src.SVCProviderName
            FROM (
                 SELECT pv.ClientMemberKey, 
                    pv.AttribNPI, 
                    pv.AttribTIN, 
                    pv.SVCProviderNPI, 
                    pv.PrimaryServiceDate, 
                    pv.SVCProviderName,
                    ROW_NUMBER() OVER(PARTITION BY pv.ClientMemberKey ORDER BY pv.PrimaryServiceDate DESC) aRN
                 FROM adw.FctPhysicianVisits PV
                 WHERE pv.AttribNPI = pv.SVCProviderNPI
            ) src
            WHERE src.aRN = 1) LatestVistWithAtttribNPI
           ON awv.ClientMemberKey = LatestVistWithAtttribNPI.ClientMemberKey       
	   LEFT JOIN (SELECT pv.ClientMemberKey, pv.AttribNPI, COUNT(DISTINCT pv.SEQ_ClaimID) MbrAttNpiVisitCount
			 FROM adw.FctPhysicianVisits PV
			 WHERE pv.PrimaryServiceDate >= DATEFROMPARTS(Year(GETDATE()),1,1)
			 GROUP BY pv.ClientMemberKey, pv.AttribNPI) AS MbrAttNpiVisitCount
		  ON awv.ClientMemberKey = MbrAttNpiVisitCount.ClientMemberKey
			 AND awv.AttribNPI = MbrAttNpiVisitCount.AttribNPI
    ;
           

