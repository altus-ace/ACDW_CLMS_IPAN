-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [adi].[ImportIPAN_Attribution](

	@SrcFileName varchar(100) ,
	@DataDate varchar(10),
	--@LoadDate date NOT ,
	--CreatedDate date NOT ,
	@CreatedBy varchar(50),
	--LastUpdatedDate datetime NOT ,
	@LastUpdatedBy varchar(50),
	@OriginalMBI [varchar](50) ,
	@CurrentMBI [varchar](50) ,
	@BMTIN [varchar](20) ,
	@BMNPI [varchar](20) ,
	@CYTIN [varchar](20) ,
	@CYNPI [varchar](20) ,
	@Year_2018 [varchar](10) ,
	@Year_2021Q2 [varchar](10)
   
)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF LEN(@BMTIN) > 0
	BEGIN
 INSERT INTO [adi].[Attribution]
   (
       [SrcFileName]
      ,[LoadDate]
      ,[DataDate]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[LastUpdatedDate]
      ,[LastUpdatedBy]
      ,[OriginalMBI]
      ,[CurrentMBI]
      ,[BMTIN]
      ,[BMNPI]
      ,[CYTIN]
      ,[CYNPI]
      ,[Year_2018]
      ,[Year_2021Q2]
  )


     VALUES
   (

	@SrcFileName  ,
	GETDATE(),
	@DataDate ,
	GETDATE(),
	--@LoadDate date NOT ,
	--CreatedDate date NOT ,
	@CreatedBy ,
	GETDATE(),
	--LastUpdatedDate datetime NOT ,
	@LastUpdatedBy ,
	@OriginalMBI  ,
	@CurrentMBI ,
	@BMTIN ,
	@BMNPI  ,
	@CYTIN ,
	@CYNPI  ,
	@Year_2018 ,
	@Year_2021Q2 
	)


   END;

  -- SET @ActionStopDateTime = GETDATE(); 
  -- EXEC AceMetaData.amd.sp_AceEtlAudit_Close  @AuditID, @ActionStopDateTime, 1,1,0,2   

  --  EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID Out, 1, 2, 1,'UHC Import PCOR', @ActionStartDateTime, @SrcFileName, 'ACECARDW.adi.copUhcPcor', '';

END




