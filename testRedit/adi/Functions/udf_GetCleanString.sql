
CREATE FUNCTION [adi].[udf_GetCleanString] 
(
	@StringToClean as varchar(8000)
)
RETURNS varchar(8000)
AS
BEGIN	
	--Replace all non printing whitespace characers with Characer 32 whitespace
	--NULL
	Set @StringToClean = Replace(@StringToClean,CHAR(0),CHAR(32));
	--Horizontal Tab
	Set @StringToClean = Replace(@StringToClean,CHAR(9),CHAR(32));
	--Line Feed
	Set @StringToClean = Replace(@StringToClean,CHAR(10),CHAR(32));
	--Vertical Tab
	Set @StringToClean = Replace(@StringToClean,CHAR(11),CHAR(32));
	--Form Feed
	Set @StringToClean = Replace(@StringToClean,CHAR(12),CHAR(32));
	--Carriage Return
	Set @StringToClean = Replace(@StringToClean,CHAR(13),CHAR(32));
	--Column Break
	Set @StringToClean = Replace(@StringToClean,CHAR(14),CHAR(32));
	--Non-breaking space
	Set @StringToClean = Replace(@StringToClean,CHAR(160),CHAR(32));
	-- remove pipeline
	Set @StringToClean = replace(@StringToClean, CHAR(124), CHAR(32));

	Set @StringToClean = LTRIM(RTRIM(@StringToClean));
	Return @StringToClean
END
