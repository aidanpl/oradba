/*

 Name:          statspack_snap_purge_job.sql

 Purpose:       Job for statspack snapshot purge
 
 Usage:         Schedule this within the PERFSTAT schema. 
 
 Pre-Requirements: Equivalent schedule STATSPACK_SNAP_PURGE_SCH exists
 
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
        job_name            => 'STATSPACK_SNAP_PURGE_JOB'
		);
    		
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
	END;

dbms_scheduler.create_job(
    job_name            => 'STATSPACK_SNAP_PURGE_JOB' -- Job Name
  , schedule_name       => 'STATSPACK_SNAP_PURGE_SCH' -- When to run
  , job_type       		=> 'PLSQL_BLOCK'	          -- What type of module
  , job_action      	=> 'BEGIN statspack.purge(14); END;'  -- Code to run including parameters
  , job_class           => 'DEFAULT_JOB_CLASS'
  , number_of_arguments => 0						  -- How many arguments this procedure expects
  , enabled             => TRUE					      -- Need to set status to FALSE to allow arguments to be provided
  , comments            => 'Job to to control statspack snapshot purge'
  , auto_drop           => FALSE
  );
 

end;
/ 


