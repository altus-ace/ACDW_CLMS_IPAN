
CREATE VIEW [adw].[vw_Dashboard_PhysicianVisits]
AS
    SELECT PhysVis.FctPhysicianVisitsSkey, 
       PhysVis.CreatedDate, 
       PhysVis.CreatedBy, 
       PhysVis.LastUpdatedDate, 
       PhysVis.LastUpdatedBy, 
       PhysVis.AdiKey, 
       PhysVis.SrcFileName, 
       PhysVis.AdiTableName, 
       PhysVis.LoadDate, 
       PhysVis.DataDate, 
       PhysVis.ClientKey, 
       PhysVis.ClientMemberKey, 
       PhysVis.EffectiveAsOfDate, 
       PhysVis.VisitExamType, 
       PhysVis.SEQ_ClaimID, 
       PhysVis.PrimaryServiceDate, 
       PhysVis.SVCProviderNPI, 
       PhysVis.SVCProviderSpecialty, 
       PhysVis.PrimaryDiagnosis, 
       PhysVis.CPT, 
       PhysVis.AttribNPI, 
       PhysVis.AttribTIN
    FROM adw.FctPhysicianVisits PhysVis;

