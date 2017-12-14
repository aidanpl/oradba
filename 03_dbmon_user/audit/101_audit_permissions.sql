/*

 Name:          audit_permissions.sql

 Purpose:       Required synonyms/permissions TO dbmon

 Usage:         Change DBMON TO your preferred monitoring name

 Date            Who             Description

 15th Jun 1017   Aidan Lawrence  Validated for git

*/


GRANT DELETE ON SYS.AUD$ TO DBMON;
GRANT SELECT ON DBA_AUDIT_SESSION TO DBMON;
GRANT SELECT ON DBA_AUDIT_OBJECT TO DBMON;
GRANT SELECT ON DBA_AUDIT_TRAIL TO DBMON;
