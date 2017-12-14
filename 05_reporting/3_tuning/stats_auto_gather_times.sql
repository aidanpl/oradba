/*

 Name:         stats_auto_gather_times.sql

 Purpose:      Report timings for the Database wide auto gather stats processes.

 Date            Who             Description

 8th May 2009    Aidan Lawrence  New SQL
 26th Sep 2017   Aidan Lawrence  Changed to access from views and col definitions to login.sql   

*/


-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'stats_auto_gather_times'
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
prompt Recent Auto gather run times

SELECT 
  TO_CHAR(start_time,'DD-MON-YYYY HH24:MI:SS') AS start_t
, TO_CHAR(end_time,'DD-MON-YYYY HH24:MI:SS') AS end_t
, elapsed_time
FROM stats_3_auto_gather_times
/

prompt
prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
