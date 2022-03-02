


CREATE PROCEDURE [adw].[Update_AhsExpMemberByPcp]( @ExportDate Date, @clientKey INT, @Skey INT, @ExportedStatus tinyint = 1)
AS 
begin

    UPDATE trgt set 
		trgt.Exported = @ExportedStatus
		, trgt.ExportedDate = @ExportDate
    --SELECT Elig.*
    FROM adw.AhsExpMemberByPcp trgt 
	WHERE trgt.AhsExpMemberByPcpKey = @Skey
		;
END
