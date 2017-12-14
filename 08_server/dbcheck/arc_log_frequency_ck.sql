/*

 Name:          arc_log_frequency_ck.sql

 Purpose:       Check frequency of archive log switches to warn potential problems 
 
 Usage:         arc_log_frequency_ck.sql <switch_threshold> where switch_threshold switch count threshold

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

define script_name = 'arc_log_frequency_ck'
define switch_threshold = &1

--
-- As this is directly called for monitoring keep spool simple 
--
spool &script_name

set termout on
set feedback on
set heading on 
set pages 99
set linesize 172

column hour format a35 heading 'Hour'
column switches format 999 heading 'Switches'

select 
  Hour
, Switches
from (select 
        to_char(first_time,'Dy DD-MON HH24') Hour
	    , count(*) switches
        from v$log_history
        where first_time > sysdate - 1
        group by to_char(first_time,'Dy DD-MON HH24')
        order by to_date(to_char(first_time,'Dy DD-MON HH24'),'Dy DD-MON HH24') desc 
     )		
Where switches > &switch_threshold;
	
spool off 
exit
