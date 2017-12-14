/*

 Name:          redo_logs_ck.sql

 Purpose:       State of the current redo and recent archive log history 

 Contents:  

 Date            Who             Description

14th Sep 2009    Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication 
31st May 2016    Aidan Lawrence  Changed to access from views and col definitions to login.sql  
*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'redo_logs_ck'
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
--
-- Online redo logs
--

prompt
prompt Current state of redo logs

SELECT 
  redo_group
, redo_sequence 
, status as redo_status 
, archived
, log_mbytes as mbytes
, log_time as log_start_time 
from redo_1_online_logs 
order by log_time desc
/

prompt
prompt Recovery Area Usage 

SELECT 
  file_type 
, percent_space_used
, percent_space_reclaimable
, percent_space_not_reclaimable
, number_of_files
FROM redo_3_recovery_area_usage
;

prompt
prompt Redo Destinations

SELECT 
  dest_name
, destination as redo_destination
, status 
, error
, target
, valid_type
, valid_role 
, log_sequence  as redo_sequence
, fail_sequence
FROM
  redo_2_destinations
;

prompt
prompt Redo switches per hour 

SELECT 
  Hour     as date_hour
, switches as number_of_switches
from redo_4_log_switches_per_hour
;

prompt
prompt Recent redo log history 

SELECT sequence#
, log_time as log_start_time
FROM redo_6_log_history_recent
/

prompt
prompt Recent archive log history 

--
-- NB Be careful of the numbers here - can get duplicate entries v$archived_log

SELECT
  sequence#  as redo_sequence                                       
, archive_log_start_time
, archive_log_end_time
, archive_log_size
FROM redo_7_archive_history_recent
/


prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit
