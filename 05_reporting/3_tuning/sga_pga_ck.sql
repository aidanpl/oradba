/*

 Name:          sga_pga_ck.sql

 Purpose:       SGA and PGA sizing report 

 Contents:      
 
 Date            Who             Description

21st Sep 2016    Aidan Lawrence  SGA and PGA measurements split off FROM instance_ck script
27th Sep 2017    Aidan Lawrence  Validated for git  

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'sga_pga_ck'
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
set feedback on 

prompt
prompt SGA Size

SELECT 
  sga_component_name
, component_size_mb
, resizeable      
FROM sga_1_info
/

prompt
prompt SGA Component Size and most recent change

SELECT 
  sga_component_name
, current_size_mb
, min_size_mb
, max_size_mb
, last_oper_type
, disp_last_oper_time
FROM sga_2_dyn_components
/

prompt
prompt SGA resize operations in last four weeks

SELECT 
  sga_component_name
, final_size_mb
, target_size_mb
, initial_size_mb
, oper_type
, oper_start_time
FROM sga_3_resize
/

prompt
prompt SGA Target Advice

SELECT 
  sga_size
, sga_size_factor
, estd_db_time
, estd_db_time_factor
, estd_physical_reads
FROM sga_4_target_advice
/


prompt
prompt PGA Statistics

SELECT 
  pga_component_name
, component_size_mb
FROM pga_1_info
/

prompt
prompt PGA Target Advice

SELECT 
  pga_target_for_estimate
, pga_target_factor
, estd_time
, estd_pga_cache_hit_percentage
FROM pga_2_target_advice
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

edit &spool_name
exit
