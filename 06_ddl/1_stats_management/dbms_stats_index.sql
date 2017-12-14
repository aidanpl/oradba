/*

 Name:          dbms_stats_index.sql

 Purpose:       Refresh/rebuild stats at a index level

 Usage:

 Example:       sqlplus -s user/pw@sid @dbms_stats_index <schema_name> <index_name>

                sqlplus sh/<pw>@sid @dbms_stats_index SH CUSTOMERS_PK


 Limitations:   Potential for locked stats

Another issue to consider is whether stats are locked at a table level. By default locked stats will be ignored. See procedure
        DBMS_STATS.UNLOCK_TABLE_STATS(ownname,tabname)

   script dbms_stats_unlock_index.sql will unlock at a index level

   DBMS_STATS.GATHER_INDEX_STATS (
ownname VARCHAR2,
indname VARCHAR2,
partname VARCHAR2 DEFAULT NULL,
estimate_percent NUMBER DEFAULT to_estimate_percent_type
(get_param('ESTIMATE_PERCENT')),
degree NUMBER DEFAULT to_degree_type(get_param('DEGREE')),
granularity VARCHAR2 DEFAULT GET_PARAM('GRANULARITY'),
no_invalidate BOOLEAN DEFAULT to_no_invalidate_type (
get_param('NO_INVALIDATE')),
force BOOLEAN DEFAULT FALSE);

 Date            Who             Description

 20th Jun 2005   Aidan Lawrence  Cloned from similar
 13th Jul 2017   Aidan Lawrence  Refreshed/revalidated pre git publication

*/

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

define script_name = 'dbms_stats_index'
set verify on
define schema_name  = '&1'
define index_name  = '&2'
set verify off

--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || lower('&schema_name')
       || '_'
       || lower('&index_name')
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI')
       || '.lst' spool_name
  from v$database d;

select 'Output report name is '
       || '&spool_name'
  from dual;

-- Adjust environment for specific scripts
--

set verify on
set feedback on
set termout on
set heading on
set echo on
set time on

spool &spool_name

DECLARE

v_schema_name  VARCHAR2(30);
v_index_name   VARCHAR2(30);

BEGIN

v_schema_name := '&schema_name';
v_index_name := '&index_name';

   dbms_stats.gather_index_stats(
         ownname          => v_schema_name -- Schema to generate stats for
       , indname          => v_index_name
       , partname         => NULL
       , estimate_percent => NULL  -- default analyze 20 percent of rows
       --degree             => NULL
	   --noinvalidate       => 
       --granularity        => ALL
       --force              => FALSE
     );

END;
/

spool off
exit
