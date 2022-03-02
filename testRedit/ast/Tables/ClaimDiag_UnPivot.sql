CREATE TABLE [ast].[ClaimDiag_UnPivot] (
    [SrcAdiKey]    INT          NOT NULL,
    [CLM_LINE_NUM] INT          NOT NULL,
    [DiagCD]       VARCHAR (20) NOT NULL,
    [DiagNum]      INT          NOT NULL,
    [srcClaimType] VARCHAR (10) NULL
);

