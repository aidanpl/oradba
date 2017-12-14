/*

 Name:          mview_refresh_ck.sql

 Purpose:       Check for mviews not refreshed in last x hours

 Usage:         mview_refresh_ck.sql <time_limit> where time_limit represents a number of hours

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

-- Time limit should be specified in hours 

define script_name = 'mview_refresh_ck'
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

column owner             format a20 heading 'Owner'
column mview_name        format a30 heading 'Mview|Name'
column compile_state     format a20 heading 'Compile|State'
column last_refresh_date format a16 heading "Last|Refresh Time"

select
  dmrt.owner                                         as owner
, dmrt.name                                          as mview_name
, dmv.compile_state                                  as compile_state
, to_char(dmv.last_refresh_date,'DD-MON HH24:MI:SS') as last_refresh_date
from dba_mview_refresh_times dmrt
, dba_mviews dmv
where dmrt.owner = dmv.owner
and   dmrt.name = dmv.mview_name
AND dmv.last_refresh_date < sysdate - &time_limit/24 
order by
dmrt.owner
, last_refresh_date desc
/

spool off
exit
