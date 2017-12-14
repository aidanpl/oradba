/*

 Name:          Run gen_move_table_non_partitioned.sql

 Purpose:       Generate table move commands for a non-partitioned individual table 

 Usage:         gen_move_table_non_partitioned.sql <schema> <table_name>
			
				Simple rebuilding of tables - commonly to reclaim space/reset a highwatermark after data purges. 
				
				Deliberately not asking for old/new tablespace name in this script - see related scripts for bulk move of tables between tablespaces
 
 Example:       sqlplus -s user/pw@sid @gen_move_table.sql DEPT 
 
 Limitations:   See other scripts for tables with partitions, LOBS or IOTs

 Sanity checks: Before running this, check for any invalid indexes using invalid_index_ck.sql 
                After moving tables indexes will be left in an unusable state. 
                Rebuild them using other scripts as appropriate                
				
 Sample output :

 Date            Who             Description

 29th Apr 2008  Aidan Lawrence   Initial build 
 24th May 2017  Aidan Lawrence   Validated pre git publication 

*/

set lines 132
set pages 0
set feedback off
set verify off
set echo off

define schema  = '&1'
define table_name  = '&2'

spool gen_move_table_&schema._&table_name

select 'spool gen_move_table_&schema._&table_name..log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

select 'ALTER TABLE ' 
|| t.owner || '.'
|| t.table_name || ' MOVE'
|| ';'
FROM 
  dba_tables t
WHERE t.owner = '&schema'
AND t.table_name = '&table_name'

/

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off
exit
