



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [adw].[sp_Get_ClaimProcs]
	-- Add the parameters for the stored procedure here
	 @ClientMemberKey	VARCHAR(50)
	,@SeqClaimID		VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

IF (@ClientMemberKey <> '0' AND @SeqClaimID = '0')
  SELECT [SEQ_CLAIM_ID]				AS ClaimID
      ,[SUBSCRIBER_ID]					AS MemberID
      ,[ProcNumber]						AS ProcNumber
      ,[ProcCode]						AS ProcCode
	  ,l.ICD10PCS_Desc					AS ProcDesc
      ,[ProcDate]						AS ProcDate
  FROM [adw].[Claims_Procs] a
  LEFT JOIN [lst].[LIST_ICD10PCS] l
  ON a.[ProcCode] = l.[ICD10PCS_Code]
  AND getdate() BETWEEN l.EffectiveDate AND l.ExpirationDate
  AND l.ACTIVE = 'Y'
  WHERE a.[SUBSCRIBER_ID] = @ClientMemberKey
  ORDER BY SEQ_CLAIM_ID, ProcNumber
ELSE IF (@SeqClaimID <> '0' AND @ClientMemberKey = '0')
  SELECT [SEQ_CLAIM_ID]				AS ClaimID
      ,[SUBSCRIBER_ID]					AS MemberID
      ,[ProcNumber]						AS ProcNumber
      ,[ProcCode]						AS ProcCode
	  ,l.ICD10PCS_Desc					AS ProcDesc
      ,[ProcDate]						AS ProcDate
  FROM [adw].[Claims_Procs] a
  LEFT JOIN [lst].[LIST_ICD10PCS] l
  ON a.[ProcCode] = l.[ICD10PCS_Code]
  AND getdate() BETWEEN l.EffectiveDate AND l.ExpirationDate
  AND l.ACTIVE = 'Y'
  WHERE a.SEQ_CLAIM_ID = @SeqClaimID
  ORDER BY SEQ_CLAIM_ID, ProcNumber
ELSE
  SELECT [SEQ_CLAIM_ID]				AS ClaimID
      ,[SUBSCRIBER_ID]					AS MemberID
      ,[ProcNumber]						AS ProcNumber
      ,[ProcCode]						AS ProcCode
	  ,l.ICD10PCS_Desc					AS ProcDesc
      ,[ProcDate]						AS ProcDate
  FROM [adw].[Claims_Procs] a
  LEFT JOIN [lst].[LIST_ICD10PCS] l
  ON a.[ProcCode] = l.[ICD10PCS_Code]
  AND getdate() BETWEEN l.EffectiveDate AND l.ExpirationDate
  AND l.ACTIVE = 'Y'
  WHERE a.[SUBSCRIBER_ID] = @ClientMemberKey
  AND a.SEQ_CLAIM_ID = @SeqClaimID
  ORDER BY SEQ_CLAIM_ID, ProcNumber
END

/***
EXEC [adw].[sp_Get_ClaimProcs] '4N47RR4MG67','82060752710'
***/




