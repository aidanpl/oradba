/*

 Name:          purge_dba_recyclebin_schedule.sql

 Purpose:       schedule for purge of recyclebin
 
 Usage:         Schedule this within the SYS schema. 
 
 Pre-Requirements: Schema must have been GRANTED the SCHEDULER_ADMIN role 
				e.g. GRANT SCHEDULER_ADMIN to SYS;
 
  Date            Who             Description

  31st Aug 2017   Aidan Lawrence  Validated for git 

*/

BEGIN

	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27475); 

	BEGIN

		dbms_scheduler.drop_job(
        job_name            => 'PURGE_DBA_RECYCLEBIN_JOB'
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
        schedule_name            => 'PURGE_DBA_RECYCLEBIN_SCH'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_schedule(
    schedule_name       => 'PURGE_DBA_RECYCLEBIN_SCH'
  , start_date          => to_timestamp('31-AUG-2017 21:00','DD-MON-YYYY HH24:MI')
  , repeat_interval     => 'FREQ=DAILY; BYHOUR=21; BYMINUTE=00; BYSECOND=00;'
  , end_date            => to_timestamp('31-DEC-2099 0:00','DD-MON-YYYY HH24:MI')
  , comments            => 'Schedule to control purge of recyclebin'
    );

END;
/  