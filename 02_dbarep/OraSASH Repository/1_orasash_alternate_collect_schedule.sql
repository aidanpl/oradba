/*

 Name:          orasash_alternate_collect_schedule.sql

 Purpose:       schedule for job SASH_PKG_COLLECT_<instance>_<dbid>
 
 Usage:         Default OraSASH implementation job schedules the job with an hourly interval.
				
				Experience has shown that this job can run for more than one hour. 
				
				To allow more fine control over when this job runs this is an example schedule than can be applied to the job if desired.
				
				The job name includes the DBID so manually change this script as appropriate on implementation.
 
 Date            Who             Description

 19th Dec 2017	 Aidan Lawrence  Ongoing improvement
*/

BEGIN

	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27476); 

	BEGIN

		dbms_scheduler.drop_schedule(
        schedule_name            => 'SASH_COLLECT_1_1234567890_SCH'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_schedule(
    schedule_name       => 'SASH_COLLECT_1_1234567890_SCH'
  , start_date          => to_timestamp('19-DEC-2017 11:30','DD-MON-YYYY HH24:MI')
  , repeat_interval     => 'FREQ=DAILY; BYHOUR=01,03,05,07,09,11,13,15,17,19,23; BYMINUTE=30; BYSECOND=00;'
  , end_date            => to_timestamp('31-DEC-2099 0:00','DD-MON-YYYY HH24:MI')
  , comments            => 'Schedule to control OraSASH Collection'
    );

END;
/  