/*

 Name:          failed_logins_ck.sql

 Purpose:       Check for excessive failed login attempts 
 
 Usage:         failed_logins_ck.sql <failure_limit> where failure_limit represents a number of failed attempts

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

define script_name = 'failed_logins_ck'
define failure_limit = &1

--
-- As this is directly called for monitoring keep spool simple 
--
spool &script_name

set termout on
set feedback on
set heading on 
set pages 99
set linesize 172

column username        format a30 heading 'Username'
column failed_attempts format 99  heading 'Failed|Attempts'

select 
  name   as username
, lcount as failed_attempts
from sys.user$
where lcount >= &failure_limit;
	
spool off 
exit
