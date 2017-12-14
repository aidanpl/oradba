/*

 Name:          Run gen_move_table_lob_segment_tablespace.sql

 Purpose:       Generate commands to relocate lob segments from an old/existing tablespace to a new one
 
 Usage:         gen_move_table_lob_segment_tablespace <old_tablespace_name> <new_tablespace_name> <table_name>

 Example:       sqlplus -s sys/<pw>@<sid> as sysdba @gen_move_table_lob_segment_tablespace.sql  SAMPLE_SCHEMAS USERS PRINT_MEDIA

 Limitations:   See other scripts for tables with partitions, LOBS or IOTs

 Sanity checks: Note this script has some commented queries to identify the LOB in the database. Use this to determine owmer table, column names for LOBS with system generated names 
				
 Sample output :
 
 
spool gen_move_table_lob_segment_tablespace_SAMPLE_SCHEMAS_USERS_PRINT_MEDIA.log
Set time on
Set timing on
Set echo on
ALTER TABLE PM.PRINT_MEDIA MOVE LOB ( "AD_HEADER"."LOGO") STORE AS (TABLESPACE USERS);
ALTER TABLE PM.PRINT_MEDIA MOVE LOB ( AD_PHOTO) STORE AS (TABLESPACE USERS);
ALTER TABLE PM.PRINT_MEDIA MOVE LOB ( AD_FLTEXTN) STORE AS (TABLESPACE USERS);
ALTER TABLE PM.PRINT_MEDIA MOVE LOB ( AD_FINALTEXT) STORE AS (TABLESPACE USERS);
ALTER TABLE PM.PRINT_MEDIA MOVE LOB ( AD_SOURCETEXT) STORE AS (TABLESPACE USERS);
ALTER TABLE PM.PRINT_MEDIA MOVE LOB ( AD_COMPOSITE) STORE AS (TABLESPACE USERS);
Set echo off
Spool off
exit
 
 Date            Who             Description

 13th Mar 2014   Aidan Lawrence   Tidy up, revalidate
 2nd  Apr 2015   Aidan Lawrence   Added in syntax for partitioned tables 
 30th May 2017   Aidan Lawrence   Validated pre git publication 

*/

/*

Check basic LOB information across the database limiting by tablespace or anything else you like

select 
  l.owner
, s.tablespace_name
, l.table_name
, l.column_name
, s.segment_name
, s.segment_type
from dba_lobs l
join dba_segments s
on (l.owner = s.owner
and l.segment_name = s.segment_name
and l.partitioned = 'NO'
)
where s.tablespace_name = 'SAMPLE_SCHEMAS'
UNION ALL
select 
  l.owner
, s.tablespace_name
, l.table_name
, l.column_name
, s.segment_name
, s.segment_type
from dba_lobs l
join dba_segments s
on (l.owner = s.owner
and l.index_name = s.segment_name 
)
where s.tablespace_name = 'SAMPLE_SCHEMAS'
order by owner, tablespace_name, table_name, segment_name

-- Manual name example

ALTER TABLE PM.PRINT_MEDIA 
MOVE LOB ( AD_FLTEXTN) 
STORE AS (TABLESPACE USERS);

-- Partition Example
--

select
  l.owner
, s.tablespace_name
, l.table_name
, l.column_name
, s.segment_name
, s.segment_type
, s.partition_name
from dba_lobs l
join dba_segments s
on (l.owner = s.owner
and l.segment_name = s.segment_name
and l.partitioned = 'YES'
)
where s.tablespace_name = 'SAMPLE_SCHEMAS'
order by owner, tablespace_name, table_name, segment_name

*/

set lines 132
set pages 0
set feedback off
set verify off
set echo off

define old_tablespace_name  = '&1'
define new_tablespace_name  = '&2'
define table_name  = '&3'


spool gen_move_table_lob_segment_tablespace_&old_tablespace_name._&new_tablespace_name._&table_name

select 'spool gen_move_table_lob_segment_tablespace_&old_tablespace_name._&new_tablespace_name._&table_name..log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

select 'ALTER TABLE ' 
|| l.owner || '.'
|| l.table_name || ' MOVE '
|| 'LOB ( '
|| l.column_name
|| ')'
|| ' STORE AS (TABLESPACE ' 
|| '&new_tablespace_name'
|| ')'
|| ';'
from dba_lobs l
join dba_segments s
on (l.owner = s.owner
and l.segment_name = s.segment_name 
and l.partitioned = 'NO'
)
WHERE s.tablespace_name = '&old_tablespace_name'
AND l.table_name = '&table_name'
ORDER BY l.table_name
/

--
-- For Partitioned tables need to move the whole segment 

select 'ALTER TABLE '
|| utp.table_name || ' MOVE PARTITION '
|| utp.partition_name || ' TABLESPACE '
|| utp.tablespace_name  || ' STORAGE( INITIAL  '
|| tbs.min_extlen || ')'
|| ' LOB ( '
|| l.column_name
|| ')'
|| ' STORE AS (TABLESPACE ' 
|| '&new_tablespace_name'
|| ')'
|| ';'
FROM dba_tables t
JOIN dba_tab_partitions utp
ON (t.owner = utp.table_owner
AND t.table_name = utp.table_name)
JOIN dba_tablespaces tbs
ON (utp.tablespace_name = tbs.tablespace_name)
JOIN dba_lobs l
ON (l.owner = utp.table_owner
AND l.table_name = t.table_name)
WHERE  l.table_name = '&table_name'
AND l.partitioned = 'YES'
--WHERE  utp.table_name = 'xyz'
ORDER BY utp.table_name, utp.partition_name
/


select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off
exit

