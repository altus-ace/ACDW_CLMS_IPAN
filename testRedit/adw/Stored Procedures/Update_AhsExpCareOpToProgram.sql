

CREATE PROCEDURE [adw].[Update_AhsExpCareOpToProgram]( @ExportDate Date, @clientKey INT, @Skey INT, @ExportedStatus tinyint = 1)
AS 
begin

    UPDATE trgt set 
		trgt.Exported = @ExportedStatus
		, trgt.ExportedDate = @ExportDate        
    FROM adw.AhsExpCareOpsToPrograms trgt	   
    WHERE trgt.AhsExpCareOpsProgramKey = @Skey
	   ;

END


