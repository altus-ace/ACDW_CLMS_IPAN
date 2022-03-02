


CREATE FUNCTION [ast].[tvf_Get_MemberID_ConvertedTo_ClientMemberKey]
			(@EffectiveDate DATE)
RETURNS TABLE
    /* Conversion of MemberID to ClientMemberKey
	   */  
AS
    RETURN
(   
   
   SELECT DISTINCT MasterConsumerID AS ClientMemberKey
				,HICN_could_contain_ssn
				,HealthCardIdentifier
				,DateofBirth
				,FirstName,LastName
	FROM [ACDW_CLMS_AMGTX_MA].[adi].[Amerigroup_Member]
  
  );

