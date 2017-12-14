/*

 Name:          non_zero_audit_ck.sql

 Purpose:       Check for non zero audit actions in last x days 
 
 Usage:         non_zero_audit_ck.sql <time_limit> where <time_limit> represents a number of days

 Date            Who             Description

 12th Sep 2017   Aidan Lawrence  Validated for git

*/

-- Set up environment
      

set heading off
set verify off 
set feedback off
set trimspool on
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

define script_name = 'non_zero_audit_ck'
define time_limit = &1

--
-- As this is directly called for monitoring keep spool simple 
--
spool &script_name

set termout on
set feedback on
set heading on 
set pages 99
set linesize 172

column os_username 		format a30 heading 'OS|Username'
column username    		format a30 heading 'DB|Username'
column userhost    		format a20 heading 'User|Host'
column returncode_desc 	format a25 heading 'Return Code|Description'
column action_name 		format a20 heading 'Action|Name'
column audit_time  		format a20 heading 'Audit|Time'

select 
  case returncode
	WHEN 1017 THEN 'Invalid User/Password'
	ELSE to_char(returncode)
  END 										  as returncode_desc  
, to_char(Timestamp,'DD-MON-YYYY HH24:MI:SS') as audit_time
, OS_Username
, Username
, UserHost
, Action_name
from dba_audit_session
where returncode <> 0
and timestamp > sysdate - &time_limit;

spool off 
exit
