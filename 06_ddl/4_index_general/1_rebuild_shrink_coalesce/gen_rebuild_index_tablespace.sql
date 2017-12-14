/*

 Name:          Run gen_rebuild_index_tablespace.sql

 Purpose:       Generate index rebuild commands for all indexes in a given tablespace. 
				Optionally rebuild to a new tablespace - specify a different value for old and new tablespaces 
				To rebuild within the original tablespace simply have the same values for old and new 

 Usage:         gen_rebuild_index_tablespace.sql <old_tablespace_name> <new_tablespace_name> 
 
 Example:       sqlplus -s user/pw@sid @gen_rebuild_index_tablespace.sql USERS SAMPLE_SCHEMAS 
 
 Limitations:   Access to DBA_ views for generating the commands. Access to ALTER INDEX for each schema to execute the result. 
				If desired can always cut up the output into individual schemas 

 Sanity checks: Before running this, check for any invalid indexes using invalid_index_ck.sql 

 Date            Who             Description

 7th Feb 2008   Aidan Lawrence   Fresh build for 2008
 24th Mar 2015  Aidan Lawrence   Added in partitioned and subpartitioned indexes and assumed ONLINE as a default option
 5th May 2017   Aidan Lawrence   Cleaned up pre git publication 

*/


set lines 132
set pages 0
set feedback off
set verify off
set echo off

define old_tablespace_name  = '&1'
define new_tablespace_name  = '&2'

spool gen_rebuild_index_&old_tablespace_name._&new_tablespace_name

SELECT 'spool gen_rebuild_index_&old_tablespace_name._&new_tablespace_name..log'
FROM dual
/

SELECT 'Set time on' FROM dual;
SELECT 'Set timing on' FROM dual;
SELECT 'Set echo on' FROM dual;


--
-- Non Partitioned Indexes ALTER INDEX <index_name> REBUILD TABLESPACE <new_tablespace_name> ONLINE;  
--
select 'ALTER INDEX '
|| i.owner || '.'
|| i.index_name || ' REBUILD TABLESPACE '
|| '&new_tablespace_name'
|| ' ONLINE'
|| ';'
FROM dba_indexes i
WHERE i.tablespace_name = '&old_tablespace_name'
AND i.partitioned = 'NO' -- Different syntax for Partitions
AND i.index_type = 'NORMAL' -- See distinct index_type in dba_indexes for alternatives 
ORDER BY i.owner, i.index_name
/

--
-- Partitioned Indexes - ALTER INDEX <index_name> REBUILD PARTITION <partition_name> TABLESPACE <new_tablespace_name> ONLINE;  
--
SELECT 'ALTER INDEX '
|| i.index_owner || '.'
|| i.index_name || ' REBUILD PARTITION ' 
|| i.partition_name 
|| ' TABLESPACE '
|| '&new_tablespace_name'
|| ' ONLINE'
|| ';'
FROM dba_ind_partitions i
WHERE i.tablespace_name = '&old_tablespace_name'
AND i.subpartition_count = 0 -- Different syntax for sub partitions
ORDER BY i.index_owner, i.index_name
/

--
-- Subpartitioned Indexes - ALTER INDEX <index_name> REBUILD SUBPARTITION <subpartion_name> TABLESPACE <new_tablespace_name> ONLINE;  
--
SELECT 'ALTER INDEX '
|| i.index_owner || '.'
|| i.index_name || ' REBUILD SUBPARTITION '
|| i.subpartition_name  
|| ' TABLESPACE '
|| '&new_tablespace_name'
|| ' ONLINE'
|| ';'
FROM dba_ind_subpartitions i
WHERE i.tablespace_name = '&old_tablespace_name'
ORDER BY i.index_owner, i.index_name
/

SELECT 'Set echo off' FROM dual;
SELECT 'Spool off' FROM dual;
SELECT 'exit' FROM dual;

spool off
exit
