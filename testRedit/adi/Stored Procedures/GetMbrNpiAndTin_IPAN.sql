





-- =============================================
-- Author:		Brit Akhile
-- Create date: 2021/05/11
-- Using the new latest version of provider roster, Select Valid Npis
--, Npi and Tins and assign Tins to Npis with invalid Tins
/*
	Step 1: Declare a table variable
	Step 2: Check to see if these NPIs exist in our roster 
			(Note that after the left join, if it still remains Null, then NPI does not exist in our roster
			, ie (Might not be in our contract))
	Step 3: Assign the TIN to NPIs that exist
	Step 4: Update AttribTIN from the roster
*/
-- =============================================

CREATE PROCEDURE [adi].[GetMbrNpiAndTin_IPAN] (@LoadDate DATE, @RowStatus INT,@ClientKey INT) -- [adi].[GetMbrNpiAndTin_IPAN]'2022-02-01',0,25

AS
					-- DECLARE @LoadDate DATE = '2022-02-01' DECLARE @RowStatus INT = 0 DECLARE @ClientKey INT = 25
					IF OBJECT_ID('tempdb..#Pr') IS NOT NULL DROP TABLE #Pr
					CREATE TABLE #Pr(NPI VARCHAR(50),ClientNPI VARCHAR(50),AttribTIN VARCHAR(50)
									,ClientTIN VARCHAR(50),MemberID VARCHAR(50)  )
									-- DECLARE @LoadDate DATE = '2021-12-08' DECLARE @RowStatus INT = 0 DECLARE @ClientKey INT = 25
					INSERT INTO #Pr(NPI,AttribTIN,ClientNPI,ClientTIN,MemberID) 
					SELECT	pr.NPI
							,pr.AttribTIN
							,src.BMNPI						AS	ClientNPI
							,src.srcTIN								AS	ClientTIN 
							,src.CurrentMBI 
					FROM		(SELECT		DISTINCT src.CurrentMBI
											,src.BMNPI
											,src.BMTIN AS srcTIN
											--  select * ---MAX(DataDate)
								 FROM		[adi].[Attribution] src -- 
								 WHERE		src.LoadDate =  @LoadDate -- 2021-03-13
								 AND		src.RowStatus =  0
								) src
					LEFT JOIN	(SELECT * 
								 FROM (
									SELECT NPI,AttribTIN,ROW_NUMBER()OVER(PARTITION BY NPI ORDER BY NPI) RwCnt
									FROM adw.tvf_AllClient_ProviderRoster (@ClientKey, @LoadDate,1)
												)src
								 WHERE	RwCnt = 1
								)pr
					ON			pr.NPI = src.BMNPI 
										
					
					/*Step 4. Update AttribTIN from the roster */
					
					UPDATE		#Pr
					SET			NPI = (CASE WHEN Toasg.ClientNPI = Toasg.prNPI THEN Toasg.ClientNPI END)
								, AttribTIN = (CASE WHEN Toasg.ClientTIN <> Toasg.prTIN THEN Toasg.prTIN  END)
					FROM		#Pr pr  --  SELECT * FROM #PR pr
					JOIN		(  ---  SELECT * FROM (
							--Step 2 
								--Step 3 
									SELECT		*
									FROM		(
												 SELECT	NPI,AttribTIN,ClientNPI,ClientTIN
												 FROM	#Pr 
												 WHERE	NPI IS NULL
												)noMatch
									LEFT JOIN	(SELECT		NPI AS prNPI,AttribTIN AS prTIN
												 FROM		ACECAREDW.[adw].[tvf_AllClient_ProviderRoster_TinRank](@ClientKey,@LoadDate,1) 
												 ) a
									ON			noMatch.ClientNPI = prNPI
							)Toasg
					ON		pr.ClientNPI= Toasg.prNPI 
					
					
					SELECT	*
					FROM	#Pr
					

					
