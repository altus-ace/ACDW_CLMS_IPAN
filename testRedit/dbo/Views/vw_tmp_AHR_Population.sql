



CREATE VIEW [dbo].[vw_tmp_AHR_Population]
AS
  SELECT DISTINCT
	  H.ClientKey
	  ,H.ClientMemberKey
	  ,H.[HICN]
      ,H.[MBI]
      ,H.[FirstName]
      ,H.[LastName]
      ,H.[Sex]
      ,H.[DOB]
      ,H.[Age]
      ,H.[TIN]
      ,H.[TIN_NAME]
      ,H.[NPI]
      ,H.[NPI_NAME]
	  ,D.ClientName
	  ,D.Address1
	  ,D.Address2
	  ,D.City
	  ,D.State
	  ,D.Zip
	  ,D.SubscriberNo
	  ,D.Phone
	  --,H.CurrentDisplayGaps
  FROM [adw].[AHR_Population_History]  H with (nolock)
  JOIN [dbo].[tmp_AHR_HL7_Report_Header]  D with (nolock)ON H.ClientMemberKey = D.SubscriberNo
  WHERE LOAD_DATE = (SELECT MAX(LOAD_DATE) FROM [adw].[AHR_Population_History])
  --AND [ToSend] = 'Y'
  --AND H.CurrentDisplayGaps > 2


