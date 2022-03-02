

CREATE PROCEDURE [adw].[sp_Update_Users]
	-- Add the parameters for the stored procedure here
	 @Username	VARCHAR(50)
	,@Password		VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE adw.Users 
	SET Password  = @Password,LastPasswordModifiedTime = CURRENT_TIMESTAMP
	WHERE Username  = @Username
					 

END
