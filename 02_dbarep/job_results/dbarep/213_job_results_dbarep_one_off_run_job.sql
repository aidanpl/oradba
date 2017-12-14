/*

 Name:          job_results_dbarep_job.sql

 Purpose:       Execute existing job
 
 Usage:         Just run it...
 
 Date            Who             Description

 22nd Dec 2014   Aidan Lawrence  Cloned from similar
 17th Oct 2017   Aidan Lawrence  Validated pre git  

*/
BEGIN

      sys.dbms_scheduler.run_job(  job_name=>'JOB_RESULTS_DBAREP_JOB'
                                 , use_current_session => FALSE
                               );
END;
/


