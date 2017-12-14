/*

 Name:          gen_rebuild_index_unusable.sql

 Purpose:       Generate index rebuild commands for unusuable indexes across the database 

 Usage:         gen_rebuild_index_tab.sql 
 
 Example:       sqlplus -s user/pw@sid @gen_rebuild_index_unusable.sql 
 
 Limitations:   None.

 Sanity checks: Before running this, check for any invalid indexes using invalid_index_ck.sql 				

 Date            Who             Description

 2nd Jan 2014    Aidan Lawrence  Cloned from similar
 31st Mar 2015   Aidan Lawrence  Expanded to include partitioned and subpartitioned indexes
 5th May 2017   Aidan Lawrence   Cleaned up pre git publication 

*/


set lines 132
set pages 0
set feedback off
set verify off
set echo off

spool gen_rebuild_index_unusable

select 'spool gen_rebuild_index_unusable.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

select 'ALTER INDEX '
|| i.owner || '.'
|| i.index_name || ' REBUILD '
|| ';'
FROM dba_indexes i
WHERE i.status = 'UNUSABLE'
and i.partitioned = 'NO'
ORDER BY i.index_name
/

--
-- Partitioned Indexes 
--

select 'ALTER INDEX ' 
|| ip.index_owner || '.'
|| ip.index_name || ' REBUILD PARTITION '
|| ip.partition_name || ' ONLINE '
|| ';'
FROM dba_ind_partitions ip 
WHERE ip.status = 'UNUSABLE'
AND ip.subpartition_count = 0
ORDER BY ip.index_owner, ip.index_name, ip.partition_name
/

--
-- Sub partitioned Indexes 
--

select 'ALTER INDEX ' 
|| ip.index_owner || '.'
|| ip.index_name || ' REBUILD SUBPARTITION '
|| ip.subpartition_name || ' ONLINE '
|| ';'
FROM dba_ind_subpartitions ip 
WHERE ip.status = 'UNUSABLE'
ORDER BY ip.index_owner, ip.index_name, ip.subpartition_name
/

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off
exit
