/*

 Name:          11_datafile_highwatermark_schedule.sql

 Purpose:       schedule for tablespace stats
 
 Usage:         Schedule this within the DBMON schema. 
 
 Pre-Requirements: Schema must have been GRANTED the SCHEDULER_ADMIN role 
				e.g. GRANT SCHEDULER_ADMIN to DBMON;
 
 Date            Who             Description

 22nd Dec 2014   Aidan Lawrence  Cloned from similar
 8th Jun 2017    Aidan Lawrence  Validated pre git  

*/

BEGIN

	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27475); 

	BEGIN

		dbms_scheduler.drop_job(
        job_name            => 'FILE_HIGHWATERMARK_JOB'
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
        schedule_name            => 'FILE_HIGHWATERMARK_SCH'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_schedule(
    schedule_name       => 'FILE_HIGHWATERMARK_SCH'
  , start_date          => to_timestamp('15-JAN-2017 09:00','DD-MON-YYYY HH24:MI')
  , repeat_interval     => 'FREQ=WEEKLY; BYDAY=SUN; BYHOUR=08; BYMINUTE=00; BYSECOND=00;'
  , end_date            => to_timestamp('31-DEC-2099 0:00','DD-MON-YYYY HH24:MI')
  , comments            => 'Schedule to populate datafile_highwatermark'
    );

END;
/  



