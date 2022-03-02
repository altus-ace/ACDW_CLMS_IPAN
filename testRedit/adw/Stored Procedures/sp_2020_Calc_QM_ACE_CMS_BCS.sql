





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [adw].[sp_2020_Calc_QM_ACE_CMS_BCS] 
	-- Parameters for the stored procedure here
	@ConnectionStringProd		NVarChar(100) = '[adw].[QM_ResultByMember_History]',
	@QMDATE DATE,
	@CodeEffectiveDate DATE,
	@MeasurementYear			INT,
	@ClientKeyID				Varchar(2),
	@MbrEffectiveDate			DATE
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRY 
BEGIN TRAN
		
	--DECLARE @ClientKeyID			Varchar(2) = '25'
	--DECLARE @MeasurementYear INT = 2021
	--DECLARE @CodeEffectiveDate date = '2020-01-01'
	--DECLARE @qmdate date ='2021-07-15'
	--DECLARE @MbrEffectiveDate DATE = '2021-07-01'
	-- Declare Variables
	DECLARE @Metric				Varchar(20)		= 'ACE_HEDIS_ACO_BCS'
	DECLARE @Year				INT			    = Year(Getdate())
	DECLARE @RunDate			Date		    = @QMDATE --Getdate()
	DECLARE @RunTime			Datetime	    = Getdate()
	DECLARE @Today				INT		        = CONVERT(INT, Getdate())
	DECLARE @TodayMth			Int			    = Month(Getdate())
	DECLARE @TodayDay			Int			    = Day(Getdate())
	DECLARE @PrimSvcDate_Start	VarChar(20)	    = CONCAT('01/1/',@MeasurementYear) 
	DECLARE @PrimSvcDate_End	Varchar(20)	    = CONCAT('12/31/',@MeasurementYear)
	DECLARE @CodeSetEffective DATE				= @CodeEffectiveDate
	DECLARE @3AdditionalMnths	VarChar(20)	    = CONCAT('10/1/',@MeasurementYear - 2)
	DECLARE @MbrAceEffectiveDate	DATE		= @MbrEffectiveDate
	DECLARE @QmMeasYear CHAR(4) = @MeasurementYear /*Defines the Measurement Year in question*/
	
		
	DECLARE @TmpTable1 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					 
	DECLARE @TmpTable2 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date, SEQ_CLAIM_ID Varchar(20),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpTable3 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpDenHeader as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpDenDetail as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpNumHeader as Table	(SUBSCRIBER_ID VarChar(20),SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpNumDetail as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpCOPHeader as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TblResult as Table		(METRIC Varchar(20), SUBSCRIBER_ID VarChar(20),ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)	
					
	-- TmpTable to store Denominator 
	INSERT INTO		@TmpTable1(SUBSCRIBER_ID)
	SELECT			DISTINCT a.Subscriber_ID
	FROM			(
	SELECT DISTINCT	SUBSCRIBER_ID 
	FROM			[adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions](@MbrAceEffectiveDate)
	WHERE			AGE BETWEEN 51 AND 74
	AND				GENDER = 'F'
					)a
	JOIN			
					(SELECT SUBSCRIBER_ID,PROCEDURE_CODE FROM adw.Claims_Details
					WHERE PROCEDURE_CODE BETWEEN  '99201' AND '99499' AND SVC_TO_DATE
					BETWEEN @PrimSvcDate_Start AND @PrimSvcDate_End)cpt
	ON				a.SUBSCRIBER_ID = cpt.SUBSCRIBER_ID

	--Generating and Calculating Values for Exclusions
	INSERT INTO		 @TmpTable2(SUBSCRIBER_ID)
	SELECT DISTINCT  a.SUBSCRIBER_ID
    FROM			 [adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions](@MbrAceEffectiveDate) a	 
	JOIN			
					(
						SELECT DISTINCT	o.SUBSCRIBER_ID
						FROM			[adw].[2020_tvf_Get_ClaimsByValueSet]('HEDIS_ACO_Frailty', '',  '','',@PrimSvcDate_Start
										, @PrimSvcDate_End,@CodeSetEffective) o
						JOIN			[adw].[2020_tvf_Get_ClaimsByValueSet]('HEDIS_ACO_Acute Inpatient', 'HEDIS_ACO_Advanced Illness',  'Dementia Medications','',@PrimSvcDate_Start
										, @PrimSvcDate_End,@CodeSetEffective) n
						ON				o.SUBSCRIBER_ID = n.SUBSCRIBER_ID
					)b
	ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
	WHERE			a.AGE >=66
	AND				a.Gender = 'F'
	UNION
	SELECT			DISTINCT c.SUBSCRIBER_ID
	FROM			adw.Claims_Details  c
	JOIN			[adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions](@MbrAceEffectiveDate) e
	ON				c.SUBSCRIBER_ID = e.SUBSCRIBER_ID
	JOIN			adw.Claims_Headers z
	ON				c.SUBSCRIBER_ID=z.SUBSCRIBER_ID
	WHERE			PLACE_OF_SVC_CODE1  IN (32, 33, 34, 54 ,56)
	AND				AGE >=66
	AND				PRIMARY_SVC_DATE BETWEEN @PrimSvcDate_Start AND @PrimSvcDate_End
	

	--Inserting Values for DEN with Exclusion
	INSERT INTO		@TmpDenHeader(SUBSCRIBER_ID)
	SELECT DISTINCT	SUBSCRIBER_ID
	FROM			@TmpTable1
	EXCEPT
	SELECT			SUBSCRIBER_ID
	FROM			@TmpTable2	

	-- Clear out tmpTables to reuse
	DELETE FROM		@TmpTable1
	DELETE FROM		@TmpTable2

	-- Generating Values to store Numerator Values
	INSERT INTO		@TmpTable1(SUBSCRIBER_ID,ValueCodeSystem,ValueCode,ValueCodeSvcDate,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI)
	SELECT DISTINCT SUBSCRIBER_ID, ValueCodeSystem, ValueCode, ValueCodeSvcDate,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI
	FROM			[adw].[2020_tvf_Get_ClaimsByValueSet]('HEDIS_ACO_Mammography','','','',@3AdditionalMnths,@PrimSvcDate_End,@CodeSetEffective)

	-- Insert into Numerator Header 
	INSERT INTO		 @TmpNumHeader(SUBSCRIBER_ID)
	SELECT DISTINCT  a.SUBSCRIBER_ID 
	FROM			 @TmpTable1 a 
	INTERSECT    
	SELECT			 b.SUBSCRIBER_ID 
	FROM			 @TmpDenHeader  b

	-- Insert into Numerator Detail using TmpTable
	INSERT INTO		@TmpNumDetail(SUBSCRIBER_ID, ValueCodeSystem, ValueCode, ValueCodeSvcDate,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI)
	SELECT DISTINCT a.SUBSCRIBER_ID, a.ValueCodeSystem, a.ValueCode, a.ValueCodeSvcDate,a.SEQ_CLAIM_ID,a.SVC_TO_DATE,a.SVC_PROV_NPI 
	FROM			@TmpTable1 a
	INNER JOIN		@TmpDenHeader b
	ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID

	-- Insert into CareOpp Header
	INSERT INTO		@TmpCOPHeader
	SELECT			a.* 
	FROM			@TmpDenHeader a 
	LEFT JOIN		@TmpNumHeader b 
	ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID 
	WHERE			b.SUBSCRIBER_ID is null 
		
	IF				@ConnectionStringProd = @ConnectionStringProd
	BEGIN
	---Insert DEN into Target Table QM Result By Member
	INSERT INTO		[adw].[QM_ResultByMember_History]([ClientKey],[ClientMemberKey],[QmMsrId],[QmCntCat],[QMDate],[CreateDate],[CreateBy], [QmMeasYear],QMMbrEffectiveDate )
	SELECT			DISTINCT @ClientKeyID,SUBSCRIBER_ID, @Metric , 'DEN' ,@QMDATE ,@RUNTIME , SUSER_NAME(), @QmMeasYear, @MbrEffectiveDate 
	FROM			@TmpDenHeader
	---Insert NUM into Target Table QM Result By Member
	INSERT INTO		[adw].[QM_ResultByMember_History]([ClientKey],[ClientMemberKey],[QmMsrId],[QmCntCat],[QMDate],[CreateDate],[CreateBy], [QmMeasYear],QMMbrEffectiveDate )
	SELECT			DISTINCT @ClientKeyID,SUBSCRIBER_ID, @Metric , 'NUM' ,@QMDATE ,@RUNTIME , SUSER_NAME(), @QmMeasYear, @MbrEffectiveDate  
	FROM			@TmpNumHeader
	---Insert COP into Target Table QM Result By Member
	INSERT INTO		[adw].[QM_ResultByMember_History]([ClientKey],[ClientMemberKey],[QmMsrId],[QmCntCat],[QMDate],[CreateDate],[CreateBy], [QmMeasYear],QMMbrEffectiveDate )
	SELECT			DISTINCT @ClientKeyID,SUBSCRIBER_ID, @Metric , 'COP' ,@QMDATE ,@RUNTIME , SUSER_NAME(), @QmMeasYear, @MbrEffectiveDate  
	FROM			@TmpCOPHeader
	INSERT INTO		[adw].[QM_ResultByValueCodeDetails_History](
					[ClientKey], [ClientMemberKey], [ValueCodeSystem],[ValueCode], [ValueCodePrimarySvcDate],[QmMsrID],[QmCntCat],[QMDate],[RunDate]
					,[CreatedBy], [LastUpdatedDate],[LastUpdatedBy]
					,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI, [QmMeasYear],QMMbrEffectiveDate )
	SELECT			DISTINCT @ClientKeyID, SUBSCRIBER_ID,ValueCodeSystem,ValueCode,ValueCodeSvcDate, @Metric ,'NUM',@QMDATE 
					,@RunTime, SUSER_NAME(), GETDATE(), SUSER_NAME() 
					,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI, @QmMeasYear, @MbrEffectiveDate 
	FROM			@TmpNumDetail
	PRINT			'This is a Production Environment'
	END
	ELSE
	
	BEGIN
	PRINT			'ConnectionString Parameter is not Valid, Transaction is incomplete'
	END


COMMIT
END TRY
BEGIN CATCH
EXECUTE [dbo].[usp_QM_Error_handler]
END CATCH

END  

/***
Usage: 
EXEC [adw].[sp_2020_Calc_QM_ACE_CMS_BCS]	 @ConnectionStringProd	= '[adw].[QM_ResultByMember_History]',
											 @QMDATE				= '2021-07-15',
											 @CodeEffectiveDate		= '2020-01-01',
											 @MeasurementYear		= 2021,
											 @ClientKeyID			= 25,
											 @MbrEffectiveDate		= '2021-07-01'
***/



