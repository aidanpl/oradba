/*

 Name:          login.sql

 Purpose:       Specify sql*plus environment and column definitions for a given directory for consistency across reports.

 Usage:         Edit column definitions to suit an individual environment

 Implementation: For Oracle 12.1 or before login.sql will be executed as part of the sql*plus execution
                 For Oracle 12.2 or later this is no longer the case. Instead Oracle searchs directories specified in the ORACLE_PATH environment variable - which by default is unset.

                 To continue using login.sql functionality in Oracle 12.2 then set ORACLE_PATH=. before executing SQL*PLUS

 Date            Who             Description

  4th Sep 2017   Aidan Lawrence  Comments on changed behaviour in Oracle 12.2

*/
prompt
prompt ###############################################################
prompt #                                                             #
prompt #  Login.sql present in this directory                        #
prompt #                                                             #
prompt ###############################################################
prompt

--
-- Basic formatting
--
set pages 99
set linesize 172
set verify off
set trimspool on
set feedback off
set heading off
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

set heading on
set termout on
set feedback on

--
-- NB - Careful adding any more to this - max string size is 240 characters :-o
define ignore_schemas = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')


--
-- Common values

column parameter_name  format a20 heading 'Parameter|Name'
column value           format a20 heading 'Value'

--
-- General Instance

column instance_name  format a8  heading 'Instance|Name'
column host_name      format a35 heading 'Host Name'
column version        format a10 heading 'Oracle|Release'
column last_start     format a20 heading 'Instance|Last Started'
column archiver       format a10 heading 'Archive|Status'

--
-- Undo

column tablespace_name format a25    heading Tablespace_name
column status          format a15    heading status
column start_time      format a18    heading 'Period|Start'
column undo_mb         format 99,999 heading 'Undo|Mb'
column size_mbytes     format 99,999 heading 'Size|Mb'
column undo_segment_id format 999    heading 'Undo|Segment'
column high_watermark  format 9999,999,999 heading 'High|Watermark'
column no_writes       format 9999,999,999 heading 'Writes'
column no_shrinks      format 999,999      heading 'Shrinks'
column no_extends      format 999,999      heading 'Extends'
column no_wraps        format 999,999      heading 'Wraps'
column avg_shrink_size format 999,999,999 heading 'Average|Shrink'
column avg_active_size format 999,999,999 heading 'Average|Active'
column class           format A20         heading 'Class'
column count           format 999,999     heading 'Count'
column time            format 999,999     heading 'Time'
column gets            format 999,999,999 Heading 'Gets'
column waits           format 999,999,999 Heading 'waits'
column hit_ratio       format 999.999999999 Heading 'Hit|Ratio'

--
-- SGA and PGA

column resizeable           format a10    heading 'Resizable?'
column sga_component_name   format a40    heading 'SGA Component Name'
column pga_component_name   format a40    heading 'PGA Component Name'
column oper_type            format a13    heading 'Operation|Type'
column oper_start_time      format a22    heading 'Operation|Time'
column last_oper_type       format a13    heading 'Last Operation|Type'
column disp_last_oper_time  format a25    heading 'Last Operation|Time'
column component_size_mb    format 99,999 heading 'Size Mb'
column initial_size_mb      format 99,999 heading 'Initial|Size Mb'
column target_size_mb       format 99,999 heading 'Target|Size Mb'
column final_size_mb        format 99,999 heading 'Final|Size Mb'
column current_size_mb      format 99,999 heading 'Current|Size Mb'
column min_size_mb          format 99,999 heading 'Min|Size Mb'
column max_size_mb          format 99,999 heading 'Max|Size Mb'
column sga_size             format 999,999,999,999 heading 'SGA Size'
column sga_size_factor      format 0.99            heading 'Ratio To| current size'
column estd_db_time         format 999,999,999,999 heading 'Estimated|DB Time'
column estd_db_time_factor  format 0.99            heading 'Ratio To| current time'
column estd_physical_reads  format 999,999,999,999 heading 'Estimated|DB Reads'

column pga_target_for_estimate       format 999,999,999,999 heading 'PGA Target|For Estimate'
column pga_target_factor             format 0.99            heading 'Ratio To| current size'
column estd_time                     format 999,999,999,999 heading 'Estimated|PGA Time'
column estd_pga_cache_hit_percentage format 999.99 heading 'Estimated|Cache hit ratio'

--
-- Transaction and lock
column sid                format 9999        heading 'SID'
column serial#            format 99999       heading 'Serial#'
column processname        format a12         heading 'Process|Name'
column os_process         format a6          heading 'Process|spid'
column fore_back          format a10         heading 'Background|Foreground'
column status             format a10         heading 'Status'
column osuser             format a10         heading 'OS User'
column schemaname         format a30         heading 'Oracle|User'
column ses_start_time     format a19         heading 'Session|Start Time'
column tran_start_time    format a20         heading 'Transaction|Start Time'
column oper_start_time    format a20         heading 'Operation|Start Time'
column update_time        format a17         heading 'Last Update|Time'
column program            format a15         heading 'Program'
column event              format a15         heading 'Event'
column state              format a20         heading 'State'
column opname             format a25         heading 'Operation|Name'
column target             format a30         heading 'Target'
column wait_time          format 999,999     heading 'Wait|Time'
column seconds_in_wait    format 9,999,999   heading 'Seconds|In Wait'
column undo_blocks        format 9,999,999   heading 'Undo Block|In Use'
column log_io             format 999,999,999 heading 'Logical|I/O'
column phy_io             format 999,999,999 heading 'Physical|I/O'
column percent_complete   format 999.99      heading 'Percent|Complete'
column mins_elapsed       format 99,990.9    heading 'Mins|Elapsed'
column mins_remaining     format 99,990.9    heading 'Mins|Remaining'
column object_owner       format a10         heading 'Object|Owner'
column object_name        format a25         heading 'Object|Name'
column locked_mode        format a15         heading 'Lock|Mode'
column machine            format a20         heading 'Machine'
column sql_id             format a13         heading 'SQL|ID'
column pga_used_mb        format 9,999.0     heading 'PGA Used|Memory Mb'
column pga_alloc_mb       format 9,999.0     heading 'PGA Alloc|Memory Mb'

