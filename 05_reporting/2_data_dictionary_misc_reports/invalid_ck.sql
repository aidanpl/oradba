/* 

 Name:          invalid_ck.sql

 Purpose: 	General check for invalid, offline, similar in error etc.
		Any rows returned from SQL here should be examined further by the DBA
		Output from this script will typically be mailed on a daily basis.

 Contents:	Checks for invalid procedures, triggers etc. 
		Checks for datafiles requiring recovery
		Checks for invalid redologs
		Checks for locked accounts
		Checks for accounts due to expire in next 7 days

 Date             Who             Description

 1st May 2002	  Aidan Lawrence  General Review/Tidy up for WCC
 14th Sep 2009    Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication 
 31st May 2016    Aidan Lawrence  Changed to access from views and col definitions to login.sql   
 28th Sep 2017    Aidan Lawrence  Validated for git 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'invalid_ck'
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

-- See login.sql for col definitions 

prompt
prompt Locked Accounts 

SELECT 
  username
, locked_on
, expired_on 
FROM users_1_locked
/

prompt
prompt Expiring Accounts 

SELECT 
  username
, expiring_on 
FROM users_2_future_expire
/

prompt
prompt Invalid objects (excluding mviews and synonyms)

SELECT 
    owner
  , object_type
  , object_name
  , status 
FROM inv_1_invalid_objects
/  

prompt
prompt Invalid objects (synonyms)

SELECT 
    owner
  , object_type
  , object_name
  , status 
FROM inv_2_invalid_synonyms
/  

prompt
prompt Invalid objects (mviews)

SELECT 
    owner
  , object_type
  , object_name
  , status 
FROM inv_3_invalid_mviews
/  

prompt
prompt Problem Datafiles 

SELECT 
    file_name
  , status 
FROM inv_4_datafile_problems
/  

prompt
prompt Problem Redologs

SELECT 
    member as redo_member
  , status 
FROM inv_5_redolog_problems
/  

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit

