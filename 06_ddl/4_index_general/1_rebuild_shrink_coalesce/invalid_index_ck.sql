/* 

 Name:           invalid_index_ck.sql

 Purpose:        Specific check for invalid indexes. Run in association with any table moves to check everything OK afterwards
 
 Usage:          invalid_index_ck.sql
 
 Example:        sqlplus user/pw@sid @invalid_index_ck.sql
 
 Limitations:    None - see other scripts for index rebuild commands 

 Sanity checks:  Before running any moves worth running this first to check if there are any indexes unusable before you start 
                 After moving tables indexes will be left in an unusable state. 
                 Rebuild them using other scripts as appropriate                

 Date            Who             Description

 2nd Jan 2014    Aidan Lawrence  Cloned from similar
 31st Mar 2015   Aidan Lawrence  Expanded to include partitioned and subpartitioned indexes
 24th May 2017   Aidan Lawrence  Validated pre git publication 

*/

-- Set up environment

set heading off
set verify off 
set pages 99
set feedback off
set trimspool on
set linesize 132
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

define script_name = 'invalid_index_ck'
--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;
       
select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI') 
       || '.lst' spool_name      
  from v$database d;
  
select 'Output report name is ' 
       || '&spool_name'
  from dual;  

spool &spool_name

prompt 
prompt Report Details are &spool_name                     
prompt
--
-- Main report begins
--

set heading on

prompt
prompt List of invalid non-partitioned indexes
prompt

column owner             format a20 Heading Owner
column tablespace_name   format a20 Heading 'Tablespace|Name'
column index_name        format a30 Heading 'Index|Name'
column status            format a15 Heading 'Status'


SELECT
  owner
, index_name
, status   
, tablespace_name
FROM dba_indexes
WHERE status != 'VALID'
and partitioned = 'NO'
ORDER BY owner
, table_name
, index_name
/

prompt
prompt List of invalid partitioned indexes
prompt

column index_owner       format a20 Heading Owner
column partition_name    format a20 Heading 'Partition|Name'


SELECT
  index_owner
, index_name
, partition_name
, status   
, tablespace_name
FROM dba_ind_partitions
WHERE status != 'USABLE'
and subpartition_count = 0
ORDER BY index_owner
, index_name
, partition_name
/


prompt
prompt List of invalid subpartitioned indexes
prompt

column subpartition_name format a30 Heading 'SubPartition|Name'

SELECT
  index_owner
, index_name
, partition_name
, subpartition_name
, status   
, tablespace_name
FROM dba_ind_subpartitions
WHERE status != 'USABLE'
ORDER BY index_owner
, index_name
, partition_name
, subpartition_name
/

prompt
prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
