CREATE FUNCTION [adw].[2020_tvf_Get_AHRCareGaps]
(
 --@ClientMemberKey	VARCHAR(50)
)
RETURNS TABLE
AS RETURN
(
		SELECT TOP (1000) [ID]
      ,[SUBSCRIBER_ID]
      ,[CGQMDATE]
      ,[CGQM]
      ,[CGQMDESC]
      ,[LOADDATE]
      ,[LOADEDBY]
  FROM [dbo].[tmp_AHR_HL7_Report_Detail_CG]
--  WHERE SUBSCRIBER_ID = '3KW8KD8QE58' --@ClientMemberKey
)
