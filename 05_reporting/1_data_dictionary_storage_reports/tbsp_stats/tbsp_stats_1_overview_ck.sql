/*

 Name:          tbsp_stats_1_overview_ck.sql

 Purpose:       Driving script for tbsp_stats_1_overview view 

 Contents:  

 Date            Who             Description

15th Jul 2017    Aidan Lawrence  Validated for git

*/

-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'tbsp_stats_1_overview_ck'
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
prompt #  Tablespace Overview                                        #
prompt #                                                             #
prompt ###############################################################
prompt

set heading on

select 
  dbname
, generated_date
, tablespace_name
, mbytes_used
, mbytes_free_no_extend
, mbytes_max_no_extend
, pct_free_no_extend
, mbytes_free_with_extend
, mbytes_max_with_extend
, pct_free_with_extend
 FROM tbsp_stats_1_overview
;

prompt
prompt end of report

spool off


-- Leave edit commented out if running from batch

--edit &spool_name
exit
