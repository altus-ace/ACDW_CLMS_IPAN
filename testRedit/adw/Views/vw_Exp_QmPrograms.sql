


CREATE VIEW [adw].[vw_Exp_QmPrograms]
AS
    /*     GET ACTIVE_Members: fct mbrship
			 join QM That are active for those member
			 filter for qm mapping
			 filter Plan
			 fiter Program

    THIS ONLY GETS THE LATEST QM MONTH: I Don't know if that is correct
    */

    SELECT Client.CS_Export_LobName
        , Cop.DESTINATION_PROGRAM_NAME PROGRAM_NAME        
        , Cop.programStartDate AS ENROLL_DATE 			 
        , Cop.ProgramCreateDate AS CREATE_DATE        
	   , cop.ClientMemberKey AS MEMBER_ID
        , COP.ProgramEndDate AS ENROLL_END_DATE 
        , cop.ProgramStatusCode AS PROGRAM_STATUS
        , cop.ReasonDescription AS REASON_DESCRIPTION        
        , cop.ReferalType AS REFERAL_TYPE		
	   , cop.ClientKey	   
	   , Cop.AhsExpCareOpsProgramKey SKEY
    FROM Adw.ahsExpCareOpsToPrograms Cop
	   JOIN lst.List_Client Client ON Cop.ClientKey = Client.ClientKey
--	   JOIN (SELECT Max(CareOpBatchDate) MaxCareOpBatchDate FROM Adw.CareOpsToPrograms ) MaxBatchDate
--		  ON Cop.CareOpBatchDate = MaxBatchDate.MaxCareOpBatchDate
    WHERE cop.exported = 0
