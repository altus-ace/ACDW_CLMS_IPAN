


CREATE PROCEDURE [ast].[pupdateForDataDates]

AS
/*Updating DataDate for FctMembership.*/
		/*
		UPDATE	adw.FctMembership
		SET		DataDate = '2022-02-01' --- SELECT DISTINCT MBRYEAR, MBRMONTH, DATADATE FROM adw.FctMembership
		WHERE	MbrYear = YEAR(GETDATE())
		AND		DataDate =(SELECT MAX(DataDate) FROM adw.FctMembership)
		*/

		/*Update Active Flag*/
		BEGIN
		---- SELECT	ClientMemberKey,ast.ClientSubscriberId,ast.Active,adw.Active,ast.Excluded,adw.Excluded
		UPDATE	adw.FctMembership
		SET		Active = ast.Active
				,Excluded = ast.Excluded
		FROM	adw.FctMembership adw
		JOIN	ast.MbrStg2_MbrData ast
		ON		adw.ClientMemberKey = ast.ClientSubscriberId
		AND		adw.RwEffectiveDate = ast.EffectiveDate
		END


		/*Transform DOD Field Where its Null*/
		UPDATE adw.FctMembership
		SET		DOD = '1900-01-01'
		WHERE	DOD IS NULL

		