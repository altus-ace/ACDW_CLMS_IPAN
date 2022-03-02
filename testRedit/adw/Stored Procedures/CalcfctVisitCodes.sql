




CREATE PROCEDURE [adw].[CalcfctVisitCodes]
	(
	@ClientKeyID				VARCHAR(2),
	@RunDate						DATE,
	@KPIStartDate				DATE,
	@KPIEndDate					DATE,
	@MbrEffectiveDate			DATE
	)
AS    
BEGIN
    SET NOCOUNT ON;

	INSERT INTO [adw].[FctVisitCodes] (
			 [SrcFileName]		
			,[LoadDate]	
			,[EffectiveAsOfDate] 
			,[ClientKey]			
			,[ClientMemberKey]	
			,[SEQ_ClaimID]		
			,[ClaimType] 
			,[PrimaryServiceDate]
			,[PrimDx]			
			,[PrimPC]
			,[DRGCode]
			,[DRGType]				
			,[MDCCode]				
			,[PrimCPT]			
			,[ERFlg]				
			,[ObvFlg]			
			,[SurFlg]		)	

	SELECT '[adw].[CalcfctVisitCodes]', getdate(), @RunDate, @ClientKeyID, * 
	FROM (
		SELECT DISTINCT main.ClientMemberKey, main.Seq_ClaimID, main.CLAIM_TYPE
			,main.PRIMARY_SVC_DATE as PrimSvcDate
			,diag.DiagCode
			,pro.ProcCode
			,CASE WHEN main.DRG_CODE = '' OR main.DRG_CODE = '000' THEN '000' ELSE main.DRG_CODE END as DrgCode
			,main.DrgType			
			,main.Mdc_Code as MdcCode
			,cpt.CptCode
			,(CASE WHEN er.ClientMemberKey IS NULL THEN 0 ELSE 1 END) AS ER_Flg
			,(CASE WHEN obv.ClientMemberKey IS NULL THEN 0 ELSE 1 END) AS Obv_Flg
			,(CASE WHEN sur.ClientMemberKey IS NULL THEN 0 ELSE 1 END) AS Surg_Flg
		FROM
		(SELECT DISTINCT SUBSCRIBER_ID AS ClientMemberKey
			,SEQ_CLAIM_ID AS Seq_ClaimID, PRIMARY_SVC_DATE, CLAIM_TYPE, m.DRG_CODE, drg.MedMorSurgP as DRGType, l.Mdc_Code
		FROM adw.Claims_Headers m
		LEFT JOIN lst.LIST_DRG drg
			ON m.DRG_CODE = drg.DRG_CODE
			AND @KPIStartDate BETWEEN drg.EffectiveDate AND drg.ExpirationDate
			AND drg.ACTIVE = 'Y'
		LEFT JOIN lst.LIST_MDC l
			ON m.DRG_CODE = l.MS_DRG
			AND @KPIStartDate BETWEEN l.EffectiveDate AND l.ExpirationDate
			AND l.ACTIVE = 'Y'
		WHERE CLAIM_TYPE IN ('20','40','50','60','71')
		AND CONVERT(DATETIME, m.PRIMARY_SVC_DATE) BETWEEN @KPIStartDate AND @KPIEndDate
		) main
		
		JOIN [adw].[2020_tvf_Get_ActiveMembersFull]	(@MbrEffectiveDate) a
		ON main.ClientMemberKey = a.ClientMemberKey

		LEFT JOIN
		(
		SELECT DISTINCT SUBSCRIBER_ID as ClientMemberKey, SEQ_CLAIM_ID as Seq_ClaimID, [diagCodeWithoutDot] AS DiagCode
		FROM adw.Claims_Diags m
		WHERE diagNumber = 1
		) diag
		ON main.ClientMemberKey = diag.ClientMemberKey
		AND main.Seq_ClaimID = diag.Seq_ClaimID
		
		LEFT JOIN
		(
		SELECT DISTINCT SUBSCRIBER_ID as ClientMemberKey, SEQ_CLAIM_ID as Seq_ClaimID, [ProcCode] AS ProcCode
		FROM adw.Claims_Procs m
		WHERE ProcNumber = 1
		) pro
		ON main.ClientMemberKey = pro.ClientMemberKey
		AND main.Seq_ClaimID = pro.Seq_ClaimID
			
		LEFT JOIN
		(
		SELECT DISTINCT SUBSCRIBER_ID as ClientMemberKey, SEQ_CLAIM_ID as Seq_ClaimID
			,STUFF((SELECT ',' + CONVERT(varchar(10),s.PROCEDURE_CODE)
		            FROM 
						(SELECT DISTINCT SUBSCRIBER_ID, SEQ_CLAIM_ID, PROCEDURE_CODE 
						FROM adw.Claims_Details 
						WHERE LEN(PROCEDURE_CODE) > 1 AND PROCEDURE_CODE <> '0'
						AND LINE_NUMBER = 1) s
					WHERE s.SUBSCRIBER_ID = m.SUBSCRIBER_ID
					AND s.SEQ_CLAIM_ID = m.SEQ_CLAIM_ID
		            FOR XML PATH('')
		            ), 1, 1, '') AS CPTCode
		FROM adw.Claims_Details m
		--WHERE SUBSCRIBER_ID = @ClientMemberKey
		) cpt
		ON main.ClientMemberKey = cpt.ClientMemberKey
		AND main.Seq_ClaimID = cpt.Seq_ClaimID
		
		LEFT JOIN 
		(SELECT DISTINCT SUBSCRIBER_ID as ClientMemberKey, SEQ_CLAIM_ID as Seq_ClaimID 
		FROM adw.[2020_tvf_Get_SurgVisits] (@KPIStartDate, @KPIEndDate)
		) sur
		ON main.ClientMemberKey = sur.ClientMemberKey
		AND main.Seq_ClaimID = sur.Seq_ClaimID
		
		LEFT JOIN 
		(SELECT DISTINCT SUBSCRIBER_ID as ClientMemberKey, SEQ_CLAIM_ID as Seq_ClaimID 
		FROM adw.[2020_tvf_Get_ERVisits] (@KPIStartDate, @KPIEndDate)
		) er
		ON main.ClientMemberKey = er.ClientMemberKey
		AND main.Seq_ClaimID = er.Seq_ClaimID
		
		LEFT JOIN 
		(SELECT DISTINCT SUBSCRIBER_ID as ClientMemberKey, SEQ_CLAIM_ID as Seq_ClaimID 
		FROM adw.[2020_tvf_Get_ObvVisits] (@KPIStartDate, @KPIEndDate)
		) obv
		ON main.ClientMemberKey = obv.ClientMemberKey
		AND main.Seq_ClaimID = obv.Seq_ClaimID
		
		) b

END;												


/***
EXEC [adw].[CalcfctVisitCodes] 16,'07-15-2020','01-01-2019','05-31-2020'

SELECT *
FROM [adw].[FctVisitCodes]
WHERE EffectiveAsOfDate = '08-15-2020'
and erflg = 1
and PrimaryServiceDate BETWEEN '01-01-2020' AND '03-31-2020'
***/
