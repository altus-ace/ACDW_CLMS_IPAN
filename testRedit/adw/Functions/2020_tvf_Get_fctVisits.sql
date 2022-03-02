





CREATE  FUNCTION [adw].[2020_tvf_Get_fctVisits]
(
 @EffectiveAsOfDate	DATE,
 @PrimSvcDate_Start DATE, 
 @PrimSvcDate_End   DATE
)
RETURNS TABLE
AS RETURN
(
SELECT '[adw].[FctEDVisits]'		as TableName
	,FctEDVisitsSkey				as TableKey
	,CreatedDate					as CreatedDate
	,LoadDate						as LoadDate
	,EffectiveAsOfDate				as EffectiveAsOfDate
	,ClientMemberKey				as ClientMemberKey
	,SEQ_ClaimID					as SeqClaimID
	,PrimaryServiceDate				as PrimaryServiceDate
	,VendorID						as VendorID
	,''								as Other
	,ObvFlag						as ObvFlag
	,SurFlag						as SurFlag
	,ERToIPFlag						as ERToIpFlag
FROM [adw].[FctEDVisits]
WHERE [PrimaryServiceDate] BETWEEN	@PrimSvcDate_Start AND @PrimSvcDate_End
AND EffectiveAsOfDate = @EffectiveAsOfDate
--WHERE ClientMemberKey =  @ClientMemberKey
--AND SEQ_ClaimID = @SeqClaimID
UNION
SELECT '[adw].[FctEDToIPVisits]'	as TableName
	,[FctEDToIPVisitskey]			as TableKey
	,CreatedDate					as CreatedDate
	,LoadDate						as LoadDate
	,EffectiveAsOfDate				as EffectiveAsOfDate
	,ClientMemberKey				as ClientMemberKey
	,[ClaimID_ER]					as SeqClaimID
	,[PrimSvcDate_ER]				as PrimaryServiceDate
	,''								as VendorID
	,CONCAT('IP:',[ClaimID_IP])		as Other
	,''						as ObvFlag
	,''						as SurFlag
	,''						as ERToIpFlag

FROM [adw].[FctEDToIPVisits]
WHERE [PrimSvcDate_ER] BETWEEN	@PrimSvcDate_Start AND @PrimSvcDate_End
AND EffectiveAsOfDate = @EffectiveAsOfDate
--WHERE ClientMemberKey =  @ClientMemberKey
--AND [ClaimID_ER] = @SeqClaimID
UNION
SELECT '[adw].[FctInpatientVisits]'	as TableName
	,[FctInpatientVisitsSkey]			as TableKey
	,CreatedDate					as CreatedDate
	,LoadDate						as LoadDate
	,EffectiveAsOfDate				as EffectiveAsOfDate
	,[ClientMemberKey]				as ClientMemberKey
	,[SEQ_ClaimID]					as SeqClaimID
	,[PrimaryServiceDate]			as PrimaryServiceDate
	,''								as VendorID
	,CONCAT('InstTypeERToIPObv:',[InstType],'|',[ERToIPFlag],'|',[ObvFlag])		as Other
	,ObvFlag						as ObvFlag
	,SurFlag						as SurFlag
	,ERToIPFlag						as ERToIpFlag

FROM [adw].[FctInpatientVisits]
WHERE [PrimaryServiceDate] BETWEEN	@PrimSvcDate_Start AND @PrimSvcDate_End
AND EffectiveAsOfDate = @EffectiveAsOfDate
--WHERE ClientMemberKey =  @ClientMemberKey
--AND [SEQ_ClaimID] = @SeqClaimID
UNION
SELECT '[adw].[FctOutpatientVisits]'	as TableName
	,[FctOutpatientVisitskey]			as TableKey
	,CreatedDate					as CreatedDate
	,LoadDate						as LoadDate
	,EffectiveAsOfDate				as EffectiveAsOfDate
	,[ClientMemberKey]				as ClientMemberKey
	,[SEQ_ClaimID]					as SeqClaimID
	,[PrimaryServiceDate]			as PrimaryServiceDate
	,''								as VendorID
	,''								as Other
	,''						as ObvFlag
	,SurFlag						as SurFlag
	,''						as ERToIpFlag

FROM [adw].[FctOutpatientVisits]
WHERE [PrimaryServiceDate] BETWEEN	@PrimSvcDate_Start AND @PrimSvcDate_End
AND EffectiveAsOfDate = @EffectiveAsOfDate
--WHERE ClientMemberKey =  @ClientMemberKey
--AND [SEQ_ClaimID] = @SeqClaimID

)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_fctVisits] ('08-15-2020','01-01-2020','03-31-2020')
ORDER BY TableName, EffectiveAsOfDate, PrimaryServiceDate
***/

