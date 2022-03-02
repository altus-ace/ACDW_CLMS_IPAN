

CREATE VIEW  [dbo].[vw_Exp_AH_PE_NewMembers]     
As           
    SELECT distinct           
	   	lc.ClientShortName  as Client_id          
        , 'TOC1' AS Program_ID          
        , 'Newly Enrolled' AS Program_Name      
        ,  getdate() as Enroll_date      
        , getdate()    As Create_date          
        , DATEADD(DAY, 90, GETDATE()) AS Enroll_End_date          
        , Mbr.ClientMemberkey AS Member_id      
        , 'ACTIVE' AS PROGRAM_STATUS       
        , 'Enrolled in a Program' AS REASON_DESCRIPTION       
        , 'SHCN_MSSP New Membership' AS REFERAL_TYPE       
        , lc.ClientKey    
        FROM [adw].FctMembership Mbr           
    	   INNER JOIN [lst].[List_Client] lc 
    		  ON lc.Clientkey = Mbr.clientkey 		      	   
    
    		LEFT JOIN (SELECT PR.ClientKey, PR.ClientMemberKey, PR.EnrollmentStartDate, PR.EnrollmentStopDate, PR.ProgramName
    					FROM adw.MbrProgramEnrollments PR
    					WHERE PR.ProgramName = 'Newly Enrolled') ProgEnr 
    			ON  Mbr.ClientMemberKey = ProgEnr.ClientMemberKey
    
    WHERE  mbr.Active = 1
    	   and mbr.DOD = '1900-01-01'
    	   AND ProgEnr.ProgramName is null
