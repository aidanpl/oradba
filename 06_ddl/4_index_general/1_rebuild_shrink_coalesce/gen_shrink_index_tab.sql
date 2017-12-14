/*

 Name:          Run gen_shrink_index_tab.sql

 Purpose:       Generate index shrink commands for all indexes for a single table. 
 
 Usage:         gen_shrink_index_tab.sql <schema> <table_name> 
 
 Example:       sqlplus -s user/pw@sid @gen_shrink_index_tab.sql SH CUSTOMERS
 
 Limitations:   None.
 
 Date            Who             Description

 5th May 2017   Aidan Lawrence   Cleaned up pre git publication 

*/

set lines 132
set pages 0
set feedback off
set verify off
set echo off

define schema  = '&1'
define table_name  = '&2'

spool gen_shrink_index_tab_&schema._&table_name

SELECT 'spool gen_shrink_index_tab_&schema._&table_name..log'
FROM dual
/

SELECT 'Set time on' FROM dual;
SELECT 'Set timing on' FROM dual;
SELECT 'Set echo on' FROM dual;

--
-- Non Partitioned Indexes ALTER INDEX <index_name> SHRINK SPACE;  
--

SELECT 'ALTER INDEX ' 
|| i.owner || '.'
|| i.index_name || ' SHRINK SPACE '
|| ';'
FROM dba_indexes i
WHERE i.owner = '&schema'
AND i.table_name = '&table_name'
AND i.partitioned = 'NO'
AND i.index_type = 'NORMAL' -- See distinct index_type in dba_indexes for alternatives 
ORDER BY i.index_name
/

--
-- Partitioned Indexes ALTER INDEX <index_name> MODIFY PARTITION  <partition_name> ' SHRINK SPACE' 
--

SELECT 'ALTER INDEX ' 
|| ip.index_name || ' MODIFY PARTITION '
|| ip.partition_name 
|| ' SHRINK SPACE'
|| ';'
FROM dba_ind_partitions ip
JOIN dba_indexes i
ON (ip.index_name = i.index_name)
WHERE i.owner = '&schema'
AND i.table_name = '&table_name'
AND i.index_name = ip.index_name
ORDER BY ip.index_name, ip.partition_name
/

SELECT 'Set echo off' FROM dual;
SELECT 'Spool off' FROM dual;
SELECT 'exit' FROM dual;

spool off
exit
