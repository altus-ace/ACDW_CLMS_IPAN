

/* Load source from dims */
CREATE FUNCTION [ast].[tvf_Get_ActiveMbrFromDim](@EffectiveDate DATE, @ClientKey INT)
RETURNS TABLE
    /* Purpose: gets all members active for all clients for a specific day.
	   Incudes the keys of the Rows used to create the set. 
	   */  
AS
    RETURN
(   
    /*  /
	   SET STATISTICS IO ON;
	   DBCC FREEPROCCACHE;

	   DECLARE @EffectiveDate date = '10/20/2020'
	   declare @clientKey int = 16

/	  */
		-- DECLARE @EffectiveDate date = '2021-01-01' DECLARE @ClientKey INT = 20;
    SELECT DISTINCT
           mbr.[mbrMemberKey]
		 , MbrDemo.mbrDemographicKey
		 , MbrPlan.mbrPlanKey , mbrPlan.EffectiveDate, mbrPlan.ExpirationDate
		 , MbrPcp.mbrPcpKey
		 , mbrCsPlan.mbrCsPlanKey
		 , ISNULL(MbrPhoneHome.mbrPhoneKey,0)	  AS MbrPhoneKey_Home
		 , ISNULL(MbrPhoneMobile.mbrPhoneKey, 0)  AS MbrPhoneKey_Mobile
		 , ISNULL(MbrPhoneWork.mbrPhoneKey, 0)	  AS MbrPHoneKeyType_Work
		 , ISNULL(MbrAddressHome.mbrAddressKey,0) AS MbrAddressKeyHome
		 , ISNULL(MbrAddressMail.mbrAddressKey,0) AS MbrAddressKeyMail
		 , lc.ClientShortName	  AS CLIENT
		 , lc.ClientKey		  AS ClientKey
		 , mbr.[ClientMemberKey]	  AS MEMBER_ID
		 , mbr.MstrMrnKey		  AS Ace_ID
		 , GETDATE() AS CreatedDate
		 , system_user AS CreatedBy
		 , @EffectiveDate AS MemberMonthDate
		 ,MemberOriginalEffectiveDate
		 ,'2099-12-31' AS MemberTermDateDate  --- Recent changes applied
    FROM [adw].[MbrMember] mbr										    
	   JOIN [lst].[List_Client] lc ON lc.Clientkey = mbr.clientkey	
	   JOIN [adw].[MbrPcp] MbrPcp ON MbrPcp.ClientMemberKey = mbr.ClientMemberKey 
		  AND @EffectiveDate BETWEEN MbrPcp.EffectiveDate AND MbrPcp.ExpirationDate
		  --AND mbrPcp.ClientKey = mbr.ClientKey						    -- Issue #1
	   JOIN [adw].[MbrPlan] MbrPlan 
		  ON MbrPlan.ClientMemberKey = mbr.ClientMemberKey		  
			 -- mbrPlan.ClientKey = mbr.ClientKey
			 AND (@EffectiveDate BETWEEN MbrPlan.EffectiveDate AND MbrPlan.ExpirationDate)	    -- Issue #2
	   JOIN [adw].[MbrDemographic] MbrDemo 
		  ON MbrDemo.ClientMemberKey = mbr.ClientMemberKey
			 -- mbrDemo.ClientKey = mbr.ClientKey
			 AND (@EffectiveDate BETWEEN MbrDemo.EffectiveDate AND MbrDemo.ExpirationDate)
	   JOIN adw.mbrCsPlan MbrCsPlan 
		  ON MbrCsPlan.ClientMemberKey = mbr.ClientMemberKey
			 -- mbrCsPlan.ClientKey = mbr.ClientKey
			 AND (@EffectiveDate BETWEEN MbrCsPlan.EffectiveDate AND MbrCsPlan.ExpirationDate)
	   LEFT JOIN (SELECT DISTINCT ClientMemberKey, EffectiveDate, ExpirationDate, AddressTypeKey, MbrAddressKey,
				Address1, Address2, city, STATE, 
				case when try_convert(int,RIGHT(address1,5)) IS null then ZIP 
				    else RIGHT(address1,5)  end  ZIP,COUNTY, TRY_CONVERT(int, Zip) AS zipCodeJoin
				FROM [adw].[MbrAddress]
				) AS MbrAddressHome 
				ON MbrAddressHome.ClientMemberKey = mbr.ClientMemberKey
				    -- mbrAddressHome.ClientKey = mbr.ClientKey
				    AND MbrAddressHome.AddressTypeKey = 1
				    AND (@EffectiveDate BETWEEN MbrAddressHome.EffectiveDate AND MbrAddressHome.ExpirationDate)
	   --  LEFT JOIN SELECT * FROM lst.[lstAddressType] lstAddressType1 ON lstAddressType1.[lstAddressTypeKey] = MbrAddress1.[AddressTypeKey]
	   --	   AND lstAddressType1.lstAddressTypeKey = 1
	   LEFT JOIN [adw].[MbrAddress] MbrAddressMail 
		  ON MbrAddressMail.ClientMemberKey= mbr.ClientMemberKey 
			 -- AND MbrAddressMail.ClientKey = Mbr.ClientKey
			 AND MbrAddressMail.AddressTypeKey = 2
			 AND @EffectiveDate BETWEEN MbrAddressMail.EffectiveDate AND MbrAddressMail.ExpirationDate
    --  LEFT JOIN lst.[lstAddressType] lstAddressType2 ON lstAddressType2.[lstAddressTypeKey] = MbrAddress2.[AddressTypeKey]
    --	   AND lstAddressType2.lstAddressTypeKey = 2
         LEFT JOIN(SELECT DISTINCT c.mbrPhoneKey, c.ClientMemberKey, c.EffectiveDate, c.ExpirationDate, c.PhoneType, c.PhoneNumber, rank
				FROM (SELECT DISTINCT p.[mbrPhoneKey], p.ClientMemberKey, p.[EffectiveDate],p.[ExpirationDate], p.[PhoneType], p.[PhoneNumber]
					   , ROW_NUMBER() OVER(PARTITION BY p.CLientMemberKey /*, p.clientkey */ ORDER BY p.[ExpirationDate] DESC) AS rank
					   FROM [adw].[MbrPhone] p
					   WHERE p.PhoneType = 1
					  ) AS c
				WHERE c.rank = 1) AS MbrPhoneHome 
		  ON MbrPhoneHome.ClientMemberKey = mbr.ClientMemberKey
			 --AND MbrPhoneHome.ClientKey = mbr.ClientKey
			 AND (@EffectiveDate BETWEEN MbrPhoneHome.EffectiveDate AND MbrPhoneHome.ExpirationDate)
	   --		LEFT JOIN SELECT * FROM lst.lstPhoneType lstType_MbrPhone1pt ON lstType_MbrPhone1pt .lstPhonetypeKey = MbrPhone1.phoneType
	   --		    AND lstType_MbrPhone1pt .lstPhoneTYpekey = 1
         LEFT JOIN ( SELECT DISTINCT [mbrPhoneKey], ClientMemberKey,[EffectiveDate], [ExpirationDate],[PhoneType],[PhoneNumber], [rank]
				    FROM (SELECT DISTINCT p.[mbrPhoneKey], p.ClientMemberKey, p.[EffectiveDate],p.[ExpirationDate], p.[PhoneType], p.[PhoneNumber]
					   , ROW_NUMBER() OVER(PARTITION BY p.ClientMemberKey /*, p.ClientKey */ ORDER BY p.[ExpirationDate] DESC) AS rank
					   FROM [adw].[MbrPhone] p
					   WHERE p.PhoneType = 4
						  ) AS c1
				    WHERE c1.rank = 1) MbrPhoneMobile 
		  ON MbrPhoneMobile.ClientMemberKey= mbr.ClientMemberKey
			 -- AND MbrPhoneMobile.ClientKey = mbr.ClientKey
			 AND @EffectiveDate BETWEEN MbrPhoneMobile.EffectiveDate AND MbrPhoneMobile.ExpirationDate
    --	   LEFT JOIN lst.lstPhoneType lpt2 ON lpt2.lstPhonetypeKey = MbrPhone2.phoneType
    --		 AND lpt2.lstPhoneTYpekey = 4
        LEFT JOIN(SELECT DISTINCT [mbrPhoneKey], ClientMemberKey, [EffectiveDate],[ExpirationDate],[PhoneType],[PhoneNumber]
				FROM(SELECT DISTINCT p.[mbrPhoneKey], p.ClientMemberKey, p.[EffectiveDate],p.[ExpirationDate], p.[PhoneType], p.[PhoneNumber]
					   , ROW_NUMBER() OVER(PARTITION BY p.ClientMemberKey/* ,p.ClientKey */ ORDER BY p.[ExpirationDate] DESC) AS rank
					   FROM [adw].[MbrPhone] p
					   WHERE p.PhoneType = 3
					   ) AS c3
				WHERE c3.rank = 1) MbrPhoneWork 
		  ON MbrPhoneWork.ClientMemberKey = mbr.ClientMemberKey
			 -- AND MbrPhoneWork.CLientKey = mbr.ClientKey
			 AND @EffectiveDate BETWEEN MbrPhoneWork.EffectiveDate AND MbrPhoneWork.ExpirationDate --order by MEMBER_ID
	   --  LEFT JOIN lst.lstPhoneType lpt3 ON lpt3.lstPhonetypeKey = MbrPhone3.phoneType
	   --	 AND lpt3.lstPhoneTYpekey = 3	
	   WHERE mbr.EffectiveDate = @EffectiveDate
	   AND	MbrPcp.EffectiveDate = @EffectiveDate
	   AND	MbrPlan.EffectiveDate = @EffectiveDate
	   AND	MbrDemo.EffectiveDate = @EffectiveDate
	   AND  mbrCsPlan.EffectiveDate = @EffectiveDate
	   AND  MbrAddressHome.EffectiveDate = @EffectiveDate
	   AND @clientKey IN (@ClientKey,0) --or (@clientKey <> 0 and lc.ClientKey = @clientKey)
  
  );

