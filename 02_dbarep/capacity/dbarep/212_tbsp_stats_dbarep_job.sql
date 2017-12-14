/*

 Name:          TBSP_STATS_DBAREP_job.sql

 Purpose:       Job or tbsp_stats within dbarep 
 
 Usage:         Schedule this within the DBMON schema. 
 
 Date            Who             Description

 22nd Dec 2014   Aidan Lawrence  Cloned from similar
  8th Jun 2017   Aidan Lawrence  Validated pre git  

*/

BEGIN

	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27475); 

	BEGIN

		dbms_scheduler.drop_job(
        job_name            => 'TBSP_STATS_DBAREP_JOB'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_job(
    job_name            => 'TBSP_STATS_DBAREP_JOB'   -- Job Name
  , schedule_name       => 'TBSP_STATS_DBAREP_SCH'   -- When to run
  , job_type       		=> 'STORED_PROCEDURE'			 -- What type of module
  , job_action      	=> 'PKG_TBSP_STATS_DBAREP.POP_TBSP_STATS_ALL' -- Which Module
  , job_class           => 'DEFAULT_JOB_CLASS'
  , number_of_arguments => 0
  , enabled             => TRUE
  , comments            => 'Job to populate tbsp_stats for all monitored databases'
  , auto_drop           => FALSE
  );
   
end;
/ 

