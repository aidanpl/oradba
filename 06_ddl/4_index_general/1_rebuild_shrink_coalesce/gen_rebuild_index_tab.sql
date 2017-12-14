/*

 Name:          Run gen_rebuild_index_tab.sql

 Purpose:       Generate index rebuild commands for all indexes for a single table with no change of tablespace. 

 Usage:         gen_rebuild_index_tab.sql <schema> <table_name> 
 
 Example:       sqlplus -s user/pw@sid @gen_rebuild_index_tab.sql SH CUSTOMERS
 
 Limitations:   See other scripts for partitioned tables, rebuilding in new tablespace etc. 

 Sanity checks: Before running this, check for any invalid indexes using invalid_index_ck.sql 

 Date            Who             Description

 7th Feb 2008   Aidan Lawrence   Fresh build for 2008
 13th May 2015  Aidan Lawrence   Included partitioned and subpartition indexes
 5th May 2017   Aidan Lawrence   Cleaned up pre git publication 

*/


set lines 132
set pages 0
set feedback off
set verify off
set echo off

define schema  = '&1'
define table_name  = '&2'

spool gen_rebuild_index_&schema._&table_name

SELECT 'spool gen_rebuild_index_&schema._&table_name..log'
FROM dual
/

SELECT 'Set time on' FROM dual;
SELECT 'Set timing on' FROM dual;
SELECT 'Set echo on' FROM dual;

--
-- Non Partitioned Indexes ALTER INDEX <index_name> REBUILD TABLESPACE <new_tablespace_name> ONLINE;  
--

SELECT 'ALTER INDEX ' 
|| i.owner || '.'
|| i.index_name || ' REBUILD ONLINE TABLESPACE '
|| i.tablespace_name || ';'
FROM dba_indexes i
WHERE i.owner = '&schema'
AND i.table_name = '&table_name'
AND i.partitioned = 'NO'
AND i.index_type = 'NORMAL' -- See distinct index_type in dba_indexes for alternatives 
ORDER BY i.index_name
/

--
-- Partitioned Indexes - ALTER INDEX <index_name> REBUILD PARTITION <partition_name> TABLESPACE <new_tablespace_name> ONLINE;  
--
SELECT 'ALTER INDEX '
|| i.owner || '.'
|| i.index_name || ' REBUILD PARTITION ' 
|| ip.partition_name 
|| ' TABLESPACE '
|| ip.tablespace_name
|| ' ONLINE'
|| ';'
FROM dba_ind_partitions ip
JOIN dba_indexes i
ON (ip.index_name = i.index_name)
WHERE i.owner = '&schema'
AND i.table_name = '&table_name'
AND ip.subpartition_count = 0 -- Different syntax for sub partitions
ORDER BY i.owner, i.index_name, ip.partition_name
/

--
-- Subpartitioned Indexes - ALTER INDEX <index_name> REBUILD SUBPARTITION <subpartion_name> TABLESPACE <new_tablespace_name> ONLINE;  
--
SELECT 'ALTER INDEX '
|| i.owner || '.'
|| i.index_name || ' REBUILD SUBPARTITION '
|| ip.subpartition_name  
|| ' TABLESPACE '
|| ip.tablespace_name
|| ' ONLINE'
|| ';'
FROM dba_ind_subpartitions ip
JOIN dba_indexes i
ON (ip.index_owner = i.owner
AND ip.index_name = i.index_name)
WHERE i.owner = '&schema'
AND i.table_name = '&table_name'
ORDER BY i.owner, i.index_name, ip.subpartition_name
/

SELECT 'Set echo off' FROM dual;
SELECT 'Spool off' FROM dual;
SELECT 'exit' FROM dual;

spool off
exit
