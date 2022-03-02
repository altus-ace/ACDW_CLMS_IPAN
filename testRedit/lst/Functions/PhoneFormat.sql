
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [lst].[PhoneFormat] (@PhoneNum VARCHAR(13))
RETURNS VARCHAR(13)
AS
BEGIN
	
	DECLARE @ResultVar VARCHAR(13)

	BEGIN

	SET @ResultVar = (SELECT '(' + LEFT(@PhoneNum, 3) + ') ' + SUBSTRING(@PhoneNum, 4,3) + '-' + RIGHT(@PhoneNum,4))

	END
	
	RETURN @ResultVar
	
END



