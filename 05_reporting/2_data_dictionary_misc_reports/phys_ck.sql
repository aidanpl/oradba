/*

 Name:          phys_ck.sql

 Purpose:       List all physical files associated with the database

 Contents:      Lists data files
                Lists redo log files
                Lists control files
                Lists archive log information
                Lists path names in use

 Date            Who             Description

 1st May 2002    Aidan Lawrence  General Review/Tidy up for WCC
 8th Aug 2002    Aidan Lawrence  Added tempfiles to list
14th Sep 2009    Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication
11th Feb 2015    Aidan Lawrence  Increased some column sizes to reflect new standard directories
31st May 2016    Aidan Lawrence  Added in file_id
 5th Apr 2017    Aidan Lawrence  Changed to access from views and col definitions to login.sql  
*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'phys_ck'
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

set heading on

-- See login.sql for col definitions 

prompt
prompt Data Files Associated With This Database

select 
  file_id
, file_name
, tablespace_name
, file_status
, mbytes
, max_mbytes
, extendable
from phys_1_data_files
/


prompt
prompt Temp Files Associated With This Database

select 
  file_id
, file_name
, file_status
, tablespace_name
, mbytes
, max_mbytes
, extendable
from phys_2_temp_files
order by tablespace_name
, file_name
/

prompt
prompt Redo/Standby Log Files

SELECT 
  redo_type
, redo_group
, redo_member 
, file_status
FROM phys_3_redo_files
ORDER BY 
  redo_type
, redo_group
, redo_member
/

prompt
prompt Control Files

SELECT 
  file_name
, file_status
FROM phys_4_control_files
/

prompt
prompt Destination directories

SELECT 
  parameter_value
, parameter_name
FROM phys_5_destinations
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit
