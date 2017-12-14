/*

 Name:          dbms_stats_fixed objects.sql

 Purpose:       Refresh fixed objects stats 
 
				DBMS_STATS.GATHER_FIXED_OBJECTS_STATS will gather stats for all fixed objects (v_$_xxx dynamic performance
 
 Usage:			sqlplus -s sys/pw@sid as sysdba @dbms_stats_fixed objects
 
DBMS_STATS.GATHER_FIXED_OBJECTS_STATS (
stattab VARCHAR2 DEFAULT NULL,
statid VARCHAR2 DEFAULT NULL,
statown VARCHAR2 DEFAULT NULL,
no_invalidate BOOLEAN DEFAULT to_no_invalidate_type (
get_param('NO_INVALIDATE')));
 				
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

--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

define script_name = 'dbms_stats_fixed_objects'

select '&script_name'
       || '_'
       || lower(d.name)
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

BEGIN

   dbms_stats.gather_fixed_objects_stats;
     
END;
/

spool off
exit
