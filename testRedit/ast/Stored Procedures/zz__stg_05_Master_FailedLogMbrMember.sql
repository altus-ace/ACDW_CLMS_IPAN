


CREATE PROCEDURE [ast].[zz__stg_05_Master_FailedLogMbrMember](@DataDate DATE, @LoadDateFrmStg DATE)


AS

EXECUTE [ast].[FailedLogMbrMember] @DataDate,@LoadDateFrmStg

/*
Not in use at the moment
EXECUTE	[ast].[FailedLogMbrAddress]
EXECUTE	[ast].[FailedLogMbrCsPlan]
EXECUTE	[ast].[FailedLogMbrDemo]
EXECUTE	[ast].[FailedLogMbrEmail]
EXECUTE	[ast].[FailedLogMbrPcp]
EXECUTE	[ast].[FailedLogMbrPhone]
EXECUTE	[ast].[FailedLogMbrPlan]

*/
