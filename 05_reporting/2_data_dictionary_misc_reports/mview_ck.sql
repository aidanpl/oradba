/*

 Name:          mview_ck.sql

 Purpose:       List information on materialized views

 Contents:      

 Date            Who             Description

 7th Oct 2004    Aidan Lawrence  Fresh Build
14th Sep 2009    Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication 
13th Mar 2013    Aidan Lawrence  Added youngest/oldest info
28th Sep 2017    Aidan Lawrence  Validated for git 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'mview_ck'
--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;
       
SELECT '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI') 
       || '.lst' spool_name      
  FROM v$database d;
  
SELECT 'Output report name is ' 
       || '&spool_name'
  FROM dual;  

spool &spool_name

prompt 
prompt Report Details are &spool_name                     
prompt

set heading off
set feedback off

SELECT 'Database Name: ' || value FROM v$parameter where name='db_name'
/

SELECT 'Generated On ' ||  to_char(sysdate,'dd Month YYYY  HH24:MI') today FROM dual
/

set heading on
set feedback on

/* Standard formatting for report */

prompt
prompt Materialised Views Refresh Time by Owner

SELECT 
  owner
, local_view
, master_owner 
, master_table
, compile_state
, local_refresh_time
, master_refresh_time
FROM mview_1_refresh_times
/

prompt
prompt Registered Child Materialised Views by Owner

SELECT
  child_view
, child_schema
, child_db
, updatable
FROM mview_2_reg_child_views
/

prompt
prompt Registered Local Materialised View groups 

SELECT
  local_name 
, child_site
FROM mview_3_local_groups
/


prompt
prompt Local Refresh Group Information

SELECT
owner
, name
, job
FROM mview_4_local_refresh_groups
/

prompt
prompt Local Refresh Information by owner by name 

SELECT
owner
, name
, master_owner
, master_name
, job
, next_date
, interval
, broken
FROM mview_5_local_refresh_info
/

prompt
prompt Repcat Information

SELECT
  sname
, is_master
, status
FROM mview_6_repcat
/

prompt
prompt Materialised View Logs by Owner by master date

SELECT 
  log_owner
, master_table
, log_table
, oldest
, youngest
FROM mview_7_mlog_summary
/

prompt
prompt Materialised Logs with entries older than 24 hours 

SELECT 
  master_owner
, master_table
, oldest
, youngest
FROM mview_8_mlog_old_entries
/

prompt Materialized logs with different youngest and oldest entries
prompt

SELECT
  log_owner
, master_table
, log_table
, oldest
, youngest
, size_mlog_mbytes
FROM mview_9_mlog_diff_entries
/

prompt
prompt Materialised View Filter columns by Owner by master date

SELECT 
  master_owner
, master_table
, column_name
FROM mview_10_filter_cols
/

prompt
prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

edit &spool_name
exit
