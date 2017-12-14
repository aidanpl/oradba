/*

 Name:          rman_report_job.sql

 Purpose:       Job for RMAN Reporting 
 
 Usage:         Schedule this within the DBMON schema. 
 
 Date            Who             Description

 22nd Dec 2014   Aidan Lawrence  Cloned from similar
 28th Jun 1017   Aidan Lawrence  Validated for git   

*/

BEGIN

	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27475); 

	BEGIN

		dbms_scheduler.drop_job(
        job_name            => 'RMAN_REPORT_JOB'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_job(
    job_name            => 'RMAN_REPORT_JOB'   -- Job Name
  , schedule_name       => 'RMAN_REPORT_SCH'   -- When to run
  , job_type       		=> 'STORED_PROCEDURE'			 -- What type of module
  , job_action      	=> 'PKG_RMAN_REP.RMAN_REP_RMAN_REPORT' -- Which Module
  , job_class           => 'DEFAULT_JOB_CLASS'
  , number_of_arguments => 0
  , enabled             => TRUE
  , comments            => 'Job for RMAN Reporting'
  , auto_drop           => FALSE
  );
   
end;
/ 