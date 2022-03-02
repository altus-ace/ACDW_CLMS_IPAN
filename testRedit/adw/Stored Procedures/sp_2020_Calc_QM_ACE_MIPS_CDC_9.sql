





---- =============================================
---- Author:		<Author,,Name>
---- Create date: <Create Date,,>
---- Description:	<Description,,>
---- =============================================
CREATE PROCEDURE [adw].[sp_2020_Calc_QM_ACE_MIPS_CDC_9] 
--	-- Parameters for the stored procedure here
	@ConnectionStringProd		NVarChar(100) = '[adw].[QM_ResultByMember_History]', 
	@QMDATE						DATE,
	@CodeEffectiveDate			DATE,
	@MeasurementYear			INT,
	@ClientKeyID				Varchar(2),
	@MbrEffectiveDate			DATE
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRY 
BEGIN TRAN
									
		--DECLARE @ClientKeyID			Varchar(2) = '16'
		--DECLARE @MeasurementYear INT = 2021
		--DECLARE @CodeEffectiveDate date = '2021-01-01'
		--DECLARE @qmdate date ='2022-02-15'
		--DECLARE @MbrEffectiveDate DATE = '2021-12-01'
	-- Declare Variables
	DECLARE @Metric					Varchar(20)	   = 'ACE_MIPS_CDC_9'
	DECLARE @RunDate				Date		   = @QMDATE --Getdate()
	DECLARE @RunTime				Datetime	   = Getdate()
	DECLARE @Today					Date		   = Getdate()
	DECLARE @TodayMth				Int			   = Month(Getdate())
	DECLARE @TodayDay				Int			   = Day(Getdate())
	DECLARE @Year					INT			   = Year(Getdate())
	DECLARE @StartDatePriorToMeasurementYear Date	= CONCAT('01/1/', @MeasurementYear - 1)
	DECLARE @PrimSvcDate_Start	VarChar(20)			=CONCAT('01/1/',@MeasurementYear)
	DECLARE @PrimSvcDate_End	Varchar(20)			= CONCAT('12/31/',@MeasurementYear)
	DECLARE @CodeSetEffective		VARCHAR(20)    = @CodeEffectiveDate
	DECLARE @MbrAceEffectiveDate	DATE		= @MbrEffectiveDate
	DECLARE @DateAsAtMeasurementYear Date  = CONCAT('1/1/', @MeasurementYear)
	DECLARE @StartDateOfMeasurementYear Date  = CONCAT('1/1/', @MeasurementYear)
	DECLARE @QmMeasYear CHAR(4) = @MeasurementYear /*Defines the Measurement Year in question*/


	DECLARE @TmpTable1		as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					 
	DECLARE @TmpTable2		as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpTable3		as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))	
	DECLARE @TmpTable4		as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))
	DECLARE @TmpTable5		as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))	
	DECLARE @TmpDenHeader	as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpNumHeader	as Table	(SUBSCRIBER_ID VarChar(20),SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)																		   
	DECLARE @TmpNumDetail	as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpCOPHeader	as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)	
	DECLARE @TmpDenDetail	as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)
	


