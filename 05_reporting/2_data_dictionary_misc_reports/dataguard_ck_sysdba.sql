/*

 Name:          dataguard_ck_sysdba.sql

 Purpose:       Monitor state of dataguard - suitable for both primary and secondary roles.
                Unlike most scripts this does not use views but instead reads the data dictionary directly. This is a requirement for secondary roles where the database is not fully open, so access via a dbmon type user with views is unavailable. 
				
				Also see dataguard_ck_dbmon for primary monitoring where sysdba unavailable.

 Contents:  

 Date            Who             Description

26th Apr 2013    Aidan Lawrence  Inspired by suggestions in Oracle documentation..
18th Aug 2016    Aidan Lawrence  Changed to access col definitions to login.sql  ** APL ** Outstanding to move this to views and status.cgi 
 2nd May 2017    Aidan Lawrence  Renamed from dataguard_ck where sysdba access is available for monitoring both primary and secondary 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'dataguard_ck_sysdba'
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
-- Main report begins
--

set heading on

prompt
prompt Dataguard config


select db_unique_name
from v$dataguard_config
order by db_unique_name
/

prompt
prompt Dataguard modes, switchover states etc. 


SELECT 
  name            as db_name 
, db_unique_name  
, database_role 
, current_scn
, archive_change#
, switchover_status 
, dataguard_broker
, protection_level
FROM v$database
/

prompt
prompt Fast Start Failover Status 

SELECT 
  fs_failover_status 
, fs_failover_current_target target 
, fs_failover_threshold  
, fs_failover_observer_present 
FROM v$database
/

prompt
prompt Archive log gaps - if working ok - should return no rows

-- Deliberately wrap this around a feedback on/off to see the no rows returned response.
set feedback on 

select 
  low_sequence#
, high_sequence#
  from v$archive_gap
/

set feedback off 

prompt
prompt Dataguard stats (only for standby)

select 
  name as metric_name
, value
, unit
, time_computed
from v$dataguard_stats
/

prompt
prompt Active archive destinations

SELECT 
dest_id
, dest_name
, destination
, target 
, status
, log_sequence as log_sequence#
, process
, to_char(fail_date,'DD-MON-YYYY HH24:MI:SS') as fail_time 
, fail_sequence
, failure_count 
, max_failure
, error 
, transmit_mode
, valid_type
, valid_role
from v$archive_dest
where status <> 'INACTIVE'
and log_sequence <> 0
/

prompt
prompt General archive status
  
select
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
from v$archive_dest_status
where status = 'VALID'
/

prompt
prompt  Redo Apply and redo transport status on a physical standby database

--
-- On Primary server this will essentially give information on recent log generation
-- On Standby server this will show logs received from primary and being applied

SELECT 
  process
, pid
, client_process
, client_pid
, status
, sequence#
, blocks 
FROM v$managed_standby
ORDER BY sequence# desc
/

prompt
prompt Current state of logs - both online and standby

select
  l.type 
, l.group#
, l.member  
, sl.bytes
, sl.sequence#
, sl.status as archive_status 
, to_char(sl.first_time,'DD-MON-YYYY HH24:MI:SS') as first_time
, to_char(sl.next_time,'DD-MON-YYYY HH24:MI:SS')  as next_time
, to_char(sl.last_time,'DD-MON-YYYY HH24:MI:SS')  as last_time
from v$standby_log sl
join v$logfile l 
on sl.group# = l.group#
and l.type = 'STANDBY'
UNION
select 
  l.type 
, l.group#
, l.member  
, sl.bytes
, sl.sequence#
, sl.status
, to_char(sl.first_time,'DD-MON-YYYY HH24:MI:SS')
, to_char(sl.next_time,'DD-MON-YYYY HH24:MI:SS') 
, to_char(null) 
from v$log sl
join v$logfile l 
on sl.group# = l.group#
and l.type = 'ONLINE'
order by 1,2,3 
/

prompt 
prompt Archived redo log files that have been received by a physical or snapshot standby database from a primary database:

select 
  sequence#
, to_char(first_time,'DY DD-MON-YYYY HH24:MI:SS') as log_start_time
, dest_id
, case status
    when 'A' then 'Available'
    when 'D' then 'Deleted'
    when 'U' then 'Unavailable'
    when 'X' then 'Expired'
    else status
  end as archive_status    
, standby_dest
, archived
, registrar
, applied
 from v$archived_log
where first_time > sysdate - 1/2
order by 
first_time desc
, dest_id asc
/
  


prompt
prompt Dataguard Status Log last 12 hours 

SELECT
  facility
, severity   
, to_char(timestamp,'DD-MON-YYYY HH24:MI:SS') as message_time
, error_code
, substr(message,1,80) as message
FROM V$DATAGUARD_STATUS
where timestamp > sysdate - 1/2
ORDER BY timestamp desc 
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

--edit &spool_name
exit