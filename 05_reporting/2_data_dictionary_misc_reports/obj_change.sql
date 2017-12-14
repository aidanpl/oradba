/* 

 Name:          obj_change.sql

 Purpose:       List any object changes in the last 7 days

 Usage:     	Useful for spotting changes on the system when troubleshooting

 Date            Who             Description

 1st May 2002	 Aidan Lawrence  General Review/Tidy up for WCC
25th Jul 2002    Aidan Lawrence  Increased size of some columns
14th Sep 2009    Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication 
11th Apr 2017    Aidan Lawrence  Changed to access from views and col definitions to login.sql   
*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'obj_change'
--
-- Set the Spool output name as combination of script, database AND time
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
--
-- Main report begins
--

set heading on
set feedback on

prompt
prompt Objects created in the last 7 days.

SELECT 
  creation_time
, owner
, object_name
, object_type
FROM obj_31_created_recent
/

prompt
prompt Objects changed in the last 7 days.

SELECT 
  ddl_time
, owner
, object_name
, object_type
FROM obj_32_changed_recent
/

prompt
prompt mviews refreshed in the last 7 days.

SELECT 
  ddl_time
, owner
, object_name
, object_type
FROM obj_33_mview_refreshes
/

prompt
prompt jobs run in the last 7 days.

SELECT 
  ddl_time
, owner
, object_name
, object_type
FROM obj_34_job_runs
/

prompt
prompt partition creation in the last 7 days.

SELECT 
  owner
, object_name
, object_type
, partition_count
, creation_time
FROM obj_35_partition_changes
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

edit &spool_name
exit
