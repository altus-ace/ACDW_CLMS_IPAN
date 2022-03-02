





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [adw].[sp_2020_Calc_QM_ACE_MIPS_CBP] 
	-- Parameters for the stored procedure here
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
		--DECLARE @qmdate date ='2020-10-15'	
		--DECLARE @MbrEffectiveDate DATE = '2021-12-01'
	--  Declare Variables
	DECLARE @Metric				Varchar(20)			= 'ACE_MIPS_CBP'
	DECLARE @RunDate			Date				= @QMDATE --Getdate()
	DECLARE @RunTime			Datetime			= Getdate()
	DECLARE @Today				Date				= Getdate()
	DECLARE @TodayMth			Int					= Month(Getdate())
	DECLARE @TodayDay			Int					= Day(Getdate())
	DECLARE @Year				INT					=Year(Getdate())
	DECLARE @PrimSvcDate_Start	VarChar(20)			=CONCAT('01/1/',@MeasurementYear)
	DECLARE @PrimSvcDate_End	Varchar(20)			= CONCAT('12/31/',@MeasurementYear)
	DECLARE @StartDatePriorToMeasurementYear Date	= CONCAT('01/1/', @MeasurementYear - 1)
	DECLARE @CodeSetEffective  VARCHAR(20)			= @CodeEffectiveDate
	/*year prior to the measurement period and the first six months of the measurement period (January 1, 2021
	- June 30, 2022)*/
	DECLARE @PriorYearBegin		Varchar(20)			= CONCAT('01/1/',@MeasurementYear - 1)
	DECLARE @CurrentYearJun		Varchar(20)			= CONCAT('06/30/',@MeasurementYear)
	DECLARE @MbrAceEffectiveDate	DATE		= @MbrEffectiveDate
	DECLARE @QmMeasYear CHAR(4) = @MeasurementYear /*Defines the Measurement Year in question*/
	

	DECLARE @TmpTable1 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					 
	DECLARE @TmpTable2 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,MaxDate DATE,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpTable3 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,MaxDate DATE,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))	
	DECLARE @TmpTable4 as Table		(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,MaxDate DATE,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))				
	DECLARE @TmpDenHeader as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpDenDetail as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpNumHeader as Table	(SUBSCRIBER_ID VarChar(20),SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TmpNumDetail as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE,SVC_PROV_NPI VARCHAR(50))					
	DECLARE @TmpCOPHeader as Table	(SUBSCRIBER_ID VarChar(20), ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	DECLARE @TblResult as Table		(METRIC Varchar(20), SUBSCRIBER_ID VarChar(20),ValueCodeSystem Varchar(20), ValueCode Varchar(20), ValueCodeSvcDate Date,SEQ_CLAIM_ID VARCHAR(50),SVC_TO_DATE DATE)					
	
	-- TmpTable to store Denominator --getActiveMembers does not have valuecode etc
	INSERT INTO		@TmpTable1(SUBSCRIBER_ID, ValueCodeSystem, ValueCode, ValueCodeSvcDate)
	SELECT DISTINCT a.SUBSCRIBER_ID, '0', '0', ''
	FROM			[adw].[2020_tvf_Get_ActiveMembers_WithQMExclusions] (@MbrAceEffectiveDate) a
	JOIN			[adw].[2020_tvf_Get_ClaimsByValueSet]('', ''
					,'','ACE_MIPS_SCD_Encounter', @PriorYearBegin, @CurrentYearJun, @CodeSetEffective) b
	ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
	JOIN			(SELECT DISTINCT c.SUBSCRIBER_ID
						FROM [adw].[2020_tvf_Get_ClaimsByValueSet]('', ''
					,'','HEDIS_ACO_Essential Hypertension', @PriorYearBegin, @CurrentYearJun, @CodeSetEffective)c
					    ) c
	ON				a.SUBSCRIBER_ID = c.SUBSCRIBER_ID
	WHERE			a.AGE BETWEEN 18 AND 85
	AND				a.DOD = '1900-01-01' /*AND exclude members who have a date of death*/

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
	SELECT DISTINCT	SUBSCRIBER_ID
	FROM			@TmpTable1
	EXCEPT
	SELECT			SUBSCRIBER_ID
	FROM			@TmpTable2
	  
	-- Clear out tmpTables to reuse
	DELETE FROM		@TmpTable1
	DELETE FROM		@TmpTable2
	
	--Generating Claim Values for Numerator
	--TmpTable to store Numerator Values for headers
	/*
		Performance Met  :  Most recent systolic blood pressure< 140 mmHg (CPT/Procedure Code = G8752) --tvf-get claims by cptcode
		Exclude readings if they were on the same day as acute inpatient stay  (HEDIS_ACO_Acute Inpatient) 
		OR same day as (HEDIS_ACO_ED)  an ED visit
	*/	
	INSERT INTO		@TmpTable2(SUBSCRIBER_ID,MaxDate)
	SELECT DISTINCT a.SUBSCRIBER_ID,a.PRIMARY_SVC_DATE	
	FROM	(	SELECT	DISTINCT a.SUBSCRIBER_ID
						,a.PRIMARY_SVC_DATE
						,a.CPT_CODE
						,ROW_NUMBER()OVER(PARTITION BY a.SUBSCRIBER_ID ORDER BY a.PRIMARY_SVC_DATE)RwCnt
				FROM	[adw].[2020_tvf_Get_ClaimsByCPTCode](@PriorYearBegin,@CurrentYearJun) a
				WHERE	CPT_CODE = 'G8752'
			)a
	WHERE RwCnt = 1 
	EXCEPT
	SELECT DISTINCT a.SUBSCRIBER_ID
					,a.PRIMARY_SVC_DATE
					--,a.SEQ_CLAIM_ID
	FROM		 [adw].[2020_tvf_Get_ClaimsByValueSet]('HEDIS_ACO_Acute Inpatient', 'HEDIS_ACO_ED'
					, '', '', @PriorYearBegin, @CurrentYearJun, @CodeSetEffective) a
	
	--TmpTable to store Numerator Values for Details
	INSERT INTO		@TmpTable4(SUBSCRIBER_ID,MaxDate, ValueCodeSystem, ValueCode, ValueCodeSvcDate,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI)
	SELECT DISTINCT a.SUBSCRIBER_ID,a.PRIMARY_SVC_DATE, a.ValueCodeSystem, a.ValueCode, a.ValueCodeSvcDate,a.SEQ_CLAIM_ID,a.SVC_TO_DATE,a.SVC_PROV_NPI
	FROM	(
				SELECT	DISTINCT a.SUBSCRIBER_ID
						,a.PRIMARY_SVC_DATE
						, c. ValueCodeSystem
						, c.ValueCode
						, c.PRIMARY_SVC_DATE AS  ValueCodeSvcDate
						,a.SEQ_CLAIM_ID
						,c.SVC_TO_DATE
						,c.SVC_PROV_NPI
						,ROW_NUMBER()OVER(PARTITION BY a.SUBSCRIBER_ID ORDER BY a.PRIMARY_SVC_DATE DESC )RwCnt
				FROM	(SELECT	DISTINCT a.SUBSCRIBER_ID
									,a.PRIMARY_SVC_DATE
									,a.CPT_CODE,a.SEQ_CLAIM_ID
									,ROW_NUMBER()OVER(PARTITION BY a.SUBSCRIBER_ID ORDER BY a.PRIMARY_SVC_DATE)RwCnt
							FROM	[adw].[2020_tvf_Get_ClaimsByCPTCode](@PriorYearBegin,@CurrentYearJun) a
							WHERE	CPT_CODE = 'G8752') a
				JOIN	(SELECT * FROM [adw].[2020_tvf_Get_ClaimsByValueSet]('HEDIS_ACO_Acute Inpatient', 'HEDIS_ACO_ED'
								, '', '', @PriorYearBegin, @CurrentYearJun, @CodeSetEffective) )c
				ON		a.SUBSCRIBER_ID = c.SUBSCRIBER_ID
				WHERE	a.PRIMARY_SVC_DATE BETWEEN @PriorYearBegin AND @CurrentYearJun
			)a
	WHERE RwCnt = 1 
	EXCEPT
	SELECT DISTINCT a.SUBSCRIBER_ID
					,a.PRIMARY_SVC_DATE
					,a.ValueCodeSystem,a.ValueCode,a.PRIMARY_SVC_DATE,a.SEQ_CLAIM_ID,a.SVC_TO_DATE,a.SVC_PROV_NPI
	FROM		 [adw].[2020_tvf_Get_ClaimsByValueSet]('HEDIS_ACO_Acute Inpatient', 'HEDIS_ACO_ED'
					, '', '', @PriorYearBegin, @CurrentYearJun, @CodeSetEffective) a		
	
		
  -- Insert into Numerator Header using TmpTable, with only members in the denominator
	INSERT INTO		@TmpNumHeader(SUBSCRIBER_ID)
	SELECT			DISTINCT a.SUBSCRIBER_ID 
	FROM			@TmpTable2 a 
	INTERSECT    
	SELECT			b.SUBSCRIBER_ID 
	FROM			@TmpDenHeader  b
	-- Insert into Numerator Detail using TmpTable
	INSERT INTO		@TmpNumDetail(SUBSCRIBER_ID, ValueCodeSystem, ValueCode, ValueCodeSvcDate,SEQ_CLAIM_ID,SVC_TO_DATE,SVC_PROV_NPI)
	SELECT			a.SUBSCRIBER_ID, a.ValueCodeSystem, a.ValueCode, a.ValueCodeSvcDate,a.SEQ_CLAIM_ID,a.SVC_TO_DATE,a.SVC_PROV_NPI
	FROM		    @TmpTable4 a
	INNER JOIN		@TmpDenHeader b
	ON				a.SUBSCRIBER_ID = b.SUBSCRIBER_ID
	--select * from @TmpNumDetail
	-- Insert into CareOpp Header
	INSERT INTO		@TmpCOPHeader(SUBSCRIBER_ID)
	SELECT			a.SUBSCRIBER_ID 
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
EXEC [adw].[sp_2020_Calc_QM_ACE_MIPS_CBP]	 @ConnectionStringProd	= '[adw].[QM_ResultByMember_History]',
											 @QMDATE				= '2022-01-15',
											 @CodeEffectiveDate		= '2021-01-01',
											 @MeasurementYear		= 2021,
											 @ClientKeyID			= 16,
											 @MbrEffectiveDate		= '2022-01-01'
***/
