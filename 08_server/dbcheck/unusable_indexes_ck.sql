/*

 Name:          unusable_indexes_ck.sql

 Purpose:       Check for any unusables indexes
 
 Usage:         unusable_indexes_ck.sql 

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

define script_name = 'unusable_indexes_ck'

--
-- As this is directly called for monitoring keep spool simple 
--
spool &script_name

set termout on
set feedback on
set heading on 
set pages 99
set linesize 172

column message   	   format a60 heading 'Message'

select index_name||' is Unusable and Requires Rebuild ' as message 
  from dba_indexes
  where status not in ('VALID','N/A');
	
spool off 
exit