--	---Calculating for Metrics for 'CDC_9' Measure
--	-- TmpTable to Calculate Headers and Details Denominator Values
--	--Calculating for Headers Denominator 
	INSERT INTO		 @TmpTable1(SUBSCRIBER_ID)--, ValueCodeSystem , ValueCode , ValueCodeSvcDate)
    SELECT DISTINCT  a.SUBSCRIBER_ID--,'0','0','1900-01-01'
    FROM			 [adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions](@MbrAceEffectiveDate) a
	JOIN
                     (
						SELECT DISTINCT a.SUBSCRIBER_ID--, ValueCodeSystem , ValueCode , ValueCodeSvcDate
						FROM		[adw].[2020_tvf_Get_ClaimsByValueSet]('ACE_MIPS_CDC9_Encounter', '',  '','',@PrimSvcDate_Start
									, @PrimSvcDate_End,@CodeSetEffective) a
						JOIN		[adw].[2020_tvf_Get_ClaimsByValueSet]('', ''
										,'ACE_MIPS_CDC9_Diabetes','',@PrimSvcDate_Start
										, @PrimSvcDate_End,@CodeSetEffective) c
						ON			a.SUBSCRIBER_ID = c.SUBSCRIBER_ID
					 ) b 
	ON				 a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
    WHERE			 AGE BETWEEN 18 AND 75
	AND				 a.DOD = '1900-01-01'; /**AND exclude members who have a date of death*/

	--Generating and Calculating Values for Exclusions
	INSERT INTO		 @TmpTable2(SUBSCRIBER_ID)
	SELECT DISTINCT  a.SUBSCRIBER_ID--,'0','0','1900-01-01'
    FROM			 [adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions](@MbrAceEffectiveDate) a	 
	JOIN			
					(
						SELECT DISTINCT	a.SUBSCRIBER_ID
						FROM			[adw].[2020_tvf_Get_ClaimsByValueSet]('', ''
										,'ACE_MIPS_CDC9_DENEX','',@PrimSvcDate_Start
										, @PrimSvcDate_End,@CodeSetEffective) a
					)b
	ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
	WHERE			a.AGE >=66

	--Inserting Values for DEN with Exclusion
	INSERT INTO		@TmpDenHeader(SUBSCRIBER_ID)
	SELECT			SUBSCRIBER_ID
	FROM			@TmpTable1
	EXCEPT
	SELECT			SUBSCRIBER_ID
	FROM			@TmpTable2
	
	---Clear Tmp Tables for Reuse
	DELETE FROM		@TmpTable1
	DELETE FROM		@TmpTable2

	--Calculating for CDC_9 Numerator Headers Values
	INSERT INTO		@TmpTable1(SUBSCRIBER_ID)
	SELECT			DISTINCT a.SUBSCRIBER_ID--, a.ValueCodeSystem, a.ValueCode, a.ValueCodeSvcDate,a.SEQ_CLAIM_ID,a.SVC_TO_DATE,a.SVC_PROV_NPI
    FROM            (
						SELECT *
						FROM
						(		/*
								Numerator: From the denominator, identify members who have the Most recent hemoglobin A1c level > 9.0% ???in 
								the measurement year as identified by the value set (HEDIS_ACO_HbA1c Level Greater Than 9.0) (3046F same as MIPS)
								and not having these codes 3044F and 3052F in that latest set of codes not In the following codes  
								*/
							SELECT SUBSCRIBER_ID
									, SEQ_CLAIM_ID
									, PRIMARY_SVC_DATE
									, ROW_NUMBER() OVER(PARTITION BY SUBSCRIBER_ID	ORDER BY PRIMARY_SVC_DATE DESC) AS RwcCnt
										, ValueCodeSystem , ValueCode , ValueCodeSvcDate,SVC_TO_DATE,SVC_PROV_NPI
							FROM	[adw].[2020_tvf_Get_ClaimsByValueSet]('HEDIS_ACO_HbA1c Level Greater Than 9.0', '','','',@PrimSvcDate_Start, @PrimSvcDate_End
									,@CodeSetEffective) a
						) b
					   WHERE b.RwcCnt = 1
					   AND	 b.ValueCode NOT IN ('3044F','3052F')
					) a
    

	--Inserting Records into Num Table for CDC_9
    INSERT	INTO	@TmpNumHeader(SUBSCRIBER_ID)
    SELECT DISTINCT	a.SUBSCRIBER_ID
    FROM			@TmpTable1 a
    INTERSECT
    SELECT			b.SUBSCRIBER_ID
    FROM			@TmpDenHeader b 

    INSERT INTO		@TmpCOPHeader(SUBSCRIBER_ID) 
    SELECT			a.SUBSCRIBER_ID
    FROM			@TmpDenHeader A 
    LEFT JOIN		@TmpNumHeader b 
	ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
    WHERE			b.SUBSCRIBER_ID IS NULL;
	----Calculating Values for Numerator Details
	INSERT INTO		@TmpTable3(SUBSCRIBER_ID, ValueCodeSystem, ValueCode, ValueCodeSvcDate,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI) 
    SELECT			a.SUBSCRIBER_ID, a.ValueCodeSystem, a.ValueCode, a.ValueCodeSvcDate,a.SEQ_CLAIM_ID,a.SVC_TO_DATE,a.SVC_PROV_NPI
    FROM            (
						SELECT *
						FROM
						(
							SELECT SUBSCRIBER_ID
									, SEQ_CLAIM_ID
									, PRIMARY_SVC_DATE
									, ROW_NUMBER() OVER(PARTITION BY SUBSCRIBER_ID	ORDER BY PRIMARY_SVC_DATE DESC) AS RwcCnt
										, ValueCodeSystem , ValueCode , ValueCodeSvcDate,SVC_TO_DATE,SVC_PROV_NPI
							FROM	[adw].[2020_tvf_Get_ClaimsByValueSet]('HEDIS_ACO_HbA1c Level Greater Than 9.0', '','','',@PrimSvcDate_Start, @PrimSvcDate_End
									,@CodeSetEffective) a
						) b
					   WHERE b.RwcCnt = 1
					   AND	 b.ValueCode NOT IN ('3044F','3052F')
					) a
   
	--Inserting Num Detail Values from tmp
    INSERT	INTO    @TmpNumDetail(SUBSCRIBER_ID, ValueCodeSystem , ValueCode , ValueCodeSvcDate,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI)
    SELECT			a.SUBSCRIBER_ID, a.ValueCodeSystem , a.ValueCode , a.ValueCodeSvcDate,a.SEQ_CLAIM_ID,a.SVC_TO_DATE,SVC_PROV_NPI
    FROM			@TmpTable3 a
    JOIN			@TmpDenHeader B
    ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
	
		
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
EXEC [adw].[sp_2020_Calc_QM_ACE_MIPS_CDC_9] 	@ConnectionStringProd	= '[adw].[QM_ResultByMember_History]',
													@QMDATE				= '2022-01-15',
													@CodeEffectiveDate		= '2021-01-01',
													@MeasurementYear		= 2021,
													@ClientKeyID			= 16,
													@MbrEffectiveDate		= '2022-01-01'
***/

