/*

 Name:          Run gen_move_table_partitioned.sql

 Purpose:       Generate table move commands for all partitions for an individual table 

 Usage:         gen_move_table_partitioned.sql <table_name>
 
				Note script currently uses user_tables and user_tab_partitions. Could be changed to dba_ or all_ if desired and expanded to include schema name. 
				
				Deliberately not asking for old/new tablespace name. This script will often be run to help generate commands to move older partitions to a different/archive tablespace. Easiest done by generating a standard script and then manually editing the output to change tablespace for preferred partitions. Would be huge overkill to try and code this with things like checking values before etc. etc. 
 
 Example:       sqlplus -s user/pw@sid @gen_move_table_partitioned.sql DEPT 
 
 Limitations:   See other scripts for tables with partitions, LOBS or IOTs

 Sanity checks: Before running this, check for any invalid indexes using invalid_index_ck.sql 
                After moving tables indexes will be left in an unusable state. 
                Rebuild them using other scripts as appropriate                
				
 Sample output :
ALTER TABLE DEPT MOVE PARTITION P_2017_04_28 TABLESPACE TOOLS STORAGE( INITIAL  65536);
ALTER TABLE DEPT MOVE PARTITION P_2017_04_29 TABLESPACE TOOLS STORAGE( INITIAL  65536);
ALTER TABLE DEPT MOVE PARTITION P_2017_04_30 TABLESPACE TOOLS STORAGE( INITIAL  65536);
 

 Date            Who             Description

 29th Apr 2008  Aidan Lawrence   Added initial extent information to help rebuilds reclaim space
 25th Mar 2015  Aidan Lawrence   Added in partitioned and subpartitioned tables 
 24th May 2017  Aidan Lawrence   Validated pre git publication 

*/

set lines 132
set pages 0
set feedback off
set verify off
set echo off

define table_name  = '&1'

spool gen_move_table_part_tab_&table_name

select 'spool gen_move_table_part_tab_&table_name..log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

select 'ALTER TABLE ' 
|| utp.table_name || ' MOVE PARTITION '
|| utp.partition_name || ' TABLESPACE '
|| utp.tablespace_name  || ' STORAGE( INITIAL  '
|| tbs.min_extlen || ')'
|| ';'
FROM 
  user_tab_partitions utp 
, user_tables up
, dba_tablespaces tbs
WHERE up.table_name = utp.table_name
AND up.table_name = '&table_name'
AND utp.tablespace_name = tbs.tablespace_name
ORDER BY utp.table_name, utp.partition_name
/

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off
exit
