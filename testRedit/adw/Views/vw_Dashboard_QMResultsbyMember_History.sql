
CREATE VIEW [adw].[vw_Dashboard_QMResultsbyMember_History]
AS 
    -- Purpose: creates a Persiste
SELECT qm.QM_ResultByMbr_HistoryKey, 
       qm.ClientKey, 
       qm.ClientMemberKey, 
       qm.QmMsrId, 
       qm.QmCntCat, 
       qm.QMDate, 
       qm.CreateDate, 
       qm.CreateBy, 
       qm.LastUpdatedDate, 
       qm.LastUpdatedBy, 
       qm.AdiKey
FROM [adw].[QM_ResultByMember_History] qm
WHERE qm.QMDate = (select max(QMDate) from  [adw].[QM_ResultByMember_History]);


