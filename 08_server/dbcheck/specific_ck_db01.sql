/*

 Name:          db01_specific_ck.sql

 Purpose:       Database specific checks 
 
 Usage:         Note driving script dbcheck.sh includes export DBCHECK_SPECIFIC_SQL=specific_ck_$ORACLE_SID.sql

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

define script_name = 'specific_ck_db01'


--
-- As this is directly called for monitoring keep spool simple 
--
spool &script_name

set termout on
set feedback on
set heading on 
set pages 99
set linesize 172


define partition_limit = 10

prompt
prompt Check if at least &partition_limit days worth of daily partitions have been created ahead
prompt 

column table_name format a30 Heading "Table|Name"
column days_ahead format 999 Heading "Days|Ahead"

SELECT 
  table_name
, days_ahead 
FROM dbmon.db01_partition_ck
WHERE days_ahead < &partition_limit;
	
spool off 
exit
