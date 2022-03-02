


CREATE PROCEDURE [ast].[stg_05_PupdAllLineageRowsInAdiAndStg](@DataDate DATE) --  [adw].[PupdAllLineageRowsInAdiAndStg]'2021-04-15'

AS

BEGIN
BEGIN TRAN
BEGIN TRY

		/*	Will update when we have continuous data
	BEGIN
		
	END
	*/

COMMIT
END TRY
BEGIN CATCH
EXECUTE [adw].[usp_MPI_Error_handler]
END CATCH









END
