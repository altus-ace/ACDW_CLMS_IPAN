





CREATE PROCEDURE [adw].[CalcfctTME]
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

	INSERT INTO [adw].[FctTME]
			(
          [SrcFileName]
         ,[LoadDate]
         ,[DataDate]
         ,[EffectiveAsOfDate]
         ,[ClientKey] 
			,[ClientMemberKey] 
			,[AttribNPI]
			,[AttribTIN]
			,[PrimSvcYr] 
			,[PrimSvcMth]
			,[CntClaims] 
			,[TotPaidAmt]
			,[HHAPaidAmt]
         ,[SNFPaidAmt]
         ,[OPPaidAmt]
         ,[HospicePaidAmt]
         ,[IPPaidAmt]
         ,[PhyPaidAmt]
         ,[OtherPaidAmt]
			,[PrefCntClaims] 
			,[PrefTotPaidAmt]
			,[PrefHHAPaidAmt]
         ,[PrefSNFPaidAmt]
         ,[PrefOPPaidAmt]
         ,[PrefHospicePaidAmt]
         ,[PrefIPPaidAmt]
         ,[PrefPhyPaidAmt]
         ,[PrefOtherPaidAmt])
	SELECT  CONCAT('[adw].[2020_tvf_Get_ClaimsTMEByMember]',@KPIStartDate,'-',@KPIEndDate)
			,GETDATE()
			,@RunDate
			,@RunDate
			,a.ClientKey
			,a.ClientMemberKey
			,a.NPI							as AttribNPI
			,a.PcpPracticeTIN				as AttribTIN
			,b.PrimSvcYr
			,b.PrimSvcMth 
			,b.CntClaims
			,b.TotPaidAmt
			,b.HHAPaidAmt
			,b.SNFPaidAmt
			,b.OPPaidAmt
			,b.HospicePaidAmt
			,b.IPPaidAmt
			,b.PhyPaidAmt
			,b.OtherPaidAmt		
			,b.PrefCntClaims
			,b.PrefTotPaidAmt
			,b.PrefHHAPaidAmt
			,b.PrefSNFPaidAmt
			,b.PrefOPPaidAmt
			,b.PrefHospicePaidAmt
			,b.PrefIPPaidAmt
			,b.PrefPhyPaidAmt
			,b.PrefOtherPaidAmt		
	FROM [adw].[2020_tvf_Get_ActiveMembersFull]	(@MbrEffectiveDate) a
	JOIN [adw].[2020_tvf_Get_ClaimsTMEByMember] (@KPIStartDate,@KPIEndDate) b
		ON a.ClientMemberKey = b.ClientMemberKey


END;												

/***
EXEC [adw].[CalcfctTME] 16,'2020-06-15','2019-01-01','2020-03-30','2020-06-15'

SELECT top 100 *
FROM adw.fctTME order by PrimSvcYr desc
***/

