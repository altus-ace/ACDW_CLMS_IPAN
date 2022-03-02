




CREATE PROCEDURE [adw].[CalcfctERToIPVisits]
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

	INSERT INTO [adw].[FctEDToIPVisits]
         (
          [SrcFileName]
         ,[LoadDate]
         ,[DataDate]
         ,[ClientKey]
         ,[ClientMemberKey]
			,[EffectiveAsOfDate]
			,[ClaimID_ER]
			,[ClaimID_IP]
			,[PrimSvcDate_ER]
			,[SvcToDate_ER]
			,[PrimSvcDate_IP]
			,[SvcToDate_IP]
			,[AttribNPI])
	SELECT  DISTINCT CONCAT('[adw].[CalcfctERToIPVisits]',@KPIStartDate,'-',@KPIEndDate)
			,GETDATE()
			,@RunDate
			,a.ClientKey
			,e.ClientMemberKey
			,@RunDate
			,[ClaimID_ER]
			,[ClaimID_IP]
			,[PrimSvcDate_ER]
			,[SvcToDate_ER]
			,[PrimSvcDate_IP]
			,[SvcToDate_IP]
			,a.NPI
	FROM adw.[2020_tvf_Get_ERToIPAdmit] (@KPIStartDate,@KPIEndDate) e
	LEFT JOIN [adw].[2020_tvf_Get_ActiveMembersFull] (@MbrEffectiveDate) a
	ON e.ClientMemberKey = a.ClientMemberKey
	


END;												


/***
EXEC [adw].[CalcfctERToIPVisits] 16,'05-15-2020','01-01-2019','02-29-2020','05-15-2020'

SELECT *
FROM [adw].[FctEDToIPVisits]
WHERE ClientMemberKey IN ('1A11X60AE93')

***/

