/*

 Name:          dataguard_ck_dbmon.sql

 Purpose:       Monitor state of dataguard - suitable for both primary only.
                Like most scripts this does uses views instead of reading the data dictionary directly. This is a requirement where sysdba is not available for whatever reason. It does mean this script can only be used against the primary database. 
 
                Also see dataguard_ck_sysdba for both primary and secondary monitoring where sysdba available.

 Contents:  

 Date            Who             Description

26th Apr 2013    Aidan Lawrence  Inspired by suggestions in Oracle documentation..
18th Aug 2016    Aidan Lawrence  Changed to access col definitions to login.sql
 2nd May 2017    Aidan Lawrence  Cloned from dataguard_ck for view access 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'dataguard_ck_dbmon'
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

set heading on

-- See login.sql for col definitions 
	  
--
-- Main report begins
--

set heading on

prompt
prompt Databases in Dataguard config

SELECT db_unique_name
FROM dg_1_dbs 
/

prompt
prompt Dataguard modes, switchover states etc. 

SELECT 
  db_name 
, db_unique_name  
, database_role 
, current_scn
, archive_change#
, switchover_status 
, dataguard_broker
, protection_level
FROM dg_2_dbmode_states 
/

prompt
prompt Fast Start Failover Status 

SELECT 
  fs_failover_status 
, fs_failover_current_target target 
, fs_failover_threshold  
, fs_failover_observer_present 
FROM dg_3_fail_over_status
/

prompt
prompt Archive log gaps - if working ok - should return no rows

-- Deliberately wrap this around a feedback on/off to see the no rows returned response.
set feedback on 

SELECT 
  low_sequence#
, high_sequence#
  FROM dg_4_archive_gap
/

set feedback off 

prompt
prompt Active archive destinations

SELECT 
dest_id
, dest_name
, destination
, target 
, status
, log_sequence#
, process
, fail_time 
, fail_sequence
, failure_count 
, max_failure
, error 
, transmit_mode
, valid_type
, valid_role
FROM dg_5_archive_dest
/

prompt
prompt General archive status

SELECT
  db_unique_name
, dest_name
, status
, type
, database_mode
, recovery_mode
, protection_mode
, archived_seq#
, applied_seq#
, error
, destination
, synchronization_status
, synchronized
, gap_status
FROM dg_6_archive_dest_status
/

prompt
prompt  Redo Apply and redo transport status on a physical standby database

SELECT 
  process
, pid
, client_process
, client_pid
, status
, sequence#
, blocks 
FROM dg_7_redo_app_transport
/

prompt 
prompt Current state of logs - both online and standby

SELECT
  type 
, group#
, member  
, bytes
, sequence#
, archive_status 
, first_time
, next_time
, last_time
FROM dg_8_redo_current
/

prompt 
prompt Archived redo log files that have been received by a physical or snapshot standby database FROM a primary database:

SELECT 
  sequence#
, log_start_time
, dest_id
, archive_status    
, standby_dest
, archived
, registrar
, applied
FROM dg_9_redo_status
/

prompt
prompt Dataguard Status Log last 12 hours 

SELECT
  facility
, severity   
, message_time
, error_code
, message
FROM dg_10_log_dg_status
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

--edit &spool_name
exit
