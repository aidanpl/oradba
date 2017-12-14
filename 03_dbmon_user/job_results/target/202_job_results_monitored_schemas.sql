/*

 Name:          job_results_monitored_schemas.sql

 Purpose:       Populate dbarep_parameters with List of schemas to including in Monitoring

 Usage:         Application specific

 Date            Who             Description

 10th Oct 1017   Aidan Lawrence  Validated for git

*/


/*

 To obtain a list of schemas currently with scheduled jobs try something like

SELECT DISTINCT owner, job_name 
FROM dba_scheduler_job_run_details
WHERE OWNER NOT IN ('SYS')
ORDER BY OWNER;

Then a personal/application specific judgement call as to what is worth monitoring.

*/


DELETE FROM dbarep_parameters
WHERE 
param_name = 'JOB_RESULTS_MONITORED_SCHEMAS'
/

INSERT INTO dbarep_parameters
   ( param_name
   , param_value
   , valid
   )
 VALUES
   (
   'JOB_RESULTS_MONITORED_SCHEMAS'
   , 'DBMON'
   , 'Y'
   )
/

INSERT INTO dbarep_parameters
   ( param_name
   , param_value
   , valid
   )
 VALUES
   (
   'JOB_RESULTS_MONITORED_SCHEMAS'
   , 'PERFSTAT'
   , 'Y'
   )
/

COMMIT;