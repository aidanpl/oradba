/*

 Name:          tbsp_stats_3_hwm_summary_ck.sql

 Purpose:       Driving script for tbsp_stats_3_hwm_summary view 

 Contents:  

 Date            Who             Description

15th Jul 2017    Aidan Lawrence  Validated for git

*/

-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'tbsp_stats_3_hwm_summary_ck'
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
prompt ###############################################################
prompt #                                                             #
prompt #  Tablespace HWM Summary                                     #
prompt #                                                             #
prompt ###############################################################
prompt

SELECT 
  dbname
, generated_date
, tablespace_name
, mbytes_highwatermark  
, mbytes_current     
, mbytes_reclaimabile
, recyclebin_objects
FROM tbsp_stats_3_hwm_summary
;

prompt
prompt end of report

spool off


-- Leave edit commented out if running from batch

--edit &spool_name
exit
