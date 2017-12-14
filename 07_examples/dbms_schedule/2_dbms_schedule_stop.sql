/*

 Name:          dbms_schedule_job_stop.sql

 Purpose:       Examples for DBMS_SCHEDULE

 Contents:

 Date            Who             Description

 15th Jun 2017	 Aidan Lawrence  Example clean up for git  

*/

--
-- To stop a currently running job - gracefully 


BEGIN
      sys.dbms_scheduler.stop_job(  job_name=>'TBSP_STATS_TARGET_JOB'
                                  , force => FALSE
                               );
END;
/

--
-- To stop a currently running job - ungracefully - only try if force=FALSE fails


BEGIN
      sys.dbms_scheduler.stop_job(  job_name=>'TBSP_STATS_TARGET_JOB'
                                  , force => TRUE
                               );
END;
/



