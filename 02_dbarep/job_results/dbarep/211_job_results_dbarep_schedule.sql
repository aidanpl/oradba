/*

 Name:          job_results_dbarep_schedule.sql

 Purpose:       schedule for job_results within dbarep 
 
 Usage:         Schedule this within the DBMON schema. 
 
 Pre-Requirements: Schema must have been GRANTED the SCHEDULER_ADMIN role 
				e.g. GRANT SCHEDULER_ADMIN to DBMON;
 
 Date            Who             Description

 22nd Dec 2014   Aidan Lawrence  Cloned from similar
 17th Oct 2017   Aidan Lawrence  Validated pre git  
  
*/

BEGIN

	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27475); 

	BEGIN

		dbms_scheduler.drop_job(
        job_name            => 'JOB_RESULTS_DBAREP_JOB'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;


	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27476); 

	BEGIN

		dbms_scheduler.drop_schedule(
        schedule_name            => 'JOB_RESULTS_DBAREP_SCH'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_schedule(
    schedule_name       => 'JOB_RESULTS_DBAREP_SCH'
  , start_date          => to_timestamp('17-JUN-2017 08:00','DD-MON-YYYY HH24:MI')
  , repeat_interval     => 'FREQ=WEEKLY; BYDAY=SUN; BYHOUR=10; BYMINUTE=00; BYSECOND=00;'
  , end_date            => to_timestamp('31-DEC-2099 0:00','DD-MON-YYYY HH24:MI')
  , comments            => 'Schedule to populate job_results for all monitored databases'
    );

END;
/  

