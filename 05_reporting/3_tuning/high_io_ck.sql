/*

 Name:          high_io_ck.sql

 Purpose:       List IO usage by segment, file and general OS info

 Date            Who             Description

 2nd Apr 2008    Aidan Lawrence  Sanity check and general tidy up
 14th Sep 2009   Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication
 26th Sep 2017   Aidan Lawrence  Changed to access from views and col definitions to login.sql

*/

-- See login.sql for basic formatting

set heading off
set termout off

define script_name = 'high_io_ck'
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

set heading off
set feedback off

SELECT 'Database Name: ' || value FROM v$parameter where name='db_name'
/

SELECT 'Generated On ' ||  to_char(sysdate,'dd Month YYYY  HH24:MI') today from dual
/

set heading on
--set feedback on (Not needed for this specific top 10 report)
set feedback off

prompt
prompt High I/O by Segment

SELECT
  owner                  AS object_owner
, object_name
, partition_name
, tablespace_name
, logical_reads
, buffer_busy_waits
, physical_reads          AS phys_reads
, physical_reads_direct   AS phys_reads_direct
, db_block_changes
, physical_writes         AS phys_writes
--, physical_writes_direct  AS phys_writes_direct
FROM highio_1_segstats
/

prompt
prompt Recent File I/O Metrics

SELECT
  tablespace_name
, file_name
, from_time
, to_time
, phys_reads
, phys_block_reads
, phys_writes
, phys_block_writes
, avg_read_time_100s
, avg_write_time_100s
FROM highio_2_filemetric_recent
/

prompt
prompt Historical File I/O Metrics

SELECT
  tablespace_name
, file_name
, from_time
, to_time
, phys_reads
, phys_block_reads
, phys_writes
, phys_block_writes
, avg_read_time_100s
, avg_write_time_100s
FROM highio_3_filemetric_history
/

prompt
prompt OS Statistics

SELECT
statname
, value as value_os
, comments
, cumulative
, osstat_id
FROM highio_4_osstats
/

prompt
prompt end of report

spool off
-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
