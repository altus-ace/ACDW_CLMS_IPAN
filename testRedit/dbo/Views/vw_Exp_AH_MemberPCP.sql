




/* view for exporting members by pcp */
CREATE VIEW [dbo].[vw_Exp_AH_MemberPCP]
AS
    /* version history:
04/26/2020 - initial export create by RA
10/19/2020: GK = added support to get latestRecords as the Max RowEffective and RowExpiration dates from the Fct.
	   */
    SELECT DISTINCT 
        m.[ClientMemberKey] AS MEMBER_ID, 
        m.[ClientKey]   AS [CLIENT_ID], 
        m.[Exp_PcpNpi] AS [MEMBER_PCP], 
        m.[Exp_ProviderRelationshipType] AS [PROVIDER_RELATIONSHIP_TYPE],   
        m.[Exp_LOB]  AS [LOB], 
        m.[Exp_PcpEffectiveDate] AS [PCP_EFFECTIVE_DATE], 
        m.[Exp_PcpTermDate] AS [PCP_TERM_DATE], 
        m.[Exp_MemberPcpAdditionalInfo_1] AS [MEMBER_PCP_ADDITIONAL_INFORMATION_1]
		,m.ClientKey
		,m.AhsExpMemberByPcpKey SKey
   FROM [adw].[AhsExpMemberByPcp]	  m
   where m.exported	= 0;

