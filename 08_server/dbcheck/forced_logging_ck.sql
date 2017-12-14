/*

 Name:          forced_logging_ck.sql

 Purpose:       Check for any non logged activity 
 
 Usage:         forced_logging_ck.sql 

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

define script_name = 'forced_logging_ck'

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

set feedback off 

select 
  'Forced logging is set to '
|| force_logging as message 
  from v$database
;

set feedback on

column file# 			   format 9999 		  heading 'File|No.'
column first_nonlogged_scn format 999,999,999 heading 'First|Non-logged SCN'
column file_name    	   format a80 		  heading 'File Name |(Up to 80 characters)'

prompt
prompt Note the presence of any non-logged activity 
  
select 
  file#
, first_nonlogged_scn 
, substr(name,1,80) as file_name
from v$datafile 
where first_nonlogged_scn > 0
order by file_name;  
	
spool off 
exit
