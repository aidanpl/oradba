/*

 Name:          job_failures_ck.sql

 Purpose:       Check for recently failed jobs 
 
 Usage:         job_failures_ck.sql <time_limit> where time_limit represents a number of days 

 Date            Who             Description

 12th Sep 2017   Aidan Lawrence  Validated for git

*/

-- Set up environment
      

set heading off
set verify off 
set feedback off
set trimspool on
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

define script_name = 'job_failures_ck'
define time_limit = &1

--
-- As this is directly called for monitoring keep spool simple 
--
spool &script_name

set termout on
set feedback on
set heading on 
set pages 99
set linesize 172

column owner    	   format a20 heading 'Owner'
column job_name 	   format a30 heading 'job_name'
column status 		   format a15 heading 'status'
column error# 		   format 99999 heading 'error#'
column start_time 	   format a25 heading 'start time'
column additional_info format a50 heading 'Information'

SELECT 
   owner
,  job_name
,  status
,  error#
,  to_char(actual_start_date,'Dy DD-MON-YYYY HH24:MI:SS') as start_time
,  additional_info
FROM dba_scheduler_job_run_details
WHERE error# > 0
AND actual_start_date > sysdate - &time_limit 
ORDER BY actual_start_date desc;
	
spool off 
exit
