


CREATE PROCEDURE [adw].[CalcClientRiskScore]
	(
	@ClientKeyID	VARCHAR(2),
	@RunDate		DATE,
	@KPIStartDate	DATE,
	@KPIEndDate		DATE
	)
AS    
BEGIN
    SET NOCOUNT ON;


UPDATE adw.FctMembership
	SET
		 [ClientRiskScore] = b.ClientRiskScore
		,[ClientRiskScoreLevel] = b.ClientRiskLevel
		,[EligibleYear] = b.ClientEligibleYear
FROM (
		SELECT  [MBI_ID]
		,ISNULL([HCCRiskScore],0.00) as ClientRiskScore
		,CASE [PatientidentifiedHighRisk] WHEN 'Y' THEN 1.00 ELSE 0.00 END  AS ClientRiskLevel
		,CASE [New_2020_Patient] WHEN 'Y' THEN 2020 ELSE 0 END  AS ClientEligibleYear
		FROM [adi].[tmp_MemberListValidation]
		WHERE [DataDate] = (SELECT MAX([DataDate]) FROM [adi].[tmp_MemberListValidation])
	) b
WHERE [MBI] = b.MBI_ID
AND @RunDate BETWEEN RwEffectiveDate AND RwExpirationDate
AND @ClientKeyID = ClientKey

END;												

/***
EXEC [adw].[CalcClientRiskScore] 16,'02-01-2020','01-01-2019','12-31-2019'

SELECT [MBI]
		,[ClientRiskScore] 
		,[ClientRiskScoreLevel] 
		,[EligibleYear] 
		,RwEffectiveDate
FROM adw.FctMembership
WHERE RwEffectiveDate = '2020-02-01'
***/

