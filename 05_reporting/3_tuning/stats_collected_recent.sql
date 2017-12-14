/*

 Name:         stats_collected_recent.sql

 Purpose:      Count the number of times an object has had stats collected for it. Gives some background on how often stats are becoming stale for a given object. Note that the default retention period is 31 days - see tuning guide for more information. 
 
 
 Date            Who             Description

 8th May 2009    Aidan Lawrence  Specific rewrite focusing solely on recent analysis dates to help understand 'stale' issues and volatile tables in an application
 26th Sep 2017   Aidan Lawrence  Changed to access from views and col definitions to login.sql

*/


-- See login.sql for basic formatting

set heading off
set termout off

define script_name = 'stats_collected_recent'
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

set heading off
set feedback off 

SELECT 'Database Name: ' || value FROM v$parameter where name='db_name'
/

SELECT 'Generated On ' ||  to_char(sysdate,'dd Month YYYY  HH24:MI') today from dual
/

set heading on
set feedback on 

prompt
prompt Count of recent stats collections - only available for tables

select
  owner AS table_owner
, table_name
, partition_name
, stats_count
FROM stats_4_collected_recent
/

prompt
prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit

