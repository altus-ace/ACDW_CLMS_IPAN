CREATE PROCEDURE [adw].[ValidateClaimsTables] 
AS 
BEGIN
--    CREATE TABLE amd.ClaimsValidationCounts(skey INT IDENTITY(1,1) PRIMARY KEY
--	   , [ValidationType] VARCHAR(20)
--	   , cnt INT
--	   , PrimarySvcYear INT
--	   , CatOfSvc VARCHAR(20) DEFAULT('ALL')
--	   , CreatedDate Date NOT NULL DEFAULT(getdate())
--	   , CreatedBy Varchar(50) not null default(system_user)
--	   );
--

	SELECT 'Claims_Headers' AS srcTbl, h.SrcAdiTableName	FROM adw.Claims_Headers h	group by h.SrcAdiTableName;
	SELECT 'Claims_Details' AS srcTbl, h.SrcAdiTableName	FROM adw.Claims_Details h	group by h.SrcAdiTableName;
	SELECT 'Claims_Diags'	AS srcTbl, h.SrcAdiTableName	FROM adw.Claims_Diags	h	group by h.SrcAdiTableName;
	SELECT 'Claims_Procs'	AS srcTbl, h.SrcAdiTableName	FROM adw.Claims_Procs	h	group by h.SrcAdiTableName;

    INSERT INTO amd.ClaimsValidationCounts(ValidationType, cnt, PrimarySvcYear)
    SELECT 'cntHdrs' [TYPE], COUNT(*) cnt, Year(h.PRIMARY_SVC_DATE)	 AS PrimarySvcYear  
        FROM adw.Claims_Headers H 
        GROUP BY Year(h.PRIMARY_SVC_DATE);
    
    INSERT INTO amd.ClaimsValidationCounts(ValidationType, cnt, PrimarySvcYear)
    SELECT 'cntDtls' ,COUNT(*) cnt, Year(h.PRIMARY_SVC_DATE)	   AS PrimarySvcYear  
        FROM adw.Claims_Details d 
    	   JOIN adw.Claims_Headers h ON d.SEQ_CLAIM_ID = h.SEQ_CLAIM_ID
        GROUP BY Year(h.PRIMARY_SVC_DATE);

    INSERT INTO amd.ClaimsValidationCounts(ValidationType, cnt, PrimarySvcYear)
    SELECT 'cntDiag', COUNT(*) cntDiag, Year(h.PRIMARY_SVC_DATE)   AS PrimarySvcYear  
        FROM adw.Claims_Diags d 
    	   JOIN adw.Claims_Headers h ON d.SEQ_CLAIM_ID = h.SEQ_CLAIM_ID
        GROUP BY Year(h.PRIMARY_SVC_DATE);

    INSERT INTO amd.ClaimsValidationCounts(ValidationType, cnt, PrimarySvcYear)
    SELECT 'cntProc', COUNT(*) cntProc, Year(h.PRIMARY_SVC_DATE)   AS PrimarySvcYear  
        FROM adw.Claims_Procs p  
    	   JOIN adw.Claims_Headers h ON p.SEQ_CLAIM_ID = h.SEQ_CLAIM_ID
        GROUP BY Year(h.PRIMARY_SVC_DATE);
    
    INSERT INTO amd.ClaimsValidationCounts(ValidationType, cnt, PrimarySvcYear)    
    SELECT 'cntMbrs', COUNT(*) cntMbrs, Year(getdate())
        FROM adw.Claims_Member  m ;

    INSERT INTO amd.ClaimsValidationCounts(ValidationType, cnt, PrimarySvcYear, CatOfSvc)    
    SELECT 'cntHdrsByCatSvcYear' [type], COUNT(*) , Year(h.PRIMARY_SVC_DATE) AS PrimarySvcYear, h.CATEGORY_OF_SVC
        FROM adw.Claims_Headers H 
        GROUP BY  h.CATEGORY_OF_SVC, Year(h.PRIMARY_SVC_DATE)
	   ORDER BY Year(h.PRIMARY_SVC_DATE) DESC, h.CATEGORY_OF_SVC
   
   
    INSERT INTO amd.ClaimsValidationCounts(ValidationType, cnt, PrimarySvcYear, CatOfSvc)    
    SELECT 'cntHdrsByClmTypeYear' [TYPE], COUNT(*),  Year(h.PRIMARY_SVC_DATE) AS PrimarySvcYear, h.claim_type 
	   FROM adw.Claims_Headers H
	   --where year(h.primary_svc_date) = 2020
	   GROUP BY H.CLAIM_TYPE, YEAR(h.PRIMARY_SVC_DATE)
	   ORDER BY h.CLAIM_TYPE , YEAR(h.PRIMARY_SVC_DATE)
   


   SELECT * 
   FROM amd.ClaimsValidationCounts c
   ORDER BY c.CreatedDate DESC;
END    




