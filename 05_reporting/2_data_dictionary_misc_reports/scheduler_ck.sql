/*

 Name:          scheduler_ck.sql

 Purpose:       General DBMS_SCHEDULER information

 Contents:

 Date           Who             Description

 29th Mar 2016  Aidan Lawrence  Combination of various adhoc scripts
 19th Apr 2017  Aidan Lawrence  Changed to access from views and col definitions to login.sql   

*/

-- Set up environment
-- See login.sql for basic formatting

set heading off
set termout off

define script_name = 'scheduler_ck'

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '


--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI')
       || '.lst' spool_name
  from v$database d;

select 'Output report name is '
       || '&spool_name'
  from dual;

spool &spool_name

prompt
prompt Report Details are &spool_name
prompt

--
-- Main report begins
--

set heading on

prompt 
prompt Most recent job runs                        

SELECT   
  owner
, job_name
, start_time
, duration
, end_time
, job_status
FROM job_1_most_recent_runs
/

prompt 
prompt Future Schedule                             #

-- Specific increased linesize here due to large repeat_interval column
set lines 240

SELECT  
  owner
, job_name
, enabled
, next_run_date
, schedule_name
, repeat_interval
from job_2_future_schedule
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
