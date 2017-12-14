/*

 Name:          seg_all_csv_ind_part.sql

 Purpose:       Segment details as a csv file for loading to spreadsheet

 Usage:          Be a little careful with this script - can run for a moderate period of time on large systems

 Date            Who             Description
                               
  4th Feb 2016   Aidan Lawrence  Sanity check/clean up and col definitions from login.sql 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'seg_all_csv_ind_part'
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

select 'owner,  partition_name, index_name, tablespace_name, seg_mbytes, extents, leaf_blocks, last_analyzed'
from dual
/

SELECT
substr(ind.index_owner,1,10) --owner
|| ',' || substr(ind.partition_name,1,25) --partition_name
|| ',' || substr(ind.index_name,1,25) --index_name
|| ',' || substr(ind.tablespace_name,1,25) --tablespace_name
|| ',' ||  round(seg.bytes/1048976) --seg_bytes
|| ',' || seg.extents
|| ',' ||  ind.leaf_blocks -- leaf_blocks                    -- How many blocks with rows in 
|| ',' ||  to_char(ind.last_analyzed,'DD-MON-YYYY') as seg_csv
FROM dba_ind_partitions  ind
JOIN dba_segments seg
ON ( ind.index_owner = seg.owner
AND  ind.index_name  = seg.segment_name
AND  ind.partition_name = seg.partition_name
)
JOIN dba_tablespaces tbs
ON    seg.tablespace_name = tbs.tablespace_name
WHERE seg.segment_type = 'INDEX PARTITION'
AND   ind.index_owner not in &ignore_schemas
--and   rownum < 40 -- test purposes
ORDER BY
  ind.index_owner
, ind.index_name
, ind.partition_name
/

-- end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit

