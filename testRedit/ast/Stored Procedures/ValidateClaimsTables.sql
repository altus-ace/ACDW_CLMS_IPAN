-- Exec [ast].[ValidateClaimsTables] 
CREATE PROCEDURE [ast].[ValidateClaimsTables] 
AS 
BEGIN
   -- CREATE TABLE #ClaimsValidationCounts(skey INT IDENTITY(1,1) PRIMARY KEY
	--   , [ValidationType] VARCHAR(20)
	--   , cnt INT
	--   , PrimarySvcYear INT
	--   , CatOfSvc VARCHAR(20) DEFAULT('ALL')
	--   );
   --
    IF OBJECT_ID(N'tempdb..#TestResults') IS NOT NULL
		DROP TABLE #TestResults;
	CREATE TABLE #TestResults (skey INT NOT NULL IDENTITY(1,1) PRIMARY KEY, Test VARCHAR(30) , TestResult INT, LoadDate DATE,   SrcClaimType VARCHAR(20), SrcAdiKey Varchar(50), AsOfDate Date);
	
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcClaimType, AsOfDate)
	SELECT 'ast.Hdr_01' [Test] , COUNT(*) TestResult, d.LoadDate, d.SrcClaimType, GETDATE()
	FROM  ast.Claim_01_Header_Dedup d 
	GROUP BY d.LoadDate, d.SrcClaimType;
	
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcClaimType, AsOfDate)
	SELECT 'ast.Hdr_02 ' [Test] , COUNT(*) TestResult, d.LoadDate, d.SrcClaimType, GETDATE()
	FROM  ast.Claim_02_HeaderSuperKey d
	GROUP BY d.LoadDate, d.srcClaimType;
	
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcClaimType, AsOfDate)
	SELECT 'ast.Hdr_03' [Test] , COUNT(*) TestResult, GETDATE() LoadDate, d.SrcClaimType, GETDATE()
	FROM  ast.Claim_03_Header_LatestEffective d
	GROUP BY d.SrcClaimType;
	
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcClaimType, AsOfDate)
	SELECT 'ast.Dtl_04' [Test] , COUNT(*) TestResult, GETDATE() LoadDate, d.SrcClaimType, GETDATE()
	FROM  ast.Claim_04_Detail_Dedup d
	GROUP BY d.SrcClaimType;
	
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcClaimType, AsOfDate)
	SELECT 'ast.Prc_05' [Test] , COUNT(*) TestResult, GETDATE() LoadDate, d.SrcClaimType, GETDATE()
	FROM  ast.Claim_05_Procs_Dedup d
	GROUP BY d.SrcClaimType;
	
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcClaimType, AsOfDate)
	SELECT 'ast.Dia_06' [Test] , COUNT(*) TestResult, GETDATE() LoadDate, d.SrcClaimType, GETDATE()
	FROM  ast.Claim_06_Diag_Dedup d
	group by d.SrcClaimType;

	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcClaimType, AsOfDate)
	SELECT 'ast.pstProf_07' [Test] , COUNT(*) TestResult, GETDATE() LoadDate, 'PROF' AS SrcClaimType, GETDATE()
	FROM  ast.pstcDeDupClms_Cclf5 d
	;
	
	/* CLIAIMS STAGING TABLE TEST CASES: CARDINALITY TESTS */
	-- test, result, Loaddate, srcClaimType, 
	/* 01 has a cardinality of 1 */
	--SELECT 'Staging Table Cardinality Test, any rows that are returned, failed and the data in the table violates the cardinality requirement.' as TEST;
	
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcAdiKey, SrcClaimType, AsOfDate)
	SELECT	'01 ClmHdr CardinalityTest' Test, COUNT(*)  TestResult,  getdate(), hd.SrcAdiKey,  hd.SrcClaimType , GETDATE()
	FROM  ast.Claim_01_Header_Dedup hd 
	GROUP BY hd.SrcAdiKey, hd.SrcClaimType having COUNT(*) > 1			;
	
	/* 03 should have a cardinality of 1, any that do not are SHOW STOPPER */
	
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcAdiKey, SrcClaimType, AsOfDate)
	SELECT '03 LtstClm CardinalityTest' TEST , COUNT(*) TestResult, GETDATE() LOADDATE, le.LatestClaimAdiKey srcAdiKey, le.SrcClaimType, GETDATE() ASOFDate
	FROM  ast.Claim_03_Header_LatestEffective le 
	where le.LatestClaimAdiKey = 0
	group by le.LatestClaimAdiKey, le.SrcClaimType having COUNT(*) > 1;
	
	/* 04 should ahve a cardinality of 1 */
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcAdiKey, SrcClaimType, AsOfDate)
	SELECT 'AstDtls CardinalityTest' Test , COUNT(*), GETDATE() LoadDate, d.ClaimSeqClaimId + ' ' + convert(varchar(3) , d.ClaimDetailLineNumber) , d.SrcClaimType, GETDATE() ASOfDate
	FROM  ast.Claim_04_Detail_Dedup d	
	GROUP BY d.ClaimSeqClaimId, d.SrcClaimType, d.ClaimDetailLineNumber  HAVING COUNT(*)>1;
	
	/* 06 procs */
	
	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcAdiKey, SrcClaimType, AsOfDate)
	SELECT 'AstPrcs CardinalityTest' Test , COUNT(*) , GETDATE(),  cOnvert(varchar(20), p.ProcAdiKey) + ' ' + convert(varchar(4), p.ProcNumber), p.SrcClaimType, getdate() asOfDate
		FROM  ast.Claim_05_Procs_Dedup	p	
		GROUP BY p.ProcAdiKey, p.ProcNumber, p.SrcClaimType
		HAVING COUNT(*)>1;

	INSERT INTO #TestResults(Test, TestResult, LoadDate, SrcAdiKey, SrcClaimType, AsOfDate)
	SELECT 'AStDiags CardinalityTest' Test, COUNT(*),GETDATE(),  CONVERT(VARCHAR(20), d.DiagAdiKey) + ' ' + CONVERT(VARCHAR(4), d.DiagNum), d.SrcClaimType, getdate() asOfDate
		FROM  ast.Claim_06_Diag_Dedup	d	
			GROUP BY d.DiagAdiKey, d.SrcClaimType,d.DiagNum HAVING COUNT(*)>1;

	--- produce a list of some composition and cardinality
	DECLARE @SPName VARCHAR(40) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
	SELECT @SPName + ' ' + 'Summary' AS [Type], t.test, COUNT(*)
	FROM #TestResults t
	GROUP BY t.Test
	ORDER BY t.Test
	
	SELECT @SPName + ' ' + 'Details' [Type],*
	FROM #TestResults t
END;