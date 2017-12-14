/*

 Name:          statspack_snap_purge_one_off_run_job.sql

 Purpose:       Execute existing job 
 
 Usage:         Just run it :-)
 
 Date            Who             Description

 12th Dec 2014   Aidan Lawrence  Converted from DBMS_JOB
 15th Jun 2017	 Aidan Lawrence  Example clean up for git  

*/
BEGIN

      sys.dbms_scheduler.run_job(  job_name=>'STATSPACK_SNAP_PURGE_JOB'
                                 , use_current_session => FALSE
                               );
END;
/


