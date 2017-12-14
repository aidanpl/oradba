/*

 Name:          instance_ck.sql

 Purpose:       General report for instance level parameters

 Contents:      General Instance details including startup time and archive mode
				Session usage including highwatermark
				
				See related scripts under tuning directory such as instance_tune_ck for general advice and sga_pga_ck for memory sizing 
 
 Date            Who             Description

 1st May 2002	 Aidan Lawrence  General Review/Tidy up for WCC
14th Sep 2009    Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication 
21st Sep 2016    Aidan Lawrence  SGA and PGA measurements enhanced and moved to separate sga_pga_ck.sql script
11th Apr 2017   Aidan Lawrence  Changed to access from views and col definitions to login.sql   

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'instance_ck'
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
-- Don't need feedback for instance_ck
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
FROM inst_1_instance;

prompt
prompt Licensing details

SELECT
  sessions_current
, sessions_highwater
, sessions_max
, cpu_count_highwater
from inst_2_license;

prompt
prompt Instance non default Parameter Listing

select 
  parameter_name
, parameter_display_value
, parameter_description  
, parameter_modified
, parameter_modifiable 
FROM inst_3_param_nondefault
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
