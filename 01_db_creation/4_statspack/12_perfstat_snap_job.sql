/*

 Name:          statspack_snap_job.sql

 Purpose:       Job for statspack snap
 
 Usage:         Schedule this within the PERFSTAT schema. 
 
 Pre-Requirements: Equivalent schedule STATSPACK_SNAP_SCH exists
 
 Date            Who             Description

 12th Dec 2014   Aidan Lawrence  Converted from DBMS_JOB
 15th Jun 2017	 Aidan Lawrence  Example clean up for git  
*/

BEGIN

	DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27475); 

	BEGIN

		dbms_scheduler.drop_job(
        job_name            => 'STATSPACK_SNAP_JOB'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_job(
    job_name            => 'STATSPACK_SNAP_JOB' -- Job Name
  , schedule_name       => 'STATSPACK_SNAP_SCH' -- When to run
  , job_type       		=> 'STORED_PROCEDURE'	-- What type of module
  , job_action      	=> 'STATSPACK.SNAP'     -- Which Module
  , job_class           => 'DEFAULT_JOB_CLASS'
  , number_of_arguments => 0
  , enabled             => TRUE
  , comments            => 'Job to to control statspack snap'
  , auto_drop           => FALSE
  );
   
end;
/ 