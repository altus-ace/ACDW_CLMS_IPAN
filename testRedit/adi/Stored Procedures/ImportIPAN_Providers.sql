-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [adi].[ImportIPAN_Providers](
	@SrcFileName varchar(100) ,
	@DataDate varchar(10),
	--@LoadDate date NOT ,
	--CreatedDate date NOT ,
	@CreatedBy varchar(50),
	--LastUpdatedDate datetime NOT ,
	@LastUpdatedBy varchar(50),
	@TIN [varchar](20),
	@PracticeName [varchar](50) ,
	@NPI [varchar](20),
	@ProviderName [varchar](50),
	@Site [varchar](20) ,
	@Specialty [varchar](100) ,
	@LASTNAME [varchar](50) ,
	@FIRSTNAME [varchar](50) ,
	@PrimaryCare [varchar](20) ,
	@AttribType [varchar](20) 
	--[LoadStatus] [tinyint] 
   
)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF LEN(@TIN)> 0
	BEGIN
 INSERT INTO [adi].[Providers]
   (
       [SrcFileName]
      ,[LoadDate]
      ,[DataDate]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[LastUpdatedDate]
      ,[LastUpdatedBy]
      ,[TIN]
      ,[PracticeName]
      ,[NPI]
      ,[ProviderName]
      ,[Site]
      ,[Specialty]
      ,[LASTNAME]
      ,[FIRSTNAME]
      ,[PrimaryCare]
      ,[AttribType]
      --,[LoadStatus]
  )


     VALUES
   (
    -- @OriginalFileName  ,
	@SrcFileName  ,
	GETDATE(),
	CASE WHEN @DataDate = ''
	THEN NULL
	ELSE CONVERT(DATE, @DataDate)
	END,

	GETDATE(),
	--@LoadDate date NOT ,
	--CreatedDate date NOT ,
	@CreatedBy ,
	GETDATE(),
	--LastUpdatedDate datetime NOT ,
	@LastUpdatedBy ,
	@TIN ,
	@PracticeName  ,
	@NPI ,
	@ProviderName ,
	@Site  ,
	@Specialty ,
	@LASTNAME ,
	@FIRSTNAME ,
	@PrimaryCare ,
	@AttribType 
	)


   END;

  -- SET @ActionStopDateTime = GETDATE(); 
  -- EXEC AceMetaData.amd.sp_AceEtlAudit_Close  @AuditID, @ActionStopDateTime, 1,1,0,2   

  --  EXEC AceMetaData.amd.sp_AceEtlAudit_Open @AuditID Out, 1, 2, 1,'UHC Import PCOR', @ActionStartDateTime, @SrcFileName, 'ACECARDW.adi.copUhcPcor', '';

END




