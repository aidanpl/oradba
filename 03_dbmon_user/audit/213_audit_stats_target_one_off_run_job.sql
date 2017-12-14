/*

 Name:          daily_audit_target_job.sql

 Purpose:       Execute existing job
 
 Usage:         Just run it...
 
 Date            Who             Description

 22nd Dec 2014   Aidan Lawrence  Cloned from similar
 28th Jun 2017   Aidan Lawrence  Validated for git 

*/

/*

--
-- Option to purge a log if cleaning up failures 
--

BEGIN
      sys.dbms_scheduler.purge_log( job_name=>'DAILY_AUDIT_TARGET_JOB'
                               );
END;
/

*/

BEGIN

      sys.dbms_scheduler.run_job(  job_name=>'DAILY_AUDIT_TARGET_JOB'
                                 , use_current_session => FALSE
                               );
END;
/


