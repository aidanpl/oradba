/*

 Name:          transaction_ck.sql

 Purpose:       List current transaction activity with any longops 

 Date            Who             Description

 14th May 2008   Aidan Lawrence  New Script
 10th Dec 2015   Aidan Lawrence  Added in server pid  
 20th Apr 2017   Aidan Lawrence  Changed to access from views and col definitions to login.sql  

*/

-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'transaction_ck'
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

set heading off
set feedback off 

SELECT 'Database Name: ' || value FROM v$parameter where name='db_name'
/

SELECT 'Generated On ' ||  to_char(sysdate,'dd Month YYYY  HH24:MI') today from dual
/

set heading on
set feedback on 

/* Standard formatting for report */

prompt 
prompt Current Transaction activity                          

SELECT 
  status 
, processname 
, osuser 
, schemaname 
, ses_start_time 
, pga_used_mb 
, pga_alloc_mb 
, program 
, event 
, wait_time 
, seconds_in_wait 
, state 
, tran_start_time 
, undo_blocks 
, log_io 
, phy_io 
, sid 
, serial# 
, os_process
FROM trn_1_current_transactions
--where s.program not like 'oracle%' -- uncomment to ignore background tasks
/

prompt 
prompt Long ops activity

 SELECT
  sid
, status
, target
, opname
, update_time
, oper_start_time
, percent_complete
, mins_elapsed
, mins_remaining
--, sofar
--, totalwork
--, units
--, message
, osuser
, schemaname
, username
, sql_id
FROM trn_2_longops 
/

prompt
prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
