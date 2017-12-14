/*

 Name:          tbsp_stats_permissions.sql

 Purpose:       Required synonyms/permissions TO dbmon

 Usage:         Change DBMON TO your preferred monitoring name

 Date            Who             Description

 15th Jun 1017   Aidan Lawrence  Validated for git

*/


GRANT SELECT ON dba_free_space  TO dbmon;
GRANT SELECT ON dba_segments    TO dbmon;
GRANT SELECT ON dba_data_files  TO dbmon;
GRANT SELECT ON dba_extents     TO dbmon;
GRANT SELECT ON dba_recyclebin  TO dbmon;
GRANT SELECT ON dba_tablespaces TO dbmon;
GRANT SELECT ON v_$database     TO dbmon;

