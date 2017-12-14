/*

 Name:          dbms_schedule_one_off_run.sql

 Purpose:       Examples for DBMS_SCHEDULE

 Contents:

 Date            Who             Description

 15th Jun 2017	 Aidan Lawrence  Example clean up for git 

*/
--
-- To do a one off run of an existing job
--


BEGIN
      sys.dbms_scheduler.run_job(  job_name=>'TBSP_STATS_TARGET_JOB'
                                 , use_current_session => FALSE
                               );
END;
/

