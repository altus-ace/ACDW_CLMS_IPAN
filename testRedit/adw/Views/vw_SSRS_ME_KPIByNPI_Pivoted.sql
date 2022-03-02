
CREATE VIEW [adw].[vw_SSRS_ME_KPIByNPI_Pivoted]
AS

SELECT Calc2.* 
    ,  ((Calc2.kpiTRGT - Calc2.Rate)* DEN) GTT --= (Target - Rate)* DEN
FROM ( 
    SELECT Calc1.*
        ,(CONVERT(Numeric(5, 2) , Calc1.Num )/Calc1.DEN)   Rate -- = NUM Divided by DEN 
    FROM (
    	   SELECT Src.AttribNPI, Src.AttribTIN, Src.KPI, SUM(Den) DEN, SUM(Num) NUM, SUM(cop) COP, KPIEffMth, KPIEffYear
    	       , CASE WHEN (Src.Kpi = 'ACE_ACO_FLU')		  THEN 0.70
    	   		  WHEN (Src.Kpi = 'ACE_ACO_FS')		  THEN 0.82
    	   		  WHEN (Src.Kpi = 'ACE_ACO_SCD')		  THEN 0.70
    	   		  WHEN (Src.Kpi = 'ACE_ACO_TSC')		  THEN 0.0
    	   		  WHEN (Src.Kpi = 'ACE_HEDIS_ACO_BCS')	  THEN 0.80
    	   		  WHEN (Src.Kpi = 'ACE_HEDIS_ACO_CBP')	  THEN 0.80
    	   		  WHEN (Src.Kpi = 'ACE_HEDIS_ACO_CDC_9')  THEN 0.10
    	   		  WHEN (Src.Kpi = 'ACE_HEDIS_ACO_COL')	  THEN 0.70
    	   		  WHEN (Src.Kpi = 'ACE_HEDIS_SPC')		  THEN 0.0
    	   		  WHEN (Src.Kpi = 'ACE_NQF_DPR12')		  THEN 0.0
    	   		  END AS kpiTRGT
    	   
    	   FROM (SELECT KPI.AttribNPI,Kpi.AttribTIN, SUBSTRING(kpi.Kpi, 13, len(kpi.kpi)) KPI, KPI.KPIEffMth, kpi.KPIEffYear
    	   	       , CASE WHEN (KPI.KPI_ID = 500) THEN Kpi.KpiValue ELSE 0 END AS Den
    	   	       , CASE WHEN (KPI.KPI_ID = 501) THEN Kpi.KpiValue ELSE 0 END AS Num
    	   	       , CASE WHEN (KPI.KPI_ID = 502) THEN Kpi.KpiValue ELSE 0 END AS COP	   
    	   	   FROM adw.vw_Dashboard_ME_KPIByNPI  kpi
    	   	    JOIN (SELECT MAX(kpiMonth.KPIEffMth) MaxKpiMonth, Max(kpiMonth.KpiEffYear) MaxKpiYear, kpiMonth.KPI_ID
    	   				FROM adw.vw_Dashboard_ME_KPIByNPI  kpiMonth
    	   				    JOIN (SELECT MAX(kpi.KpiEffYear) KpiEffYear FROM  adw.vw_Dashboard_ME_KPIByNPI  kpi) KpiYear
    	   				    ON kpiMonth.KPIEffYear = KpiYear.KpiEffYear
    	   				GROUP BY kpiMonth.KPI_ID
    	   				) MaxEff 
    	   				ON kpi.KPI_ID = MaxEff.KPI_ID
    	   				    and kpi.KPIEffMth = MaxEff.MaxKpiMonth
    	   				    and kpi.KPIEffYear = MaxEff.MaxKpiYear		 
    	   	   WHERE kpi.KPI_id in (500, 501, 502)
    	   	   ) Src
    	   GROUP BY Src.AttribNPI, Src.AttribTIN, Src.KPI, KPIEffMth, KPIEffYear
    ) Calc1
) Calc2

