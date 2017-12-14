/*

 Name:          dbms_schedule_log_purge.sql

 Purpose:       Examples for DBMS_SCHEDULE

 Contents:		Example for purging the log for a specific job 

 Date            Who             Description

 15th Jun 2017	 Aidan Lawrence  Example clean up for git 
 
*/

--
-- To purge a log
--

BEGIN
      sys.dbms_scheduler.purge_log( job_name=>'TBSP_STATS_TARGET_JOB'
                               );
END;
/

