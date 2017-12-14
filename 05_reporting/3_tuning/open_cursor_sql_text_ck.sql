/*

 Name:          open_cursor_sql_text.sql

 Purpose:       Capture SQL Text with a large number of open cursors 
 
 Usage:         Also see sessstat_ck.sql for capturing max open cursors 

 Date            Who             Description

 16th Nov 2016   Aidan Lawrence  Cloned from similar
  9th May 2017   Aidan Lawrence  Changed to access from views and col definitions to login.sql  
 

*/

-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'open_cursor_sql_text'
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
prompt SQL with open cursor count above a threshold 

SELECT 
  sid
, user_name
, piece
, sql_text
, cursor_count 
FROM cur_1_open_threshold_count_sql
/

prompt
prompt Highest Open Cursors

SELECT 
highest_open_cur
, max_open_cur
FROM cur_2_highest_open_current
/

prompt
prompt end of report

spool off
-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit
