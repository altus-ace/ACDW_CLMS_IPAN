



/*************************************************
CREATED BY : HARI SHARMA ON MAR 30, 2007
PURPOSE : TO CONVERT INPUT STRING IN CAMEL CASE
**************************************************/
CREATE FUNCTION [adi].[udf_ConvertToCamelCase]
(@Str varchar(8000))
RETURNS varchar(8000) AS
BEGIN
  DECLARE @Result varchar(2000)
  SET @Str = LOWER(@Str) + ' '
  SET @Result = ''
  WHILE 1=1
  BEGIN
    IF PATINDEX('% %',@Str) = 0 BREAK
    SET @Result = @Result + UPPER(Left(@Str,1))+
    SubString  (@Str,2,CharIndex(' ',@Str)-1)
    SET @Str = SubString(@Str,
      CharIndex(' ',@Str)+1,Len(@Str))
  END
  SET @Result = Left(@Result,Len(@Result))
  RETURN @Result
END
/***
SELECT [adi].[udf_ConvertToCamelCase]('AAA, BBB')
***/
