CREATE PROCEDURE [adw].[sp_Get_ClaimPharmacy]   
-- Add the parameters for the stored procedure here    
@ClientMemberKey VARCHAR(50), 
@SeqClaimID      VARCHAR(50)
AS
    BEGIN
        SET NOCOUNT ON;
        IF(@ClientMemberKey <> '0'
           AND @SeqClaimID = '0')
            SELECT [SEQ_CLAIM_ID] AS ClaimID
                 , [SUBSCRIBER_ID] AS MemberID
                 , [LINE_NUMBER] AS LineNumber
                 , [SUB_LINE_CODE] AS LineCode
                 , [DETAIL_SVC_DATE] AS SvcStartDate
                 , [QUANTITY] AS Qty
                 , [BILLED_AMT] AS BilledAmt
                 , [PAID_AMT] AS PaidAmt
                 , [NDC_CODE] AS NDCCode
                 , [RX_GENERIC_BRAND_IND] AS GenBrandInd
                 , [RX_SUPPLY_DAYS] AS SuppyDays
                 , [RX_DISPENSING_FEE_AMT] AS DispFeeAmt
                 , [RX_INGREDIENT_AMT] AS IngredientAmt
                 , [RX_FORMULARY_IND] AS FormInd
                 , [RX_DATE_PRESCRIPTION_WRITTEN] AS PrescriptionDateWritten
                 , [RX_DATE_PRESCRIPTION_FILLED] AS PrescriptionDateFilled
                 , [PRESCRIBING_PROV_TYPE_ID] AS PrescribingProvType
                 , [PRESCRIBING_PROV_ID] AS PrescribingProvID
                 , PCP.PCP_LAST_NAME + ',' + PCP.PCP_FIRST_NAME + PCP.PCP_MI AS PrescribingProvName
                 , [BRAND_NAME] AS BrandName
                 , [DRUG_STRENGTH_DESC] AS DrugStrength
                 , [GPI] AS GPI
                 , [GPI_DESC] AS GPIDesc
                 , [CONTROLLED_DRUG_IND] AS CtrlDrugInd
                 , [COMPOUND_CODE] AS CompoundCode
                 , C4.Brand AS NDCDesc
            FROM [adw].[Claims_Details] C3
                 LEFT JOIN [adw].[2020_tvf_Get_NDCDesc](GETDATE()) C4 ON C3.NDC_CODE = C4.ClaimsNDC
                 --LEFT JOIN [lst].[List_PCP] PCP ON C3.PRESCRIBING_PROV_ID = PCP.[PCP_NPI]				 
				 LEFT JOIN (SELECT pr.NPI, pr.LastName PCP_LAST_NAME, pr.FirstName Pcp_First_Name, '' Pcp_MI
								FROM acdw_clms_ipan.adw.tvf_AllClient_ProviderRoster (0, getdate(), 0) pr
								GROUP BY pr.NPI, pr.LastName, pr.FirstName
								) PCP ON C3.PRESCRIBING_PROV_ID = PCP.NPI
            WHERE LEN(C3.NDC_CODE) >= 10
                  AND [SUBSCRIBER_ID] = @ClientMemberKey
            ORDER BY SEQ_CLAIM_ID
                   , LINE_NUMBER;
            ELSE
            IF(@SeqClaimID <> '0'
               AND @ClientMemberKey = '0')
                SELECT [SEQ_CLAIM_ID] AS ClaimID
                     , [SUBSCRIBER_ID] AS MemberID
                     , [LINE_NUMBER] AS LineNumber
                     , [SUB_LINE_CODE] AS LineCode
                     , [DETAIL_SVC_DATE] AS SvcStartDate
                     , [QUANTITY] AS Qty
                     , [BILLED_AMT] AS BilledAmt
                     , [PAID_AMT] AS PaidAmt
                     , [NDC_CODE] AS NDCCode
                     , [RX_GENERIC_BRAND_IND] AS GenBrandInd
                     , [RX_SUPPLY_DAYS] AS SuppyDays
                     , [RX_DISPENSING_FEE_AMT] AS DispFeeAmt
                     , [RX_INGREDIENT_AMT] AS IngredientAmt
                     , [RX_FORMULARY_IND] AS FormInd
                     , [RX_DATE_PRESCRIPTION_WRITTEN] AS PrescriptionDateWritten
                     , [RX_DATE_PRESCRIPTION_FILLED] AS PrescriptionDateFilled
                     , [PRESCRIBING_PROV_TYPE_ID] AS PrescribingProvType
                     , [PRESCRIBING_PROV_ID] AS PrescribingProvID
                     , PCP.PCP_LAST_NAME + ',' + PCP.PCP_FIRST_NAME + PCP.PCP_MI AS PrescribingProvName
                     , [BRAND_NAME] AS BrandName
                     , [DRUG_STRENGTH_DESC] AS DrugStrength
                     , [GPI] AS GPI
                     , [GPI_DESC] AS GPIDesc
                     , [CONTROLLED_DRUG_IND] AS CtrlDrugInd
                     , [COMPOUND_CODE] AS CompoundCode
                     , C4.Brand AS NDCDesc
                FROM [adw].[Claims_Details] C3
                     LEFT JOIN [adw].[2020_tvf_Get_NDCDesc](GETDATE()) C4 ON C3.NDC_CODE = C4.ClaimsNDC
                     --LEFT JOIN [lst].[List_PCP] PCP ON C3.PRESCRIBING_PROV_ID = PCP.[PCP_NPI]
					 LEFT JOIN (SELECT pr.NPI, pr.LastName PCP_LAST_NAME, pr.FirstName Pcp_First_Name, '' Pcp_MI
								FROM acdw_clms_ipan.adw.tvf_AllClient_ProviderRoster (0, getdate(), 0) pr
								GROUP BY pr.NPI, pr.LastName, pr.FirstName
								) PCP ON C3.PRESCRIBING_PROV_ID = PCP.NPI
                WHERE LEN(C3.NDC_CODE) >= 10
                      AND [SEQ_CLAIM_ID] = @SeqClaimID
                ORDER BY SEQ_CLAIM_ID
                       , LINE_NUMBER;
                ELSE
                SELECT [SEQ_CLAIM_ID] AS ClaimID
                     , [SUBSCRIBER_ID] AS MemberID
                     , [LINE_NUMBER] AS LineNumber
                     , [SUB_LINE_CODE] AS LineCode
                     , [DETAIL_SVC_DATE] AS SvcStartDate
                     , [QUANTITY] AS Qty
                     , [BILLED_AMT] AS BilledAmt
                     , [PAID_AMT] AS PaidAmt
                     , [NDC_CODE] AS NDCCode
                     , [RX_GENERIC_BRAND_IND] AS GenBrandInd
                     , [RX_SUPPLY_DAYS] AS SuppyDays
                     , [RX_DISPENSING_FEE_AMT] AS DispFeeAmt
                     , [RX_INGREDIENT_AMT] AS IngredientAmt
                     , [RX_FORMULARY_IND] AS FormInd
                     , [RX_DATE_PRESCRIPTION_WRITTEN] AS PrescriptionDateWritten
                     , [RX_DATE_PRESCRIPTION_FILLED] AS PrescriptionDateFilled
                     , [PRESCRIBING_PROV_TYPE_ID] AS PrescribingProvType
                     , [PRESCRIBING_PROV_ID] AS PrescribingProvID
                     , PCP.PCP_LAST_NAME + ',' + PCP.PCP_FIRST_NAME + PCP.PCP_MI AS PrescribingProvName
                     , [BRAND_NAME] AS BrandName
                     , [DRUG_STRENGTH_DESC] AS DrugStrength
                     , [GPI] AS GPI
                     , [GPI_DESC] AS GPIDesc
                     , [CONTROLLED_DRUG_IND] AS CtrlDrugInd
                     , [COMPOUND_CODE] AS CompoundCode
                     , C4.Brand AS NDCDesc
                FROM [adw].[Claims_Details] C3					
                     LEFT JOIN [adw].[2020_tvf_Get_NDCDesc](GETDATE()) C4 ON C3.NDC_CODE = C4.ClaimsNDC
                     --LEFT JOIN [lst].[List_PCP] PCP ON C3.PRESCRIBING_PROV_ID = PCP.[PCP_NPI]
					 LEFT JOIN (SELECT pr.NPI, pr.LastName PCP_LAST_NAME, pr.FirstName Pcp_First_Name, '' Pcp_MI
								FROM acdw_clms_ipan.adw.tvf_AllClient_ProviderRoster (0, getdate(), 0) pr
								GROUP BY pr.NPI, pr.LastName, pr.FirstName
								) PCP ON C3.PRESCRIBING_PROV_ID = PCP.NPI
                WHERE LEN(C3.NDC_CODE) >= 10
                      AND [SUBSCRIBER_ID] = @ClientMemberKey
                      AND [SEQ_CLAIM_ID] = @SeqClaimID
                ORDER BY SEQ_CLAIM_ID
                       , LINE_NUMBER;
    END
