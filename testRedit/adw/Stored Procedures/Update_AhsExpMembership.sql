


CREATE PROCEDURE [adw].[Update_AhsExpMembership]( @ExportDate Date, @clientKey INT, @Skey INT, @ExportedStatus tinyint = 1)
AS 
begin
	
    UPDATE trgt set 
		trgt.Exported = @ExportedStatus
		, trgt.ExportedDate = @ExportDate
    --SELECT Elig.*
    FROM adw.AhsExpMembership trgt 
	WHERE trgt.AhsExpMembershipKey = @Skey
	;
END

