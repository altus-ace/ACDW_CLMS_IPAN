

	CREATE PROCEDURE [adw].[pupd_QM_Addressed]
							(@srcQMDATE DATE, @trgQMDATE DATE)

	AS
	 
	SET NOCOUNT ON
	BEGIN
	
	BEGIN TRY
	BEGIN TRAN  

	CREATE TABLE		#OutputTbl (ID INT NOT NULL );

						DECLARE @AuditId INT;    
						DECLARE @JobStatus tinyInt = 1    
						DECLARE @JobType SmallInt = 9	  
						DECLARE @ClientKey INT	 = 16; 
						DECLARE @JobName VARCHAR(100) = 'adw.QM_Addressed';
						DECLARE @ActionStart DATETIME2 = GETDATE();
						DECLARE @SrcName VARCHAR(100) = 'adw.QM_Addressed'
						DECLARE @DestName VARCHAR(100) = 'ACDW_CLMS_SHCN_MSSP.adw.QM_Addressed'
						DECLARE @ErrorName VARCHAR(100) = 'NA';
						DECLARE @InpCnt INT = -1;
						DECLARE @OutCnt INT = -1;
						DECLARE @ErrCnt INT = -1;
	SELECT				@InpCnt = COUNT(a.ID)    
	FROM				#OutputTbl  a
	
	
	SELECT				@InpCnt
	
	
	EXEC				amd.sp_AceEtlAudit_Open 
						@AuditID = @AuditID OUTPUT
						, @AuditStatus = @JobStatus
						, @JobType = @JobType
						, @ClientKey = @ClientKey
						, @JobName = @JobName
						, @ActionStartTime = @ActionStart
						, @InputSourceName = @SrcName
						, @DestinationName = @DestName
						, @ErrorName = @ErrorName
						;
		

					UPDATE              adw.QM_ResultByMember_History
					SET                 Addressed = 1   ---- SELECT trg.QmMsrId,src.QmMsrId, trg.QMDate , src.QMDate,src.ClientMemberKey, trg.ClientMemberKey 
					FROM                adw.QM_ResultByMember_History trg  
					JOIN				adw.Qm_Addressed src  
					ON					src.qmdate = trg.qmdate
					WHERE               trg.ClientMemberKey = src.ClientMemberKey
					AND                 trg.QmMsrId         = src.QmMsrId
					AND                 trg.QMDate          = src.QMDate  
					AND                 trg.QmCntCat		= 'COP'
					AND                 src.QMDate          = @srcQMDATE ---'01-15-2021' 
					AND                 trg.QMDate          = @trgQMDATE ---'01-15-2021' 
					
	
			

	SELECT				@OutCnt = COUNT(*) FROM #OutputTbl;
	SET					@ActionStart  = GETDATE();
	SET					@JobStatus =2  
	    				
	EXEC				amd.sp_AceEtlAudit_Close 
						@AuditId = @AuditID
						, @ActionStopTime = @ActionStart
						, @SourceCount = @InpCnt		  
						, @DestinationCount = @OutCnt
						, @ErrorCount = @ErrCnt
						, @JobStatus = @JobStatus

	COMMIT
	END TRY

	BEGIN CATCH
	EXECUTE [dbo].[usp_QM_Error_handler]
	END CATCH

	END  

	/*
	EXECUTE [adw].[pupd_QM_Addressed]'2021-03-15','2021-03-15'
	*/



			/*  --Retired
			UPDATE			adw.QM_ResultByMember_History
			SET				Addressed = 1
			FROM			adw.QM_ResultByMember_History trg
			JOIN			adw.Qm_Addressed src
			ON				trg.ClientMemberKey = src.ClientMemberKey
			WHERE			trg.QmCntCat = 'COP'
			AND				trg.QmMsrId = src.QmMsrId
			--AND				trg.QMDate = (
			--								SELECT	MAX(QMDate) 
			--								FROM	adw.QM_ResultByMember_History
			--							 )
			*/

	
	
