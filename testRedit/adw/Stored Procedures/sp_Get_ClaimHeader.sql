-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [adw].[sp_Get_ClaimHeader]
	-- Add the parameters for the stored procedure here
	 @ClientMemberKey	VARCHAR(50)
	,@SeqClaimID		VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

IF (@ClientMemberKey <> '0' AND @SeqClaimID = '0')
	SELECT [SEQ_CLAIM_ID]				AS ClaimID
      ,[SUBSCRIBER_ID]					AS MemberID
      ,[CATEGORY_OF_SVC]				AS CatOfSvc
      ,[PRIMARY_SVC_DATE]				AS SvcStartDate
      ,[SVC_TO_DATE]					AS SvcEndDate
      ,[SVC_PROV_FULL_NAME]				AS SvcProvName
	  ,[VENDOR_ID]						AS VendorID
      ,[VEND_FULL_NAME]					AS VendorName
      ,H.[DRG_CODE]						AS Drg
	  ,DRG.DRG_DESC                     AS DRGDesc  
      ,[BILL_TYPE]						AS BillType
      ,[ADMISSION_DATE]					AS AdmDate
      ,[ADMIT_SOURCE_CODE]				AS AdmSrc
      ,[PATIENT_STATUS]					AS PtStatus
      ,[CLAIM_TYPE]						AS ClaimType
	  ,[PROCESSING_STATUS]				AS ProcessingStatus
	  ,[CLAIM_STATUS]					AS ClaimStatus
      ,[TOTAL_BILLED_AMT]				AS BilledAmt
      ,[TOTAL_PAID_AMT]					AS PaidAmt
      ,[DISCHARGE_DISPO]				AS DischDispo
  FROM [adw].[Claims_Headers] H
  LEFT JOIN [lst].[List_DRG] DRG
  ON H.DRG_CODE = DRG.[DRG_CODE]
  AND getdate() BETWEEN DRG.EffectiveDate AND DRG.ExpirationDate
  AND DRG.ACTIVE = 'Y'
  WHERE [SUBSCRIBER_ID] = @ClientMemberKey
  ORDER BY CATEGORY_OF_SVC, PRIMARY_SVC_DATE DESC
ELSE IF (@SeqClaimID <> '0' AND @ClientMemberKey = '0')
	SELECT [SEQ_CLAIM_ID]				AS ClaimID
      ,[SUBSCRIBER_ID]					AS MemberID
      ,[CATEGORY_OF_SVC]				AS CatOfSvc
      ,[PRIMARY_SVC_DATE]				AS SvcStartDate
      ,[SVC_TO_DATE]					AS SvcEndDate
      ,[SVC_PROV_FULL_NAME]				AS SvcProvName
      ,[VENDOR_ID]						AS VendorID
	  ,[VEND_FULL_NAME]					AS VendorName
      ,H.DRG_CODE						AS Drg
	  ,DRG.DRG_DESC                    AS DRGDesc
      ,[BILL_TYPE]						AS BillType
      ,[ADMISSION_DATE]					AS AdmDate
      ,[ADMIT_SOURCE_CODE]				AS AdmSrc
      ,[PATIENT_STATUS]					AS PtStatus
      ,[CLAIM_TYPE]						AS ClaimType
	  ,[PROCESSING_STATUS]				AS ProcessingStatus
	  ,[CLAIM_STATUS]					AS ClaimStatus
      ,[TOTAL_BILLED_AMT]				AS BilledAmt
      ,[TOTAL_PAID_AMT]					AS PaidAmt
      ,[DISCHARGE_DISPO]				AS DischDispo
  FROM [adw].[Claims_Headers] H
  LEFT JOIN [lst].[List_DRG] DRG
  ON H.DRG_CODE = DRG.[DRG_CODE]
  AND getdate() BETWEEN DRG.EffectiveDate AND DRG.ExpirationDate
  AND DRG.ACTIVE = 'Y'
  WHERE [SEQ_CLAIM_ID] = @SeqClaimID
  ORDER BY CATEGORY_OF_SVC, PRIMARY_SVC_DATE DESC
ELSE
	SELECT [SEQ_CLAIM_ID]				AS ClaimID
      ,[SUBSCRIBER_ID]					AS MemberID
      ,[CATEGORY_OF_SVC]				AS CatOfSvc
      ,[PRIMARY_SVC_DATE]				AS SvcStartDate
      ,[SVC_TO_DATE]					AS SvcEndDate
      ,[SVC_PROV_FULL_NAME]				AS SvcProvName
	  ,[VENDOR_ID]						AS VendorID
      ,[VEND_FULL_NAME]					AS VendorName
      ,H.DRG_CODE						AS Drg
	  ,DRG.DRG_DESC                    AS DRGDesc
      ,[BILL_TYPE]						AS BillType
      ,[ADMISSION_DATE]					AS AdmDate
      ,[ADMIT_SOURCE_CODE]				AS AdmSrc
      ,[PATIENT_STATUS]					AS PtStatus
      ,[CLAIM_TYPE]						AS ClaimType
 	  ,[PROCESSING_STATUS]				AS ProcessingStatus
	  ,[CLAIM_STATUS]					AS ClaimStatus
      ,[TOTAL_BILLED_AMT]				AS BilledAmt
      ,[TOTAL_PAID_AMT]					AS PaidAmt
      ,[DISCHARGE_DISPO]				AS DischDispo
  FROM [adw].[Claims_Headers]  H
  LEFT JOIN [lst].[List_DRG] DRG
  ON H.DRG_CODE = DRG.[DRG_CODE]
  AND getdate() BETWEEN DRG.EffectiveDate AND DRG.ExpirationDate
  AND DRG.ACTIVE = 'Y'
  WHERE [SEQ_CLAIM_ID] = @SeqClaimID
  AND [SUBSCRIBER_ID] = @ClientMemberKey
  ORDER BY CATEGORY_OF_SVC, PRIMARY_SVC_DATE DESC

END

/***
EXEC adw.sp_Get_ClaimHeader '1G08R12880C','D0285S92854263100'
***/
