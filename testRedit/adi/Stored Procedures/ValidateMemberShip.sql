


CREATE PROCEDURE [adi].[ValidateMemberShip]

AS


		SELECT   COUNT(*)RecCnt, LoadDate
				,DataDate,RowStatus
		FROM	 adi.[Attribution]
		GROUP BY DataDate
				 ,LoadDate,RowStatus
		ORDER BY DataDate DESC 

		

		SELECT		DISTINCT BMNPI,NPI,CurrentMBI --- * -- 16442
		FROM		[adi].[Attribution] adi
		LEFT JOIN	[adw].[tvf_AllClient_ProviderRoster](25,GETDATE(),1) pr
		ON			adi.BMNPI = pr.NPI
		

		SELECT		COUNT(DISTINCT CurrentMBI)TotalToBeProcessedIntoAdw
		FROM		[adi].[Attribution] adi
		LEFT JOIN	[adw].[tvf_AllClient_ProviderRoster](25,GETDATE(),1) pr
		ON			adi.BMNPI = pr.NPI
		WHERE		pr.NPI IS NOT  NULL	
		
	/*
	SELECT	 stgRowStatus
			,MbrFlgCount
			,MbrNPIFlg
			,MbrPlnFlg
			,prvNPI
			,prvTIN
			,srcTIN
			,Active
			,Excluded
			,MbrDOD
			,DataDate
			,srcNPI,srcPln,mbrGENDER ,* -- SELECT DISTINCT prvNPI 
	FROM	 ast.mbrstg2_mbrdata    
	WHERE	 LoadDate = '2021-07-01' --- AND ACTIVE = 1
	AND		stgRowStatus = 'Exported'
	AND PRVNPI = '1111111111'

	SELECT	stgRowStatus,*
	FROM	[ast].[MbrStg2_PhoneAddEmail] 
	WHERE	LoadDate = '2021-07-01'
	AND		stgRowStatus = 'Exported'

	SELECT	*
	FROM	adw.FailedMembership
	Where	effectiveDate = '2022-02-01'
	*/
	
	/*
		SELECT COUNT(*) FROM ast.MbrStg2_MbrData
		SELECT COUNT(*) FROM ast.MbrStg2_PhoneAddEmail
		SELECT COUNT(*) FROM adw.MbrLoadHistory 
		SELECT COUNT(*) FROM adw.MbrMember 
		SELECT COUNT(*) FROM adw.MbrDemographic 
		SELECT COUNT(*) FROM adw.MbrAddress
		SELECT COUNT(*) FROM adw.mbrCsPlan 
		SELECT COUNT(*) FROM adw.MbrEmail  
		SELECT COUNT(*) FROM adw.MbrPcp 
		SELECT COUNT(*) FROM adw.MbrPhone  
		SELECT COUNT(*) FROM adw.MbrPlan 
		SELECT * FROM adw.FailedMembership
		SELECT COUNT(*) FROM ast.FctMembership
		SELECT COUNT(*) FROM adw.FctMembership_Dev
		SELECT COUNT(*) FROM adw.FctMembership
		SELECT * FROM ACECAREDW.dbo.tmpAllMemberMonths WHERE ClientKey = 25

		*/

		
		
	 