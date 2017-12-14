/*

 Name:          dbms_stats_schema_lock.sql

 Purpose:       Unlock stats at a schema level 
 
 Usage:			Schema stats management
                
 Example:       sqlplus -s sys/pw@sid as sysdba @dbms_stats_schema_lock <schema_name>

                sqlplus -s sys/pw@sid as sysdba @dbms_stats_schema_lock HR
 
 Limitations:   None
 
 By default locked stats will be ignored. See procedures 
		DBMS_STATS.LOCK_SCHEMA_STATS(ownname) 
   or   DBMS_STATS.LOCK_TABLE_STATS(ownname,tabname) 

 Date            Who             Description

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

define script_name = 'dbms_stats_schema_lock'
set verify on
define schema_name  = '&1'
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
	   || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI')
       || '.lst' spool_name
  from v$database d;

select 'Output report name is '
       || '&spool_name'
  from dual;

-- Adjust environment for specific scripts
--


set feedback on
set termout on
set heading on
set echo on 
set time on

spool &spool_name

DECLARE

v_schema_name  varchar2(30);

BEGIN

v_schema_name := '&schema_name';

   dbms_stats.lock_schema_stats(
         ownname=> v_schema_name   -- Schema to lock
     );
     
END;
/

spool off
exit
