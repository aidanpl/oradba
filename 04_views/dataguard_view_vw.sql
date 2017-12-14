/*

 Name:          dataguard_view_vw.sql

 Purpose:       Dataguard views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 Implementation Typically run under 'dbmon' type user. Initially cloned from seg_all_ck etc. etc. 
 
                NB Specifically for dataguard - dbmon type user will be unavailable on standby database. These views only suitable for monitoring primary.
				See scripts dataguard_ck_dbmon.sql and dataguard_ck_sysdba.sql for further information
 
--
--  Required direct Grants for view creations
 
GRANT SELECT ON v_$dataguard_config    to DBMON;
GRANT SELECT ON v_$dataguard_stats     to DBMON;
GRANT SELECT ON v_$dataguard_status    to DBMON;
GRANT SELECT ON v_$database     	   to DBMON;
GRANT SELECT ON v_$managed_standby     to DBMON;
GRANT SELECT ON v_$archive_dest        to DBMON;
GRANT SELECT ON v_$archive_dest_status to DBMON;
GRANT SELECT ON v_$archived_log        to DBMON;
GRANT SELECT ON v_$archive_gap   	   to DBMON;
GRANT SELECT ON v_$logfile     		   to DBMON;
GRANT SELECT ON v_$log     		   	   to DBMON;
GRANT SELECT ON v_$log_history     	   to DBMON;
GRANT SELECT ON v_$standby_log     	   to DBMON;


 
 Date            Who             Description

  2nd May 2017   Aidan Lawrence  Consolidated from similar
  8th Jun 2017   Aidan Lawrence  Validated pre git publication   

*/


CREATE OR REPLACE VIEW dg_1_dbs 
AS
SELECT db_unique_name
FROM v$dataguard_config
/


CREATE OR REPLACE VIEW dg_2_dbmode_states 
AS
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

CREATE OR REPLACE VIEW dg_3_failover_status 
AS
SELECT 
  fs_failover_status 
, fs_failover_current_target
, fs_failover_threshold  
, fs_failover_observer_present 
FROM v$database
/

CREATE OR REPLACE VIEW dg_4_archive_gap
AS
SELECT 
  low_sequence#
, high_sequence#
  FROM v$archive_gap
/


CREATE OR REPLACE VIEW dg_5_archive_dest
AS
SELECT 
  dest_id
, dest_name
, destination
, target 
, status
, log_sequence AS log_sequence#
, process
, TO_CHAR(fail_date,'DD-MON-YYYY HH24:MI:SS') AS fail_time 
, fail_sequence
, failure_count 
, max_failure
, error 
, transmit_mode
, valid_type
, valid_role
FROM v$archive_dest
WHERE status <> 'INACTIVE'
AND log_sequence <> 0
/


CREATE OR REPLACE VIEW dg_6_archive_dest_status
AS
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
FROM v$archive_dest_status
WHERE status = 'VALID'
/

CREATE OR REPLACE VIEW  dg_7_redo_app_transport
AS
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

CREATE OR REPLACE VIEW  dg_8_redo_current
AS
SELECT
  l.type 
, l.group#
, l.member  
, sl.bytes
, sl.sequence#
, sl.status as archive_status 
, to_char(sl.first_time,'DD-MON-YYYY HH24:MI:SS') as first_time
, to_char(sl.next_time,'DD-MON-YYYY HH24:MI:SS')  as next_time
, to_char(sl.last_time,'DD-MON-YYYY HH24:MI:SS')  as last_time
FROM v$standby_log sl
join v$logfile l 
on sl.group# = l.group#
and l.type = 'STANDBY'
UNION
SELECT 
  l.type 
, l.group#
, l.member  
, sl.bytes
, sl.sequence#
, sl.status
, to_char(sl.first_time,'DD-MON-YYYY HH24:MI:SS')
, to_char(sl.next_time,'DD-MON-YYYY HH24:MI:SS') 
, to_char(null) 
FROM v$log sl
join v$logfile l 
on sl.group# = l.group#
and l.type = 'ONLINE'
ORDER BY 1,2,3 
/

CREATE OR REPLACE VIEW  dg_9_redo_status
AS
SELECT 
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
 FROM v$archived_log
WHERE first_time > sysdate - 1/2
ORDER BY 
first_time desc
, dest_id asc
/

CREATE OR REPLACE VIEW dg_10_log_dg_status
AS
SELECT
  facility
, severity   
, to_char(timestamp,'DD-MON-YYYY HH24:MI:SS') as message_time
, error_code
, substr(message,1,80) as message
FROM V$DATAGUARD_STATUS
WHERE timestamp > sysdate - 1/2
ORDER BY timestamp desc 
/

