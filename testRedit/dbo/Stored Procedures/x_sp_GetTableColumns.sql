
/*** Alter or Create a Stored Procedure to get the Table and Columns ***/
CREATE PROCEDURE [dbo].[x_sp_GetTableColumns] (@InputTableName VARCHAR(50), @ColValLimit INT)
	AS
	DECLARE @table_name VARCHAR(55)

	SET @table_name = @InputTableName ---- <-- Change this to your table name
	CREATE TABLE #colcount (
		ColName			VARCHAR(55)
		,DistinctValue	INT
		,TotalValue		INT
		)
	CREATE TABLE #colContent (
		ColName			VARCHAR(55)
		,ColVal			NVARCHAR(max)
		,ColValCount	INT
		)
	CREATE TABLE #sqlexecs (s VARCHAR(max))
	--IF OBJECT_ID(N'dbo.x_AnalyzeTableOutput', N'U') IS NOT NULL  DROP TABLE dbo.x_AnalyzeTableOutput
	--CREATE TABLE dbo.x_AnalyzeTableOutput (
	--	URN				INT IDENTITY
	--	,BatchID			VARCHAR(40) DEFAULT FORMAT (getdate(), 'yyyyMMdd-hhmm')
	--	,TableName		VARCHAR(55)
	--	,ColName			VARCHAR(55)
	--	,DistinctValue	VARCHAR(55)
	--	,ValueCnt		INT
	--	,CreatedDate	DATETIME		DEFAULT getdate()
	--	,CreatedBy		VARCHAR(55) DEFAULT 'dbo.x_sp_GetTableColumns'
	--	)

	DECLARE @col_name	VARCHAR(max)
		,@sql				NVARCHAR(max)
		,@sql2			NVARCHAR(max)
		,@sql3			NVARCHAR(max)
		,@colname		VARCHAR(max)
		,@vallimit		INT					= @ColValLimit

	DECLARE c CURSOR
	FOR

	SELECT name
	FROM sys.columns
	WHERE [object_id] = object_id(@table_name)

	OPEN c

	FETCH NEXT
	FROM c
	INTO @col_name

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @sql = 'select cn.name, count(distinct ' + @col_name + ') as dct_numrow, count(' + @col_name + ') as tot_numrow from ' + @table_name + ' join (select name from sys.columns where name = ''' + @col_name + ''' and [object_id]=object_id(''' + @table_name + ''')) cn on cn.name = ''' + @col_name + ''' group by cn.name'

		INSERT INTO #sqlexecs
		VALUES (@sql) --uncomment to  view sql selects produced by @sql

		INSERT INTO #colcount
		EXECUTE sp_executesql @sql

		DECLARE @d INT
			,@t INT

		SET @d = (
				SELECT DistinctValue
				FROM #colcount
				WHERE colname = @col_name
				)
		SET @t = (
				SELECT TotalValue
				FROM #colcount
				WHERE colname = @col_name
				)

		IF (@d < @vallimit)
		BEGIN
			INSERT INTO #colContent (colname,ColVal,ColValCount)
			EXEC dbo.x_sp_GetDistinctValues @table_name,@col_name
 
		END
		ELSE
		BEGIN
			INSERT INTO #colContent
			VALUES (@col_name,1,1)
		END

		FETCH NEXT
		FROM c
		INTO @col_name
	END

	CLOSE c
	DEALLOCATE c

--SELECT * FROM #colcount 
--SELECT * FROM #colContent
INSERT INTO dbo.x_AnalyzeTableOutput (TableName, ColName, DistinctValue, ValueCnt)
	SELECT @table_name, ColName, ColVal, ColValCount FROM #colContent

DROP TABLE #colcount																			-- Comment out to view results
DROP TABLE #colContent																		-- Comment out to view results
DROP TABLE #sqlexecs																			-- Comment out to view results

--DROP PROCEDURE dbo.x_sp_GetDistinctValues
--DROP PROCEDURE dbo.x_sp_GetTableColumns

/***
EXEC dbo.x_sp_AnalyzeTable												-- Creates 2 other sp to use
EXEC dbo.x_sp_GetTableColumns	'adw.Claims_Headers',50			-- Generate results, choose table and ColValue limits

SELECT * FROM dbo.x_AnalyzeTableOutput
	WHERE ColName IN ('PROCEDURE_CODE','REVENUE_CODE','MODIFIER_CODE_1','PLACE_OF_SVC_CODE1','NDC_CODE'
							,'CATEGORY_OF_SVC','CMS_CertificationNumber','PROV_TYPE','IRS_TAX_ID','BILL_TYPE','ADMIT_SOURCE_CODE','CLAIM_TYPE','DISCHARGE_DISPO')				

DROP PROCEDURE [dbo].[x_sp_AnalyzeTable]
DROP PROCEDURE [dbo].[x_sp_GetDistinctValues]
DROP PROCEDURE [dbo].[x_sp_GetTableColumns]

***/

