/*

 Name:          dbms_schedule_job_enable.sql

 Purpose:       Examples for DBMS_SCHEDULE

 Contents:		Example for enabling a job 

 Date            Who             Description

 15th Jun 2017	 Aidan Lawrence  Example clean up for git 
 
*/

--
-- To enable a currently disabled job:
--

BEGIN
      sys.dbms_scheduler.enable( name=>'TBSP_STATS_TARGET_JOB'
                               );
END;
/

