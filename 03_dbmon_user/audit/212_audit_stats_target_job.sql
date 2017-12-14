/*

 Name:          daily_audit_target_job.sql

 Purpose:       Job for for audit stats
 
 Usage:         Schedule this within the DBMON schema. 
 
 Date            Who             Description

 22nd Dec 2014   Aidan Lawrence  Cloned from similar
 28th Jun 2017   Aidan Lawrence  Validated for git 

*/

BEGIN

	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27475); 

	BEGIN

		dbms_scheduler.drop_job(
        job_name            => 'DAILY_AUDIT_TARGET_JOB'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_job(
    job_name            => 'DAILY_AUDIT_TARGET_JOB'   -- Job Name
  , schedule_name       => 'DAILY_AUDIT_TARGET_SCH'   -- When to run
  , job_type       		=> 'STORED_PROCEDURE'			 -- What type of module
  , job_action      	=> 'PKG_AUDIT_STATS_TARGET.RUN_DAILY_AUDIT' -- Which Module
  , job_class           => 'DEFAULT_JOB_CLASS'
  , number_of_arguments => 0
  , enabled             => TRUE
  , comments            => 'Job to populate/purge from audit_stats and purge from sys.aud$'
  , auto_drop           => FALSE
  );
   
end;
/ 