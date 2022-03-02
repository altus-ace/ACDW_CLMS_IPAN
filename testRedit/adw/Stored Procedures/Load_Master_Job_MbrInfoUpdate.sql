

	
CREATE PROCEDURE		[adw].[Load_Master_Job_MbrInfoUpdate](@DataDate Date)

AS


BEGIN
		EXECUTE  adi.ExtractMemberInfoFrmAHS
END


BEGIN
	
		EXECUTE [ast].[pls_MbrPcpNpiInfo] @DataDate
END


BEGIN

		EXECUTE ast.pts_UpdateMPI
END


BEGIN

		EXECUTE [adw].[pdw_MbrPcpUpdateFrmAHS] @DataDate
END


BEGIN
	
		EXECUTE adw.pdw_UpdateMbrInfoStg
END

/*
--Turn on when Si instructs. Revisit Code
BEGIN
EXECUTE adw.pdw_UpdateFctMembershipInfoDatafrmAHS
END
*/

