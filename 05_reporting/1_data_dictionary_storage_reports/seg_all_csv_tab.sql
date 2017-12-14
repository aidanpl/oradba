/*

 Name:          seg_all_csv_tab.sql

 Purpose:       Table Segment details as a csv file for loading to spreadsheet

 Usage:          Be a little careful with this script - can run for a moderate period of time on large systems

 Date            Who             Description
                               
 16th Sep 2010   Aidan Lawrence  Cloned from seg_all_ck                                  
  4th Feb 2016   Aidan Lawrence  Sanity check/clean up and col definitions from login.sql 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'seg_all_csv_tab'
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

--
-- Main report begins
--

set heading off
set verify off
set pages 0
set feedback off
set trimspool on
set linesize 1000
set termout off

/*
Ignore certain schemas
*/

-- NB - Careful adding any more to this - max string size is 240 characters :-o
-- (Should be picking up from login.sql) 
--define ignore_schemas = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')

--
-- Select heading nows to show when importing into Excel 

select 'owner, table_name, tablespace_name, seg_bytes, extents, num_rows, avg_row_len, allocated_blocks, actual_blocks, calc_blocks,pctfree, last_analyzed'
from dual
/

select
substr(tab.owner,1,10) --owner
|| ',' || substr(tab.table_name,1,25) --table_name
|| ',' || substr(tab.tablespace_name,1,25) --tablespace_name
|| ',' ||  round(seg.bytes/1048976) --seg_bytes
|| ',' || seg.extents
|| ',' || tab.num_rows
|| ',' || tab.avg_row_len
|| ',' || (seg.bytes/tbs.block_size) --allocated_blocks -- How many blocks actually allocated by segment
|| ',' ||  tab.blocks -- actual_blocks                    -- How many blocks with rows in 
|| ',' ||  round(((tab.num_rows * avg_row_len)/tbs.block_size)*1.4,1) --calc_blocks -- How many blocks needed for rows. (The 1.4 is a factor based on Oracle overhead)
|| ',' ||  tab.pct_free -- pctfree
|| ',' ||  to_char(tab.last_analyzed,'DD-MON-YYYY') seg_csv
from dba_tables tab
   , dba_segments seg
   , dba_tablespaces tbs
where tab.owner = seg.owner
and   tab.table_name = seg.segment_name
and   seg.tablespace_name = tbs.tablespace_name
and   tab.partitioned = 'NO'
and   tab.owner not in &ignore_schemas
order by
  tab.owner
, tab.table_name
/

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit

