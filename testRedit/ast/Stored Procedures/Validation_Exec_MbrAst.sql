

CREATE PROCEDURE [ast].[Validation_Exec_MbrAst] (
	@ClientKey INT )
AS
BEGIN
	--DECLARE @Clientkey INT = 16;
	EXEC [Dev_TestDeploy].amd.[Validation_Exec_MbrAst] @clientkey 
END;
