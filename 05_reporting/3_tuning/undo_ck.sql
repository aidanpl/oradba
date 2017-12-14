/*

 Name:          undo_ck.sql

 Purpose:       Basic Undo information

 Contents:      Undo parameters, retention
                Undo tablespace size
                Undo extent status and size
                Undo tuning stats

 Date            Who             Description

 1st May 2002    Aidan Lawrence  General Review/Tidy up for WCC
23rd Oct 2006    Aidan Lawrence  Added in undostats for Oracle 9i
14th Sep 2009    Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication
26th Jul 2017    Aidan Lawrence  Changed to access from views and col definitions to login.sql   


*/
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'undo_ck'
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

set heading off
set feedback off 

SELECT 'Database Name: ' || value FROM v$parameter where name='db_name'
/

SELECT 'Generated On ' ||  to_char(sysdate,'dd Month YYYY  HH24:MI') today from dual
/

set heading on
set feedback on 

prompt
prompt Undo setup

column name  format a20 heading 'Parameter|Name'
column value format a20 heading 'Value'

set heading on

SELECT 
  name as parameter_name 
, value
FROM undo_1_parameters
/

prompt
prompt Undo recent volumes

SELECT 
start_time
, undo_mb
FROM undo_2_recent_volumes
/

prompt
prompt Undo extent sizes

SELECT 
  status
, tablespace_name
, size_mbytes
FROM undo_3_extent_sizes
/

prompt
prompt Undo tablespace data


SELECT tablespace_name
, size_mbytes
FROM undo_4_undo_storage
/

prompt
prompt Undo Extension 

SELECT 
undo_segment_id
, status
, avg_active_size
, high_watermark
, no_writes
, no_shrinks
, no_wraps
, no_extends
, avg_shrink_size
FROM  undo_5_undo_extension
/

prompt
prompt Undo segment waits. Goal : TBA

SELECT 
  class
, count
, time
FROM undo_6_undo_waits
/

prompt
prompt Undo waits and gets. Goal : TBA

select 
  undo_segment_id
, waits
, gets
, hit_ratio
from undo_7_undo_hit_ratio
/

prompt
prompt end of report

spool off
-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
