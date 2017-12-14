/*

 Name:          Run gen_move_table_tablespace_schema.sql

 Purpose:       Generate table move from old to new tablespace - non-partitioned tables 

 Usage:         gen_move_table_tablespace_schema.sql <schema> <old_tablespace_name> <new_tablespace_name>
 
 Example:       sqlplus -s user/pw@sid @gen_move_table_tablespace_schema.sql DBMON TOOLS USERS 
 
 Limitations:   See other scripts for tables with partitions, LOBS or IOTs

 Sanity checks: Before running this, check for any invalid indexes using invalid_index_ck.sql 
                After moving tables indexes will be left in an unusable state. 
                Rebuild them using other scripts as appropriate                

 Date            Who             Description

 7th Feb 2008   Aidan Lawrence  Fresh build for 2008
 29th Apr 2008  Aidan Lawrence  Added initial extent information to help rebuilds reclaim space
 27th Mar 2014  Aidan Lawrence  Tweaked with addition of schema limitation
 24th May 2017  Aidan Lawrence  Validated pre git publication 

*/


set lines 132
set pages 0
set feedback off
set verify off
set echo off

define schema = '&1'
define old_tablespace_name  = '&2'
define new_tablespace_name  = '&3'

spool gen_move_table_tablespace_schema_&schema._&old_tablespace_name._&new_tablespace_name


SELECT 'gen_move_table_tablespace_schema_&schema._&old_tablespace_name._&new_tablespace_name..log'
FROM dual
/

SELECT 'Set time on' FROM dual;
SELECT 'Set timing on' FROM dual;
SELECT 'Set echo on' FROM dual;

SELECT 'ALTER TABLE '
|| t.owner || '.'
|| t.table_name || ' MOVE TABLESPACE '
|| '&new_tablespace_name'
|| ';'
FROM dba_tables t
WHERE t.tablespace_name = '&old_tablespace_name'
AND t.owner = '&schema'
AND partitioned='NO'
ORDER BY t.table_name
/

SELECT 'Set echo off' FROM dual;
SELECT 'Spool off' FROM dual;
SELECT 'exit' FROM dual;

spool off
exit

