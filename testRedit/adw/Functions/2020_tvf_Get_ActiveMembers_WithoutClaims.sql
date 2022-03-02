

CREATE FUNCTION [adw].[2020_tvf_Get_ActiveMembers_WithoutClaims]
	(
		@MemberEffDate			DATE,
		@PrimSvcDate_Start	DATE,
		@PrimSvcDate_End		DATE
	)
RETURNS TABLE
AS
RETURN
	( 
	SELECT a.ClientKey, a.ClientMemberKey, a.DOB, a.Gender
		--,b.subscriber_id
		FROM [adw].[2020_tvf_Get_ActiveMembersFull] (@MemberEffDate) a
		LEFT JOIN (
			SELECT DISTINCT SUBSCRIBER_ID FROM adw.Claims_Headers
			WHERE PRIMARY_SVC_DATE > = @PrimSvcDate_Start 
			AND SVC_TO_DATE < = @PrimSvcDate_End
			) b
		ON a.ClientMemberKey = b.subscriber_id
		WHERE b.subscriber_id is NULL
	)

/***
Usage: 
SELECT *
FROM [adw].[2020_tvf_Get_ActiveMembers_WithoutClaims] ('08/01/2020','01/01/2020','08/01/2020') 
***/