--
-- Open Cursors
column highest_open_cur   format 9999  heading 'Highest Open|Cursors'
column max_open_cur       format 9999  heading 'Max Open|Cursors'
column username           format a20   heading 'User|Name'
column piece              format 999   heading 'SQL |Line 0'
column sql_text           format a75   heading 'SQL |Text'
column cursor_count       format 9999  heading 'Cursor|Count'

-- Stats

column table_owner            format a15 Heading Owner
column table_name             format a30 Heading 'Table|Name'
column partition_name         format a30 Heading 'Partition|Name'
column num_rows               format 9,999,999,999 Heading "Row|Count"
column blocks                 format 999,999 Heading "Used|Blocks"
column last_analyzed_time     format a23 Heading "Last|Analyzed"
column index_owner            format a15 Heading Owner
column index_name             format a30 Heading 'Index|Name'
column blevel                 format 99 Heading "Block|level"
column leaf_blocks            format 999,999 Heading "Leaf|Blocks"
column start_t                format a20 Heading 'Start|Time'
column end_t                  format a20 Heading 'End|Time'
column elapsed_time           format a30 heading 'Elapsed|Time'
column stats_count            format 9,999 heading 'Stats|Count'

-- High SQL

column rank                       format 999 heading 'Rank'
column parsing_schema             format a15 heading 'Parsing|Schema'
column sql_id                     format a13 heading 'SQL|id'
column sql_text_extract           format a50     heading 'First 50 characters SQL Text'
column last_active_time           format a20     heading 'Last|Active Time'
column buffer_gets_per_execution  format 999,999,999    heading 'Buffer Gets|Per Execution'
column buffer_gets_total          format 99,999,999,999 heading 'Buffer Gets|Total'
column disk_reads_per_execution   format 99,999,999,999 heading 'Disk Reads|Per Execution'
column disk_reads_total           format 99,999,999,999 heading 'Disk Reads|Total'
column elapsed_time_per_execution format 99,999,999,999 heading 'Elapesed Time|Per Execution'
column elapsed_time_total         format 99,999,999,999 heading 'Elapsed Time|Total'
column total_executions           format 999,999 heading 'Total|Executions'
column rows_processed             format 999,999 heading 'Rows|Processed'

-- High IO

column file_name           format A50 heading 'File Name'
column logical_reads       format 999,999,999   heading 'Logical|Reads'
column buffer_busy_waits   format 9,999,999   heading 'Buffer Busy|Waits'
column db_block_changes    format 9,999,999   heading 'DB Block|Changes'

column phys_reads          format 999,999,999   heading 'Physical|Reads'
column phys_reads_direct   format 999,999,999   heading 'Physical|Reads Direct'
column phys_block_reads    format 999,999,999   heading 'Physical|Block Reads'
column phys_writes         format 999,999,999   heading 'Physical|Writes'
column phys_writes_direct  format 999,999,999   heading 'Physical|Writes Direct'
column phys_block_writes   format 999,999,999   heading 'Physical|Block Writes'
column from_time           format A5   heading 'From|Time'
column to_time             format A5   heading 'To|Time'
column avg_read_time_100s  format 99.9999   heading 'Avg Read Time|100 Secs'
column avg_write_time_100s format 99.9999   heading 'Avg Write Time|100 Secs'
column statname   format A40   heading 'Statname'
column comments   format A64   heading 'Comments'
column cumulative format A3   heading 'Cumulative'
column osstat_id  format 99999 heading 'OS Stat ID'
column value_os   format 999,999,999,999 heading 'OS Value'

-- instance_tune_ck
column instance_role           format a20 Heading 'Instance|Role'
column parameter_name          format a40 heading 'Parameter|Name'
column parameter_display_value format a40 heading 'Parameter|Value'
column parameter_description   format a50 heading 'Parameter|Description'
column parameter_modified      format a10 heading 'Parameter|Modified'
column parameter_modifiable    format a10 heading 'Parameter|Modifiable'
column buffer_cache_hit_ratio  format 990.99 heading 'Buffer Cache|Hit Ratio (%)'
column dd_cache_miss_ratio     format 990.99 heading 'Data Dictionary Cache Miss Ratio (%)'
column lib_cache_miss_ratio    format 990.99 heading 'Library Cache Miss Ratio (%)'
column redo_gets      format 999,999,999  heading 'Redo|Gets'
column redo_misses    format 999,999      heading 'Redo|Misses'
column redo_im_gets   format 999,999,999  heading 'Redo IM|Gets'
column redo_im_misses format 999,999      heading 'Redo IM|Misses'
column latch_name     format a40          heading 'Latch|Name'
column stat_name      format a40          heading 'Stat|Name'
column stat_value     format 99,999,999,999  heading 'Stat|Value'

column sort_total_mb  format 99,999 Heading 'Total|MBytes'
column sort_used_mb   format 99,999 Heading 'Used|MBytes'
column sort_free_mb   format 99,999 Heading 'Free|MBytes'
