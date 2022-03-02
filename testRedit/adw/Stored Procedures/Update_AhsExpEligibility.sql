


CREATE PROCEDURE [adw].[Update_AhsExpEligibility]( @ExportDate Date, @clientKey INT, @Skey INT, @ExportedStatus tinyint = 1)
AS 
begin

    UPDATE trgt set 
		trgt.Exported = @ExportedStatus
		, trgt.ExportedDate = @ExportDate
    --SELECT Elig.*
    FROM adw.AhsExpEligiblity trgt 
	WHERE trgt.AhsExpEligibilityKey = @Skey
		;
END
