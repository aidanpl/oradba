/*

 Name:          ts_growth_prediction_ck.sql

 Purpose:       Check tablespaces which will extend in the near future

 Usage:         ts_growth_prediction_ck.sql <time_limit> where time_limit represents a number of days
 
				Be aware that the view tbsp_stats_2_growth_predict is a user created view. 
				To avoid hardcoding schemas may need to create a public synonym 
				
				DROP PUBLIC SYNONYM tbsp_stats;
				CREATE PUBLIC SYNONYM tbsp_stats FOR dbmon.tbsp_stats;
				
				DROP PUBLIC SYNONYM tbsp_stats_2_growth_predict;
				CREATE PUBLIC SYNONYM tbsp_stats_2_growth_predict FOR dbmon.tbsp_stats_2_growth_predict;

 Date            Who             Description

set doc off

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

define script_name = 'ts_growth_prediction_ck'
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

column dbname                    format a8       heading 'Database|Name'
column generated_date            format a15      heading 'Stats|Generation Date'
column tablespace_name           format a30      heading 'Tablespace|Name'
column min_free_days_no_extend   format 999,990  trunc  heading 'Estimate|Days Free|No Extend'
column min_free_days_with_extend format 999,990  trunc  heading 'Estimate|Days Free|With Extend'

select
  dbname
, tablespace_name
, round(estimate_days_free_no_extend) as min_free_days_no_extend
, round(estimate_days_free_with_extend) as min_free_days_with_extend
, generated_date
from tbsp_stats_2_growth_predict
where estimate_days_free_no_extend <= &time_limit
order by estimate_days_free_no_extend asc
, tablespace_name
/

spool off
exit
