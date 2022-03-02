



CREATE PROCEDURE	[adw].[Load_MasterJob_QM_Addressed]
					(@QMDate DATE
					, @ClientID INT
					,@srcQMDATE DATE
					, @trgQMDATE DATE
					,@LoadDateAthena DATE
					, @LoadDateAthena_AWV DATE
					,@LoadDate DATE)

AS

		--BEGIN
		--	EXECUTE [ast].[pls_QM_Addressed]@QMDate,@LoadDate, @ClientID
		--END

		BEGIN
			EXECUTE [ast].[pls_QM_Addressed_AWV]@QMDate,@LoadDate, @ClientID
		END

		BEGIN
			EXECUTE [ast].[pls_QM_Addressed]@QMDate,@LoadDate, @ClientID
		END

		BEGIN
			EXECUTE [adw].[pdw_QM_Addressed]@QMDate , @ClientID 
		END

		
		BEGIN
			EXECUTE [adw].[pupd_QM_Addressed]@srcQMDATE,@trgQMDATE
		END

		BEGIN
			EXECUTE adw.plAthenaEMRAddressesInto_QMDetails @QMDate
		END

		
