
/*** Create a Stored Procedure to get the ColContents ***/
CREATE PROCEDURE dbo.x_sp_GetDistinctValues
	(	
		@TblTable	VARCHAR(50),
		@ColName		VARCHAR(50)
	)
	AS

	DECLARE @SQL	VARCHAR(MAX)
	DECLARE @t		VARCHAR(MAX)  = @ColName
	SET @SQL = 'SELECT ''' + @t + ''', col, colcnt FROM (SELECT DISTINCT ' + @ColName + ' as col, count(' + @ColName + ') as colcnt FROM ' + @TblTable + ' GROUP BY ' + @ColName + ') a' 
	EXEC (@SQL)
