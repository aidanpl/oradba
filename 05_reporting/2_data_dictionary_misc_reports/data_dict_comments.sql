/*

 Name:          data_dict_comments.sql

 Purpose:       Extract comments on tables/columns

 Contents:      Main objects including dependencies
 
 Usage:         Note hardcoded ignore of 'APEX%' - not easy to include in ignore_schemas and without this will get thousands of useless information...

 Date            Who             Description

 15th Nov 2011	 Aidan Lawrence  Cloned from similar
 18th Apr 2017   Aidan Lawrence  Changed to col definitions to login.sql  (No point with views - simple look at all_xxx 
 28th Sep 2017   Aidan Lawrence  Validated for git 
*/


-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'data_dict_comments'
--
-- Set the Spool output name as combination of script, database AND time
--

column spool_name new_value spool_name noprint;
       
SELECT '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI') 
       || '.lst' spool_name      
  FROM v$database d;
  
SELECT 'Output report name is ' 
       || '&spool_name'
  FROM dual;  

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
prompt Tables and their comments 

break on owner skip 1

SELECT 
  owner
, table_type
, table_name
, comments
FROM all_tab_comments
WHERE owner NOT IN  &ignore_schemas
AND owner NOT LIKE 'APEX%'
AND comments IS NOT NULL
ORDER BY 
owner
, table_type
, table_name
/

prompt
prompt Column level comments

SELECT 
  acc.owner
, acc.table_name
, ao.object_type
, acc.column_name
, acc.comments
FROM all_col_comments acc
JOIN all_objects ao
ON (ao.owner = acc.owner
AND acc.table_name = ao.object_name)
WHERE acc.owner NOT IN  &ignore_schemas
AND acc.owner NOT LIKE 'APEX%'
AND acc.comments IS NOT NULL
ORDER BY 
acc.owner
, acc.table_name
, acc.column_name
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

--edit &spool_name
exit
