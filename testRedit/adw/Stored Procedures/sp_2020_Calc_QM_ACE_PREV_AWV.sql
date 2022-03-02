





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [adw].[sp_2020_Calc_QM_ACE_PREV_AWV] 
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
			
	--DECLARE @ClientKeyID	Varchar(2) = '20'
	--DECLARE @MeasurementYear INT = 2021
	--DECLARE @CodeEffectiveDate date = '2020-01-01'
	--DECLARE @qmdate date ='2021-07-15'	
	--DECLARE @MbrEffectiveDate DATE = '2021-07-01'
			--Declare Variables
	DECLARE @Metric				Varchar(20)		= 'ACE_PREV_AWV'
	DECLARE @Year				INT			    = Year(Getdate())
	DECLARE @RunDate			Date		    = @QMDATE --Getdate()
	DECLARE @RunTime			Datetime	    = Getdate()
	DECLARE @Today				INT		        = CONVERT(INT, Getdate())
	DECLARE @TodayMth			Int			    = Month(Getdate())
	DECLARE @TodayDay			Int			    = Day(Getdate())
	DECLARE @PrimSvcDate_Start	VarChar(20)	    = CONCAT('01/1/',@MeasurementYear)
	DECLARE @PrimSvcDate_End	Varchar(20)	    = CONCAT('12/31/',@MeasurementYear)
	DECLARE @CodeSetEffDate		Varchar(20)		= @CodeEffectiveDate
	DECLARE @MbrAceEffectiveDate	DATE		= @MbrEffectiveDate
	DECLARE @QmMeasYear CHAR(4) = @MeasurementYear /*Defines the Measurement Year in question*/
	
	
	--during August of prior year to March of the measurement year Eg. August 1st 2019 to March 31st 2020

	DECLARE @TmpTable1 as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					 
	DECLARE @TmpTable2 as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpTable3 as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpDenHeader as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpDenDetail as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpNumHeader as Table	(SUBSCRIBER_ID VarChar(20))					
	DECLARE @TmpNumDetail as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpCOPHeader as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TblResult as Table		(METRIC Varchar(20), SUBSCRIBER_ID VarChar(20),ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date)					
	
	-- TmpTable to store Denominator 
	INSERT INTO		@TmpTable1(SUBSCRIBER_ID)
	SELECT			SUBSCRIBER_ID 
	FROM			[adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions] (@MbrAceEffectiveDate)
	WHERE			AGE >=0
	
	--Inserting Values for DEN with Exclusion
	INSERT INTO		@TmpDenHeader(SUBSCRIBER_ID)
	SELECT DISTINCT	SUBSCRIBER_ID
	FROM			@TmpTable1
	EXCEPT
	SELECT			SUBSCRIBER_ID
	FROM			@TmpTable2	

	-- Clear out tmpTables to reuse
	DELETE FROM		@TmpTable1
	--DELETE FROM		@TmpTable2
	
	-- TmpTable to store Numerator Values
	INSERT INTO		@TmpTable1(SUBSCRIBER_ID,ValueCodeSystem,ValueCode,ValueCodeSvcDate,SEQ_CLAIM_ID, SVC_TO_DATE,SVC_PROV_NPI)
	SELECT DISTINCT SUBSCRIBER_ID, '', AWV_CODE, PRIMARY_SVC_DATE,SEQ_CLAIM_ID, SVC_TO_DATE,SVC_PROV_NPI
	FROM			[adw].[2020_tvf_Get_AWVisits] (@PrimSvcDate_Start,@PrimSvcDate_End,@CodeEffectiveDate) 

	-- Insert into Numerator Header
	INSERT INTO		@TmpNumHeader
	SELECT			a.SUBSCRIBER_ID 
	FROM			@TmpTable1 a 
	INTERSECT    
	SELECT			b.SUBSCRIBER_ID 
	FROM			@TmpDenHeader  b

	-- Insert into Numerator Detail using TmpTable
	INSERT INTO		@TmpNumDetail(SUBSCRIBER_ID, ValueCodeSystem, ValueCode, ValueCodeSvcDate,SEQ_CLAIM_ID, SVC_TO_DATE,SVC_PROV_NPI)
	SELECT DISTINCT a.SUBSCRIBER_ID, a.ValueCodeSystem, a.ValueCode, a.ValueCodeSvcDate,a.SEQ_CLAIM_ID, a.SVC_TO_DATE,a.SVC_PROV_NPI
	FROM			@TmpTable1 a
	INNER JOIN		@TmpDenHeader b
	ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID 
			
	-- Insert into CareOpp Header
	INSERT INTO		@TmpCOPHeader
	SELECT			a.* 
	FROM			@TmpDenHeader a 
	LEFT JOIN		@TmpNumHeader b 
	ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID 
	WHERE			b.SUBSCRIBER_ID IS NULL 
		
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
EXEC [adw].[sp_2020_Calc_QM_ACE_PREV_AWV]	 @ConnectionStringProd	= '[adw].[QM_ResultByMember_History]',
											 @QMDATE				= '2021-07-15',
											 @CodeEffectiveDate		= '2020-01-01',
											 @MeasurementYear		=  2021,
											 @ClientKeyID			=  25,
											 @MbrEffectiveDate		= '2021-07-01'
***/

	
	
