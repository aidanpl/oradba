/*

 Name:         audit_oracle_ck.sql

 Purpose:      Audit report on recent database usage (Includes quite a few NPA client front end specifics)

 Contents:     Lists successful database connections during last 24 hours
	           Lists failed connection attempts during last 24 hours
	           Lists successful audited actions during last 24 hours
	           Lists failed audited actions during last 24 hours

			   NB This script will only return results where Oracle auditing has been activated 
	           
	           
 Date            Who             Description

 1st May 2002	 Aidan Lawrence  General Review/Tidy up
14th Sep 2009    Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication 
23rd Mar 2016    Aidan Lawrence  Changed to access from views and col definitions to login.sql 
28th Sep 2017    Aidan Lawrence  Validated for git 

*/
    
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'audit_oracle_ck'
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
prompt Failed database connection attempts in last 7 days

SELECT 
  os_username
, username
, userhost 
, logintime
, connect_message
 from aud_3_connect_failures
/

prompt
prompt Non connect audit records in last 7 days

SELECT
  action_name
, os_username
, username
, userhost 
, audittime
, returncode
from aud_4_non_connect_audits
/

prompt
prompt Statement Audit Options

SELECT
audit_option
, success
, failure
, username
FROM aud_1_stmt_options
ORDER BY 
  audit_option
, username
/

prompt
prompt Privilege Audit Options

SELECT
privilege
, success
, failure
, username
FROM aud_2_priv_options
ORDER BY 
  privilege
, username
/

prompt
prompt List of failed audited actions in last 24 hours 

SELECT 
  os_username
, username
, audittime
, obj_name
, action_name
, error_message
FROM aud_7_fail_actions_24hrs
/

prompt
prompt List of successful audited actions in last 24 hours 

SELECT 
  os_username
, username
, audittime
, obj_name
, action_name
, error_message
FROM aud_8_succ_actions_24hrs
/

prompt
prompt General activity in last 24 hours 

SELECT 
  os_username
, username
, userhost
, audit_date
, daily_connections
, total_logical_reads
, total_physical_reads
, total_logical_writes
FROM aud_6_historical_audit_summary
/

/*

col os_username format a30 Heading "O/S User"
col username format a15 Heading "Oracle User"
col Successes format 999,999 Heading "Successful|Connections"
col reads format 999,999,999 Heading "Total|Reads"
col writes format 999,999,999 HEading "Total|Writes"

prompt
prompt Successful database connections in last 24 hours 

select os_username
, username
, count(username) Successes
, sum(logoff_lread) Reads
, sum(logoff_lwrite) Writes
from dba_audit_session
where returncode = 0
and timestamp > (sysdate - 1)
group by os_username, username
order by os_username, username
/

prompt Default Audit Options
prompt

select * from all_def_audit_opts
/

*/

prompt
prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit


