/***
09.04.20	SN	Changed from tmp_Active_Members to fctMembership. Declare Max RWExpiration Date
***/

CREATE PROCEDURE [adw].[sp_Get_ClaimMember]
	-- Add the parameters for the stored procedure here
	 @ClientMemberKey		VARCHAR(50)
	,@SeqClaimID			VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
DECLARE @MaxRWDate DATE = (SELECT MAX(RWExpirationDate) FROM adw.FctMembership)
IF (@ClientMemberKey <> '0' AND @SeqClaimID = '0')
	SELECT 
		 Ace_ID
		,ClientMemberKey
		,HICN as AltClientMemberKey
		,CONCAT(FirstName,' ', LastName) as FullName
		,CONCAT(Gender, ' ', DOB) as Gender_DOB
		,CASE WHEN DOD = '1900-01-01' THEN 'N' ELSE CONCAT('Y','-',DOD) END as Expired
		,NPI as AttribNPI
		,CONCAT(ProviderFirstName,' ',ProviderLastName) as AttribNPIName 
      ,PcpPracticeTIN as AtrribTIN
		,ProviderPracticeName as AtrribTINName
	FROM [adw].[2020_tvf_Get_ActiveMembersFull] (@MaxRWDate) a
	WHERE ClientMemberKey = @ClientMemberKey
ELSE IF (@SeqClaimID <> '0' AND @ClientMemberKey = '0')
	SELECT 
		 Ace_ID
		,ClientMemberKey
		,HICN as AltClientMemberKey
		,CONCAT(FirstName,' ', LastName) as FullName
		,CONCAT(Gender, ' ', DOB) as Gender_DOB
		,CASE WHEN DOD = '1900-01-01' THEN 'N' ELSE CONCAT('Y','-',DOD) END as Expired
		,NPI as AttribNPI
		,CONCAT(ProviderFirstName,' ',ProviderLastName) as AttribNPIName 
      ,PcpPracticeTIN as AtrribTIN
		,ProviderPracticeName as AtrribTINName
	FROM [adw].[2020_tvf_Get_ActiveMembersFull] (@MaxRWDate) a
	JOIN (
			SELECT DISTINCT SUBSCRIBER_ID as C_ClientMemberKey, SEQ_CLAIM_ID
				FROM [adw].[Claims_Headers]
			) ch
	ON a.ClientMemberKey = ch.C_ClientMemberKey
	WHERE ch.SEQ_CLAIM_ID = @SeqClaimID

ELSE
		SELECT 
		 Ace_ID
		,ClientMemberKey
		,HICN as AltClientMemberKey
		,CONCAT(FirstName,' ', LastName) as FullName
		,CONCAT(Gender, ' ', DOB) as Gender_DOB
		,CASE WHEN DOD = '1900-01-01' THEN 'N' ELSE CONCAT('Y','-',DOD) END as Expired
		,NPI as AttribNPI
		,CONCAT(ProviderFirstName,' ',ProviderLastName) as AttribNPIName 
      ,PcpPracticeTIN as AtrribTIN
		,ProviderPracticeName as AtrribTINName
	FROM [adw].[2020_tvf_Get_ActiveMembersFull] (@MaxRWDate) a
	JOIN (
			SELECT DISTINCT SUBSCRIBER_ID as C_ClientMemberKey, SEQ_CLAIM_ID
				FROM [adw].[Claims_Headers]
			) ch
	ON a.ClientMemberKey = ch.C_ClientMemberKey
	WHERE ch.SEQ_CLAIM_ID = @SeqClaimID
	AND ch.C_ClientMemberKey = @ClientMemberKey

END
/***
EXEC [adw].[sp_Get_ClaimMember] '3KC7H18FY79','48832837321'
***/


