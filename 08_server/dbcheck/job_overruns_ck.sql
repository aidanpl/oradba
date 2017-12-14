/*

 Name:          job_overruns_ck.sql

 Purpose:       Check for overrunning jobs 
 
 Usage:         job_overruns_ck.sql <overrun_limit) where overrun_limit represents a number of mins 

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

define script_name = 'job_overruns_ck'
define overrun_limit = &1 

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
column start_time 	   format a25 heading 'start time'
column elapsed_time    format a25 heading 'Elapsed|Display time'
column elapsed_mins    format 999 heading 'Elapsed|Minutes'

SELECT 
owner
, job_name
, start_time
, elapsed_time
, elapsed_mins
FROM
(SELECT owner
, job_name
, elapsed_time
, sysdate - elapsed_time as start_time
, round((sysdate - (sysdate - elapsed_time))*1440,1) as elapsed_mins
FROM all_scheduler_running_jobs
)
where elapsed_mins > &overrun_limit
/

spool off 
exit
