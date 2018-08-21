CREATE OR REPLACE PACKAGE BODY pkg_job_results_target
 as

/*

 Name:          cr_pkg_job_results_target_body.pkb

 Purpose:       PL/SQL Package job_results

 Usage:			Centralized DBMS_SCHEDULE monitoring
 
 Required Grants: 
 
  GRANT SELECT ON dba_scheduler_job_run_details TO dbmon;
  GRANT SELECT ON v_$database TO dbmon;
 
 Comments:

  Date            Who             Description

 15th Jul 2013	 Aidan Lawrence  Cloned from similar
 10th Oct 2017   Aidan Lawrence  Validated pre git  
 21st Aug 2018   Aidan Lawrence  Changed actual_start_time to insert based on TIMESTAMP from DATE to avoid duplicate error issues on insert

*/  
PROCEDURE pop_job_results_target
IS


c_module_name    CONSTANT VARCHAR2(30) := 'POP_JOB_RESULTS_TARGET';
v_error_message  VARCHAR2(4000);

BEGIN

	--
	-- Delete any results that will be repopulated based on c_job_results_gather_period
	--	
	
	DELETE FROM job_results
	WHERE actual_start_time > sysdate - pkg_job_results_target.c_job_results_gather_period;
	
	--
	-- Delete any results older than purge period
	--	
	
	DELETE FROM job_results
	WHERE actual_start_time < sysdate - pkg_job_results_target.c_job_results_purge_period;
	
	
-- Populate job_results from dba_scheduler_job_run_details restricted by:
-- 
-- 1) Schemas defined in dbarep_parameters
-- 2) Last n days where n is the package constant pkg_job_results_target.c_job_results_gather_period
--
-- While 'n' might plausibly be set to 1 if the table is refreshed daily, setting it to a value > 1 will remove any quirks due to jobs running over midnight, failures needing rerun etc.  

INSERT INTO job_results
	( dbname            
    , owner             
    , job_name          
    , actual_start_time 
    , log_time 		
    , run_duration 	
    , status 		
    , error# 		
    , additional_info
	)
SELECT 
   d.name AS dbname
,  jrd.owner
,  jrd.job_name
--,  to_date(to_char(jrd.actual_start_date,'Dy DD-MON-YYYY HH24:MI:SS'),'Dy DD-MON-YYYY HH24:MI:SS') as actual_start_time
,  jrd.actual_start_date
,  to_date(to_char(jrd.log_date,'Dy DD-MON-YYYY HH24:MI:SS'),'Dy DD-MON-YYYY HH24:MI:SS') as log_time
,  jrd.run_duration
,  jrd.status
,  jrd.error#
,  jrd.additional_info
FROM dba_scheduler_job_run_details jrd
CROSS JOIN v$database d 
WHERE jrd.owner IN (SELECT p.param_value
                FROM dbarep_parameters p
                WHERE p.param_name = 'JOB_RESULTS_MONITORED_SCHEMAS'
                AND   p.valid = 'Y'
                )
AND jrd.actual_start_date > sysdate - pkg_job_results_target.c_job_results_gather_period
;

--
-- All good 
COMMIT;

EXCEPTION
WHEN OTHERS
      THEN

        v_error_message :=  'Unknown Error ' || c_package_name || '.' || c_module_name || ' ' || sqlerrm;
        dbms_output.put_line (v_error_message);
		RAISE_APPLICATION_ERROR(-20001,v_error_message);

END pop_job_results_target;

END pkg_job_results_target;
/

SHOW ERRORS
