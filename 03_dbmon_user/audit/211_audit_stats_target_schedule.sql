
/*

 Name:          daily_audit_target_schedule.sql

 Purpose:       schedule for audit stats
 
 Usage:         Schedule this within the DBMON schema. 
 
 Pre-Requirements: Schema must have been GRANTED the SCHEDULER_ADMIN role 
				e.g. GRANT SCHEDULER_ADMIN to DBMON;
 
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


	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27476); 

	BEGIN

		dbms_scheduler.drop_schedule(
        schedule_name            => 'DAILY_AUDIT_TARGET_SCH'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_schedule(
    schedule_name       => 'DAILY_AUDIT_TARGET_SCH'
  , start_date          => to_timestamp('28-JUN-2017 01:00','DD-MON-YYYY HH24:MI')
  , repeat_interval     => 'FREQ=DAILY; BYHOUR=01; BYMINUTE=00; BYSECOND=00;'
  , end_date            => to_timestamp('31-DEC-2099 0:00','DD-MON-YYYY HH24:MI')
  , comments            => 'Schedule to populate audit_stats on target'
    );

END;
/  



