
CREATE PROCEDURE [adw].[Valid_MemberModelZeroKeys]
AS 
BEGIN

    --P:\Information Technology\60_DatabaseDocumentation\MbrModel\InsertMbrDimZeroRows.sql
    DECLARE @MbrZeroKey			 INT;
    DECLARE @MbrDemoZeroKey		 INT;
    DECLARE @MbrPlanZeroKey		 INT;
    DECLARE @MbrCsPlanZeroKey		 INT;
    DECLARE @MbrPcpZeroKey		 INT;
    DECLARE @MbrPhoneZeroKey		 INT;
    DECLARE @MbrAddressZeroKey	 INT;
    DECLARE @MbrEmailZeroKey		 INT;
    DECLARE @MbrRespPartyZeroKey	 INT;

    SELECT @MbrZeroKey		  = COUNT(*) FROM adw.MbrMember	   where mbrMemberKey = 0
    SELECT @MbrDemoZeroKey	  = COUNT(*) FROM adw.MbrDemographic  where mbrDemographicKey = 0
    SELECT @MbrPlanZeroKey	  = COUNT(*) FROM adw.MbrPlan		   where mbrPlanKey =0
    SELECT @MbrCsPlanZeroKey	  = COUNT(*) FROM adw.mbrCsPlan	   where mbrCsPlanKey = 0
    SELECT @MbrPcpZeroKey	  = COUNT(*) FROM adw.MbrPcp		   where mbrPcpKey = 0 
    SELECT @MbrPhoneZeroKey	  = COUNT(*) FROM adw.MbrPhone	   where mbrPhoneKey = 0 
    SELECT @MbrAddressZeroKey	  = COUNT(*) FROM adw.MbrAddress	   where mbrAddressKey = 0
    SELECT @MbrEmailZeroKey	  = COUNT(*) FROM adw.MbrEmail	   where mbrEmailKey = 0
    SELECT @MbrRespPartyZeroKey = COUNT(*) FROM adw.MbrRespParty	   where mbrRespPartyKey = 0;
    
    --SELECT @MbrZeroKey,@MbrDemoZeroKey,@MbrPlanZeroKey,@MbrCsPlanZeroKey,@MbrPcpZeroKey	,@MbrPhoneZeroKey ,@MbrAddressZeroKey ,@MbrEmailZeroKey ,@MbrRespPartyZeroKey	 ;

    IF (0 = (ISNULL(@MbrZeroKey, 0)))
    BEGIN
	   SET IDENTITY_INSERT [adw].[MbrMember]   ON
	   INSERT INTO [adw].[MbrMember]   (MbrMemberKey, [ClientMemberKey],[ClientKey],[MstrMrnKey],[adiKey],[adiTableName],[IsCurrent],[LoadDate],[DataDate],[EffectiveDate],[ExpirationDate])
		   ValueS (0, 0,0, 0, 0, '', 1, getdate(), getDate(), '01/01/2000', '12/31/2099')
	   SET IDENTITY_INSERT [adw].[MbrMember]   OFF
    END


    IF (0 = (ISNULL(@MbrDemoZeroKey,0)))
    BEGIN
        SET IDENTITY_INSERT [adw].[MbrDemographic]   ON
        INSERT INTO [adw].[MbrDemographic] (MbrDemographicKey, [ClientMemberKey],[ClientKey],[adiKey],[adiTableName],[IsCurrent],[EffectiveDate],[ExpirationDate]
            ,[LastName],[FirstName],[MiddleName],[SSN],[Gender],[DOB],[mbrInsuranceCardIdNum],[MedicaidID],[HICN],[MBI],[MedicareID]
            ,[Ethnicity],[Race],[PrimaryLanguage],[LoadDate],[DataDate],[DOD])
             VALUES(0,0,0,0,'',1, '01/01/2000', '12/31/2099'
        	   ,'','','', '', '', '01/01/1900','', '', '', '', ''
        	   , '', '', '', getdate(), getdate(), '01/01/1900');
        SET IDENTITY_INSERT [adw].[MbrDemographic]   OFF
    END;
    
    IF (0 = (ISNULL(@MbrPlanZeroKey,0)))
    BEGIN
        SET IDENTITY_INSERT [adw].[mbrPlan]   ON
        INSERT INTO [adw].[MbrPlan](MbrPlanKey, [ClientMemberKey],[ClientKey],[adiKey],[adiTableName],[IsCurrent]
                   ,[EffectiveDate],[ExpirationDate],[ProductPlan],[ProductSubPlan],[ProductSubPlanName],[MbrIsDualCoverage]
                   ,[DualEligiblityStatus],[ClientPlanEffective],[LoadDate],[DataDate])
             VALUES(0, 0, 0, 0, '',1
        	   , '01/01/2000', '12/31/2099', '', '', '', ''
        	   ,'', '01/01/1900', getdate(), getdate())
        SET IDENTITY_INSERT [adw].[mbrPlan]   OFF
    END;
    
    IF (0 = (ISNULL(@MbrPcpZeroKey, 0)))
    BEGIN
        SET IDENTITY_INSERT adw.MbrPcp   ON
        INSERT INTO [adw].[MbrPcp](MbrPcpKey, [ClientMemberKey],[ClientKey],[adiKey],[adiTableName],[IsCurrent]
                   ,[EffectiveDate] ,[ExpirationDate] ,[NPI] ,[TIN],[ClientEffective],[ClientExpiration],[AutoAssigned],[LoadDate],[DataDate])
             VALUES(0,0,0,0,'', 1
        	   , '01/01/2000','12/31/2099', '','', '01/01/1900','01/01/1900', '', getdate(), getDate())
        SET IDENTITY_INSERT adw.MbrPcp  OFF
    END;
    
    IF (0 = (ISNULL(@MbrCsPlanZeroKey, 0)))
    BEGIN
        SET IDENTITY_INSERT adw.mbrCsPlan	ON
        INSERT INTO [adw].[mbrCsPlan](MbrCsPlanKey, [ClientMemberKey],[ClientKey],[adiKey],[adiTableName],[IsCurrent]
                   ,[EffectiveDate],[ExpirationDate],[MbrCsSubPlan],[MbrCsSubPlanName],[planHistoryStatus],[LoadDate], DataDate)
             VALUES(0, 0, 0, 0, '', 1
        	 , '01/01/2000','12/31/2099', '', '', '', getdate(), getDate())
        SET IDENTITY_INSERT adw.mbrCsPlan	   OFF
    END;
    
    IF (0 = (ISNULL(@MbrPhoneZeroKey, 0)))
    BEGIN
        SET IDENTITY_INSERT adw.MbrPhone	ON
        INSERT INTO [adw].[MbrPhone](MbrPhoneKey,[ClientMemberKey],[ClientKey],[adiKey],[adiTableName],[IsCurrent]
                   ,[EffectiveDate],[ExpirationDate],[PhoneType],[CarrierType],[PhoneNumber],[IsPrimary],[LoadDate],[DataDate])
             VALUES(0, 0 ,0, 0, '', 1
        	   , '01/01/2000','12/31/2099', 7,5, '', 1, getDate(), getDate())
        SET IDENTITY_INSERT adw.MbrPhone	OFF  
    END;
    
    IF (0 = (ISNULL(@MbrAddressZeroKey, 0)))
    BEGIN
        SET IDENTITY_INSERT adw.MbrAddress	ON
        INSERT INTO [adw].[MbrAddress](MbrAddressKey, [ClientMemberKey],[ClientKey],[adiKey],[adiTableName],[IsCurrent]
                   ,[EffectiveDate],[ExpirationDate],[AddressTypeKey],[Address1],[Address2],[CITY],[STATE],[ZIP],[COUNTY],[LoadDate],[DataDate])
             VALUES(0, 0, 0, 0, '', 1
        	   , '01/01/2000','12/31/2099', 1, '','', '', '', '', '', getdate(), getDate());
        SET IDENTITY_INSERT adw.MbrAddress	OFF
    END;
    
    IF (0 = (ISNULL(@MbrEmailZeroKey, 0)))
    BEGIN
        SET IDENTITY_INSERT adw.MbrEmail	ON
        INSERT INTO [adw].[MbrEmail](MbrEmailKey, [LoadDate],[DataDate],[ClientMemberKey],[ClientKey],[adiKey],[adiTableName],[IsCurrent]
                   ,[EffectiveDate],[ExpirationDate],[EmailType],[EmailAddress],[IsPrimary])
             VALUES(0, getdate(), getDate(), 0, 0, 0, '', 1
        	   , '01/01/2000','12/31/2099', 3, '', 1);
        SET IDENTITY_INSERT adw.MbrEmail	OFF
    END;
    --
    IF (0 = (ISNULL(@MbrRespPartyZeroKey, 0)))
    BEGIN
        /* insert MbrRespParty Zero Row */
        SET IDENTITY_INSERT [adw].[MbrRespParty] ON
        INSERT INTO [adw].[MbrRespParty]
                   (mbrRespPartyKey, [mbrMemberKey] ,[ClientMemberKey],[ClientKey],[adiKey],[adiTableName],[recordFlag],[EffectiveDate],[ExpirationDate]
                   ,[LastName],[FirstName],[Address1],[Address2],[CITY],[STATE],[ZIP],[Phone],[LoadDate],[DataDate])
             VALUES(0,0, 0,0,0,'',1, '01/01/1980', '12/31/2099'
                   ,'' , '' , '' , '' , '' , '' , '' , '' ,getdate(),getdate())
        SET IDENTITY_INSERT [adw].[MbrRespParty] OFF
    END;
end;
