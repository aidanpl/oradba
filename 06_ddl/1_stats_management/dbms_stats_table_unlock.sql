/*

 Name:          dbms_stats_table_unlock.sql

 Purpose:       Unlock stats at a table level 
 
 Usage:			Unlock stats for a single table 
                
 Example:        Example:       sqlplus -s sys/pw@sid as sysdba @dbms_stats_schema_unlock <schema_name> <table_name>

                sqlplus -s sys/pw@sid as sysdba @dbms_stats_schema_unlock HR EMPLOYEES
 
 Limitations:   None
 
 By default locked stats will be ignored. See procedures 
		DBMS_STATS.UNLOCK_TABLE_STATS(ownname,tabname) 

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

define script_name = 'dbms_stats_table_unlock'
set verify on
define schema_name  = '&1'
define table_name  = '&2'
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
       || lower('&table_name')
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

v_schema_name  VARCHAR2(30);
v_table_name   VARCHAR2(30);

BEGIN

v_schema_name := '&schema_name';
v_table_name := '&table_name';

   dbms_stats.unlock_table_stats(
         ownname => v_schema_name   
	   , tabname => v_table_name    
     );
     
END;
/

spool off
exit
