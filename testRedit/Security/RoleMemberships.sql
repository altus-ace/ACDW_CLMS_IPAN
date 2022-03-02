ALTER ROLE [db_securityadmin] ADD MEMBER [altus_sa];


GO
ALTER ROLE [db_datareader] ADD MEMBER [ALTUSACE\ITS-DB-BA];


GO
ALTER ROLE [db_denydatareader] ADD MEMBER [ALTUSACE\ITS-EXCLUDE-DB];


GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [ALTUSACE\ITS-EXCLUDE-DB];

