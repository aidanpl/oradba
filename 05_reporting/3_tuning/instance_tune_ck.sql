/*

 Name:          instance_tune_ck.sql

 Purpose:       Instance Tuning 

 Contents:      
 
 Date            Who             Description

  1st May 2002   Aidan Lawrence  Refresh from misc scripts 
 17th Aug 2010   Aidan Lawrence  Add values of key tuning parameters
 27th Sep 2017   Aidan Lawrence  Refresh and validate for git 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'instance_tune_ck'
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

set heading off
set feedback off 

SELECT 'Database Name: ' || value FROM v$parameter where name='db_name'
/

SELECT 'Generated On ' ||  to_char(sysdate,'dd Month YYYY  HH24:MI') today FROM dual
/

set heading on
set feedback off 

prompt
prompt Instance details

SELECT
  instance_name
, host_name
, version
, last_start
, instance_role
, status 
FROM inst_1_instance
/

prompt
prompt Instance Core tuning parameters 

SELECT 
  parameter_name
, parameter_display_value
, parameter_description  
, parameter_modified
, parameter_modifiable 
FROM inst_4_core_parameters
/

--prompt
--prompt Buffer Cache Hit ratio

SELECT 
  buffer_cache_hit_ratio
FROM inst_5_db_buf_cache_ratio
/

--prompt
--prompt Dictionary Cache Miss ratio

SELECT 
  dd_cache_miss_ratio
FROM inst_6_dict_cache_ratio
/

--prompt
--prompt Library Cache Miss ratio

SELECT 
  lib_cache_miss_ratio
FROM inst_7_lib_cache_ratio
/

prompt
prompt Redo Log Latches

SELECT 
  latch_name
, redo_gets
, redo_misses
, redo_im_gets
, redo_im_misses
FROM inst_8_redo_log_latches
/

--prompt
--prompt Redo Space Requests

SELECT 
  stat_name
, stat_value   
FROM inst_9_redo_space_req
/

prompt
prompt Sort Memory Contention

SELECT 
  stat_name
, stat_value   
FROM inst_10_sort_mem_contention
/

prompt
prompt Sort Segments

SELECT 
  tablespace_name
, sort_total_mb
, sort_used_mb
, sort_free_mb
FROM inst_11_sort_segs
/

prompt
prompt Sort Sessions

SELECT
  schemaname
, osuser
, sid
, stat_name
, stat_value 
FROM inst_12_sort_sessions
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

edit &spool_name
exit
