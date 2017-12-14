/*

 Name:          rman_report_job.sql

 Purpose:       Execute existing job
 
 Usage:         Just run it...
 
 Date            Who             Description

 22nd Dec 2014   Aidan Lawrence  Cloned from similar

*/
BEGIN

      sys.dbms_scheduler.run_job(  job_name=>'RMAN_REPORT_JOB'
                                 , use_current_session => FALSE
                               );
END;
/


