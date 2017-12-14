/*

 Name:          high_sql_ck.sql

 Purpose:       List worse 10 SQL based on buffer gets, disk reads and elapsed time in terms of per execution and overall 

 Date            Who             Description

 2nd Apr 2008    Aidan Lawrence  Sanity check and general tidy up
 14th Sep 2009   Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication 
 26th Sep 2017   Aidan Lawrence  Changed to access from views and col definitions to login.sql   

*/

-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'high_sql_ck'
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
--set feedback on (Not needed for this specific top 10 report) 
set feedback off 

prompt 
prompt Top 10 Buffer Gets per execution

SELECT
  rank
, parsing_schema
, sql_id
, SUBSTR(sql_text,1,50) AS sql_text_extract
, buffer_gets_per_execution          
, total_executions                   
, rows_processed                     
, last_active_time                   
FROM highsql_2_buffer_gets_per_exec
/

prompt 
prompt Top 10 Buffer Gets Total

SELECT
  rank
, parsing_schema
, sql_id
, SUBSTR(sql_text,1,50) AS sql_text_extract
, buffer_gets_total          
, rows_processed                     
, last_active_time                   
FROM highsql_3_buffer_gets_total
/

prompt 
prompt Top 10 Disk Reads per execution 

SELECT
  rank
, parsing_schema
, sql_id
, SUBSTR(sql_text,1,50) AS sql_text_extract
, disk_reads_per_execution
, total_executions
, rows_processed                     
, last_active_time                   
FROM highsql_4_disk_reads_per_exec
/

prompt 
prompt Top 10 Disk Reads Total 

SELECT
  rank
, parsing_schema
, sql_id
, SUBSTR(sql_text,1,50) AS sql_text_extract
, disk_reads_total
, rows_processed                     
, last_active_time                   
FROM highsql_5_disk_reads_total
/

prompt 
prompt Top 10 Elapsed Time per execution 

SELECT
  rank
, parsing_schema
, sql_id
, SUBSTR(sql_text,1,50) AS sql_text_extract
, elapsed_time_per_execution
, total_executions
, rows_processed                     
, last_active_time                   
FROM highsql_6_elapse_time_per_exec
/

prompt 
prompt Top 10 Elapsed Time Total 

SELECT
  rank
, parsing_schema
, sql_id
, SUBSTR(sql_text,1,50) AS sql_text_extract
, elapsed_time_total
, rows_processed                     
, last_active_time                   
FROM highsql_7_elapsed_time_total
/

prompt
prompt end of report

spool off
-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
