



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [adw].[sp_Get_ClaimAll]
	-- Add the parameters for the stored procedure here
	 @ClientMemberKey	VARCHAR(50)
	,@SeqClaimID		VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;


EXEC [adw].[sp_Get_ClaimHeader]		@ClientMemberKey,@SeqClaimID
EXEC [adw].[sp_Get_ClaimDetails]	@ClientMemberKey,@SeqClaimID
EXEC [adw].[sp_Get_ClaimDiags]		@ClientMemberKey,@SeqClaimID
EXEC [adw].[sp_Get_ClaimProcs]		@ClientMemberKey,@SeqClaimID
EXEC [adw].[sp_Get_ClaimPharmacy]	@ClientMemberKey,@SeqClaimID

END

/***
EXEC [adw].[sp_Get_ClaimAll] '3VP5R09XH56','83242287217'
EXEC [adw].[sp_Get_ClaimAll] '4N47RR4MG67','82060752710'
EXEC [adw].[sp_Get_ClaimAll] '6D08J36UY30','87465096887'
EXEC [adw].[sp_Get_ClaimAll] '3VP5R09XH56','83242287217'
***/



