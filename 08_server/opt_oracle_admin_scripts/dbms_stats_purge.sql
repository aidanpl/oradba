/*

 Name:          dbms_stats_purge.sql

 Purpose:       Manually purge the stats history. Only need to consider this if table SYS.WRI$_OPTSTAT_HISTGRM_HISTORY is growing 
 
 Contents:  	See Oracle doc 1055547.1 for further information on this bug 
                Also useful writeup on https://oraworklog.wordpress.com/2010/07/24/handling-smoptstat-component-growth-in-sysaux-tablespace/ (accessed 23rd Sep 2015)
				
				Check/Set retention periods with:
				
				3.Default retention of this information is obtained with below command:

				select dbms_stats.get_stats_history_retention from dual;
				exec dbms_stats.alter_stats_history_retention(10);
				
				Following significant purge consider rebuilding the larger tables with:
				
				ALTER TABLE SYS.WRI$_OPTSTAT_HISTGRM_HISTORY MOVE;
				ALTER INDEX I_WRI$_OPTSTAT_H_OBJ#_ICOL#_ST REBUILD ONLINE TABLESPACE SYSAUX;
				ALTER INDEX I_WRI$_OPTSTAT_H_ST REBUILD ONLINE TABLESPACE SYSAUX;

				
 Date            Who             Description

 20th Sep 2015   Aidan Lawrence  Cloned from similar
 12th Sep 2017   Aidan Lawrence  Validated for git 

*/

-- Set up environment
      
set heading off
set verify off 
set pages 99
set feedback off
set trimspool on
set linesize 132
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

define script_name = 'dbms_stats_purge'

define days_retention = '&1'

--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || '&days_retention'
       || '.lst' spool_name
  from v$database d;
  
select 'Output report name is ' 
       || '&spool_name'
  from dual;  

spool &spool_name

set feedback on
set termout on 
set time on

set pages 99
set heading on

-- Note volume of historical stats before hand with:
col stats_date format a5 heading 'Stats|Date'
col row_count format 999,999 heading 'Row|Count'

select to_char(savtime,'MM-DD') as stats_date
, count(*) as row_count
from WRI$_OPTSTAT_HISTGRM_HISTORY
GROUP BY to_char(savtime,'MM-DD')
ORDER BY to_char(savtime,'MM-DD') desc
/

prompt
prompt Executing dbms_stats.purge_stats

BEGIN
   dbms_stats.purge_stats(
         before_timestamp => to_timestamp(sysdate-&days_retention) -- time to purge stats before 
     );

END;
/


-- Note volume of historical stats after with:

select to_char(savtime,'MM-DD') as stats_date
, count(*) as row_count
from WRI$_OPTSTAT_HISTGRM_HISTORY
GROUP BY to_char(savtime,'MM-DD')
ORDER BY to_char(savtime,'MM-DD') desc
/

spool off
exit
