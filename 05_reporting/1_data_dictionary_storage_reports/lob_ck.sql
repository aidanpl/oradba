/*

 Name:          lob_ck.sql

 Purpose:       Rough documentation on lob segments

 Usage:         Casual investigation - shows before/after difference if tables are rebuilt with different in/out row values 

 Date            Who             Description

 22nd Jan 2015   Aidan Lawrence  Initial save
 19th Apr 2017   Aidan Lawrence  Changed to access from views and col definitions to login.sql   

*/

-- Set up environment
-- See login.sql for basic formatting

set heading off
set termout off

define script_name = 'lob_ck'

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

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
prompt LOB Segments

SELECT 
  owner
, table_name
, column_name
, in_row 
, chunk
, pctversion
, segment_name
, lob_mbytes
, table_mbytes
, num_rows
, avg_row_len
FROM lob_1_segments
/

prompt
prompt LOB Partitions

SELECT 
  table_owner
, table_name
, column_name
, lob_name
, partition_name
, in_row 
, chunk
, pctversion
FROM lob_2_partitions 
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit


