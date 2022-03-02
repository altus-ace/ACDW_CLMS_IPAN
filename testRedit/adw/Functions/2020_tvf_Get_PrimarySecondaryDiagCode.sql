

CREATE FUNCTION [adw].[2020_tvf_Get_PrimarySecondaryDiagCode]
(
	@SubscriberId VARCHAR(50)
	,@SeqClaimID VARCHAR(50)
	,@CodeEffDate DATE
)
RETURNS TABLE
AS RETURN
(
	   SELECT DISTINCT pvtOut.SUBSCRIBER_ID as ClientMemberKey, pvtOut.SEQ_CLAIM_ID as SeqClaimID, PvtOut.[1] AS PrimaryDiagCode, PrimDesc.VALUE_CODE_NAME AS PrimaryDiagDescription
	       , PvtOut.[2] AS SecondaryDiagCode, SecondDesc.Value_Code_Name AS SecondaryDiagDescription
	   FROM (
	   SELECT Diags.SUBSCRIBER_ID
	       , Diags.SEQ_CLAIM_ID
	       , diagNumber
	       , diagCode    
	   FROM adw.Claims_Diags Diags    
	   WHERE (Diags.diagNumber = 1 or Diags.diagNumber = 2)
	   ) pd
	   PIVOT( MAX(pd.diagCode)
	       FOR diagNumber IN ([1],[2])
	   ) AS PvtOut
	   LEFT JOIN [lst].[LIST_ICD10CM] PrimDesc ON PrimDesc.value_code = pvtOut.[1] 
	   LEFT JOIN [lst].[LIST_ICD10CM] SecondDesc ON SecondDesc.value_code = pvtOut.[2] 
	   WHERE ((@SeqClaimID <> '0' AND SEQ_CLAIM_ID = @SeqClaimID) OR (@SeqClaimID = '0')) 		  
		  AND ((@SubscriberID <> '0' AND  pvtOut.SUBSCRIBER_ID = @SubscriberId) OR (@SubscriberId = '0'))	
		  AND @CodeEffDate BETWEEN PrimDesc.EffectiveDate AND PrimDesc.ExpirationDate	
		  AND @CodeEffDate BETWEEN SecondDesc.EffectiveDate AND SecondDesc.ExpirationDate  
)

/***
SELECT *
FROM [adw].[2020_tvf_Get_PrimarySecondaryDiagCode] ('1A13C74KX90','83942614820',getdate())
***/

