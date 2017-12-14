/*

 Name:          job_results_permissions.sql

 Purpose:       Required synonyms/permissions TO dbmon

 Usage:         Change DBMON TO your preferred monitoring name

 Date            Who             Description

 10th Oct 1017   Aidan Lawrence  Validated for git

*/

 GRANT SELECT ON dba_scheduler_job_run_details TO dbmon;
 GRANT SELECT ON v_$database TO dbmon;


