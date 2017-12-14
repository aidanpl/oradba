/*

 Name:          Run gen_move_table_tablespace.sql

 Purpose:       Generate table move commands for all tables from and old/existing tablespace to a new one

 Usage:         gen_move_table_tablespace.sql <old_tablespace_name> <new_tablespace_name>
 
 Example:       sqlplus -s user/pw@sid @gen_move_table_tablespace.sql TOOLS USERS 
 
 Limitations:   See other scripts for tables with partitions, LOBS or IOTs

 Sanity checks: Before running this, check for any invalid indexes using invalid_index_ck.sql 
                After moving tables indexes will be left in an unusable state. 
                Rebuild them using other scripts as appropriate                

 Date            Who             Description

 7th Feb 2008   Aidan Lawrence   Fresh build for 2008
 29th Apr 2008  Aidan Lawrence   Added initial extent information to help rebuilds reclaim space
 13th Mar 2014  Aidan Lawrence   Tidy up, revalidate
 25th Mar 2015  Aidan Lawrence   Added in partitioned and subpartitioned tables 
 24th May 2017  Aidan Lawrence   Validated pre git publication 

*/


set lines 132
set pages 0
set feedback off
set verify off
set echo off

define old_tablespace_name  = '&1'
define new_tablespace_name  = '&2'

spool gen_move_table_tablespace_&old_tablespace_name._&new_tablespace_name

SELECT 'spool gen_move_table_tablespace_&old_tablespace_name._&new_tablespace_name..log'
FROM dual
/

SELECT 'Set time on' FROM dual;
SELECT 'Set timing on' FROM dual;
SELECT 'Set echo on' FROM dual;

--
-- Non Partitioned Tables  - ALTER TABLE <owner.table_name> MOVE TABLESPACE <new_tablespace_name>
--

SELECT 'ALTER TABLE '
|| t.owner || '.'
|| t.table_name || ' MOVE TABLESPACE '
|| '&new_tablespace_name'
|| ';'
FROM dba_tables t
WHERE t.tablespace_name = '&old_tablespace_name'
AND partitioned='NO'
ORDER BY 
  t.owner
, t.table_name
/

--
-- Partitioned Tables  - ALTER TABLE <owner.table_name> MOVE PARTITION <partition_name> TABLESPACE <new_tablespace_name>
--

SELECT 'ALTER TABLE '
|| t.table_owner || '.'
|| t.table_name || ' MOVE PARTITION ' 
|| t.partition_name 
|| ' TABLESPACE '
|| '&new_tablespace_name'
|| ';'
FROM dba_tab_partitions t
WHERE t.tablespace_name = '&old_tablespace_name'
AND t.subpartition_count = 0 -- Different syntax for sub partitions
ORDER BY t.table_name, t.partition_name
/

--
-- Sub partitioned Tables  - ALTER TABLE <owner.table_name> MOVE SUBPARTITION <partition_name> TABLESPACE <new_tablespace_name>
--

SELECT 'ALTER TABLE '
|| t.table_owner || '.'
|| t.table_name || ' MOVE SUBPARTITION ' 
|| t.subpartition_name 
|| ' TABLESPACE '
|| '&new_tablespace_name'
|| ';'
FROM dba_tab_subpartitions t
WHERE t.tablespace_name = '&old_tablespace_name'
ORDER BY t.table_name, t.partition_name
/


SELECT 'Set echo off' FROM dual;
SELECT 'Spool off' FROM dual;
SELECT 'exit' FROM dual;

spool off
exit

