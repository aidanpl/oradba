/*

 Name:          PURGE_DBA_RECYCLEBIN_one_off_run_job.sql

 Purpose:       Execute existing job 
 
 Usage:         Just run it :-)
 
 Date            Who             Description

 31st Aug 2017   Aidan Lawrence  Validated for git 
 

*/
BEGIN

      sys.dbms_scheduler.run_job(  job_name=>'PURGE_DBA_RECYCLEBIN_JOB'
                                 , use_current_session => FALSE
                               );
END;
/


