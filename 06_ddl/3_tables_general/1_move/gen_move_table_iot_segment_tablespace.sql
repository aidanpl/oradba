/*

 Name:          Run gen_move_table_iot_segment_tablespace.sql

 Purpose:       Generate commands to move/rebuild IOT type tables from an old/existing tablespace to a new one.
 
				A separate script is used for IOT tables as their tablespace_name is accessed via DBA_INDEXES while DBA_TABLES has null in tablespace_name. 

 Usage:         gen_move_table_iot_segment_tablespace.sql  <old_tablespace_name> <new_tablespace_name>
 
 Example:       sqlplus -s user/pw@sid @gen_move_table_iot_segment_tablespace.sql TOOLS USERS 
 
 Oracle doc references https://docs.oracle.com/cd/B28359_01/server.111/b28310/tables012.htm#i1007046
 
 Limitations:   See other scripts for tables without IOT segments. This script currently works on tablespace level without considering schema or table_name. Typically used when migrating objects from old to new tablespace before the old one is dropped. As schema is not considered, the script may generate more output than desired - use your judgement.
 
				Note the AND t.table_name NOT LIKE 'AQ$%' in the generation script. Tables beginning AQ$_xxxx existing within the sample schemas for advanced queuing. Attempting to move this is not reasonable. By excluding AQ$% the tables will not appear in the output. 
 
				When tested against the sample schemas, the script generates data for the IX advanced queuing tables 
				
 Sample output 
 
Set time on
Set timing on
Set echo on
ALTER TABLE HR.COUNTRIES MOVE TABLESPACE TOOLS;
Set echo off
Spool off
exit


 Date            Who             Description

 13th Mar 2014   Aidan Lawrence   Tidy up, revalidate
 30th May 2017   Aidan Lawrence   Validated pre git publication 

*/

set lines 132
set pages 0
set feedback off
set verify off
set echo off

define old_tablespace_name  = '&1'
define new_tablespace_name  = '&2'

spool gen_move_table_iot_segment_&old_tablespace_name._&new_tablespace_name

select 'spool gen_move_table_iot_segment_&old_tablespace_name._&new_tablespace_name..log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;


select 'ALTER TABLE '
|| t.owner || '.'
|| t.table_name || ' MOVE TABLESPACE '
|| '&new_tablespace_name'
|| ';'
FROM dba_tables t
JOIN dba_indexes i
ON t.owner = i.table_owner
AND t.table_name = i.table_name
WHERE t.partitioned='NO'
AND t.iot_type IS NOT NULL
AND t.table_name NOT LIKE 'AQ$%'
AND i.tablespace_name = '&old_tablespace_name'
ORDER BY T.OWNER, t.table_name
/

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off
exit

