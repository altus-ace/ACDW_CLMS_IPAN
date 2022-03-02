






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [adw].[sp_2020_Calc_QM_ACE_CMS_TSC] 
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
			--Declare Variables
	DECLARE @Metric				Varchar(20)		= 'ACE_ACO_TSC'
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
	
	


	DECLARE @TmpTable1 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					 
	DECLARE @TmpTable2 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpTable3 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpDenHeader as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpDenDetail as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpNumHeader as Table	(SUBSCRIBER_ID VarChar(20),SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpNumDetail as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpCOPHeader as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TblResult as Table		(METRIC Varchar(20), SUBSCRIBER_ID VarChar(20),ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	
	-- TmpTable to store Denominator 
	INSERT INTO		@TmpTable1(SUBSCRIBER_ID)
	SELECT			DISTINCT  a.SUBSCRIBER_ID 
	FROM			(	SELECT		SUBSCRIBER_ID ,AGE
						FROM	[adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions] (@MbrAceEffectiveDate) 
					)a
	JOIN			(	--Getting members with at least 2 physician visits
						SELECT	* 
						FROM	(
										SELECT		 COUNT(*)RecCnt, SEQ_CLAIM_ID, SUBSCRIBER_ID, PROCEDURE_CODE
										FROM		 adw.Claims_Details 
										WHERE		 PROCEDURE_CODE between '99201' AND '99499'
										GROUP BY	 SEQ_CLAIM_ID,SUBSCRIBER_ID,PROCEDURE_CODE
										HAVING       COUNT(*)>=2 
								)e
						WHERE	PROCEDURE_CODE NOT BETWEEN '99381' AND '99397'

					)b
	ON					a.Subscriber_id = b.SUBSCRIBER_ID
		--Getting members with at least one preventive visits
	UNION			SELECT a.SUBSCRIBER_ID
	FROM
					(		SELECT			DISTINCT SUBSCRIBER_ID,0 Age
							FROM			adw.Claims_Details 
							WHERE			PROCEDURE_CODE
							IN				('G0438','GO439','G0402','99381','99382','99383','99384','99385','99386','99387','99388',
											'99389','99390','99391','99392','99393','99394','99395','99396','99397'
											)
					)a
	JOIN			(		SELECT		SUBSCRIBER_ID ,AGE
							FROM		[adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions] (@MbrAceEffectiveDate) 
					)b
				
	ON				a.Subscriber_id = b.SUBSCRIBER_ID
	WHERE			b.AGE >18 

	--Generating and Calculating Values for Exclusions
	INSERT INTO		@TmpTable2(SUBSCRIBER_ID)
	SELECT DISTINCT a.Subscriber_ID
	FROM			adw.[2020_tvf_Get_ClaimsByValueSet]('Hospice Intervention','Hospice encounter','','',@MeasurementYear,@PrimSvcDate_End,@CodesetEffDate)a
	
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

	-- Generate Numerator Values
	INSERT INTO		@TmpTable1(SUBSCRIBER_ID,ValueCodeSystem,ValueCode,ValueCodeSvcDate,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI)
	SELECT DISTINCT SUBSCRIBER_ID, ValueCodeSystem, ValueCode, ValueCodeSvcDate,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI
	FROM			[adw].[2020_tvf_Get_ClaimsByValueSet]('ACO_TSC_TobaccoScreeningCessation','',''
					,'',@PrimSvcDate_Start,@PrimSvcDate_End,@CodeSetEffDate) 
	UNION		
	SELECT			DISTINCT a.SUBSCRIBER_ID,'',diagCodeWithoutDot,PRIMARY_SVC_DATE,b.SEQ_CLAIM_ID,PRIMARY_SVC_DATE,a.SVC_PROV_NPI
	FROM			adw.Claims_Headers a
	JOIN			adw.Claims_Diags b
	ON				a.SUBSCRIBER_ID=b.SUBSCRIBER_ID
	WHERE			a.PRIMARY_SVC_DATE > (SELECT DATEADD(YEAR,-2,CONVERT(DATE,GETDATE())))
	AND			    diagCodeWithoutDot BETWEEN 'F17200' AND 'F17290' 

	--Inserting Values for Numerator Header 
	INSERT INTO		 @TmpNumHeader(SUBSCRIBER_ID)
	SELECT			 a.SUBSCRIBER_ID 
	FROM			 @TmpTable1 a 
	INTERSECT    
	SELECT			 b.SUBSCRIBER_ID 
	FROM			 @TmpDenHeader  b

	
	-- Insert into Numerator Detail 
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
EXEC [adw].[sp_2020_Calc_QM_ACE_CMS_TSC]	 @ConnectionStringProd	= '[adw].[QM_ResultByMember_History]',
											 @QMDATE				= '2021-07-15',
											 @CodeEffectiveDate		= '2020-01-01',
											 @MeasurementYear		= 2021,
											 @ClientKeyID			= 25,
											 @MbrEffectiveDate		= '2021-07-01'
***/

