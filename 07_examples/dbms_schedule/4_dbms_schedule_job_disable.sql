/*

 Name:          dbms_schedule_job_disable.sql

 Purpose:       Examples for DBMS_SCHEDULE

 Contents:		Example for disabling a job 

 Date            Who             Description

 15th Jun 2017	 Aidan Lawrence  Example clean up for git 
 
*/

--
-- To disable a currently enabled job:
--

BEGIN
      sys.dbms_scheduler.disable( name=>'TBSP_STATS_TARGET_JOB'
                               );
END;
/

