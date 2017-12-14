/*

 Name:          cr_directories_generate.sql

 Purpose:       Generate directory creation and related grants as part of migration
 
 Usage:         cr_directories_generate.sql
 
 Example:       sqlplus -s user/pw@sid @cr_directories_generate.sql
 
				Output from this will invariably need editing to reflect which directories are required in new database and probable amended paths 
                
  Date            Who             Description

  16th Feb 2016   Aidan Lawrence  Fresh rebuild
   5th Jun 2017   Aidan Lawrence  Validated pre git publication 								 
 
*/

/*

Typical output 

CREATE OR REPLACE DIRECTORY  SYS.DATA_PUMP_DIR AS '/opt/oracle/product/11.2.0/db_1/rdbms/log/';
CREATE OR REPLACE DIRECTORY  SYS.DP_STD_DIR AS '/orabackup/datapump/';
CREATE OR REPLACE DIRECTORY  SYS.XMLDIR AS '/opt/oracle/product/11.2.0/dbhome_1/rdbms/xml';
GRANT READ ON DIRECTORY DATA_PUMP_DIR TO EXP_FULL_DATABASE;
GRANT WRITE ON DIRECTORY DATA_PUMP_DIR TO EXP_FULL_DATABASE;
GRANT READ ON DIRECTORY DATA_PUMP_DIR TO IMP_FULL_DATABASE;
GRANT WRITE ON DIRECTORY DATA_PUMP_DIR TO IMP_FULL_DATABASE;
GRANT READ ON DIRECTORY DP_STD_DIR TO DBMON;
GRANT WRITE ON DIRECTORY DP_STD_DIR TO DBMON;


*/
-- Set up generic environment

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

define script_name = 'cr_directories_generate'

--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

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

set lines 132
set pages 0
set termout on
set feedback off
set verify off
set echo off

spool &spool_name

select 'spool cr_directories_generate.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

SELECT 'CREATE OR REPLACE DIRECTORY  '
 || owner
 || '.'
 || directory_name
 || ' AS '
 || ''''
 || directory_path 
  || ''''
 || ';'
 FROM dba_directories
 ORDER BY owner, directory_name;
 
 
 SELECT 'GRANT ' 
|| privilege
|| ' ON DIRECTORY ' 
|| table_name 
|| ' TO ' 
|| grantee
|| ';'
FROM DBA_TAB_PRIVS
WHERE table_name IN (SELECT directory_name from dba_directories)
ORDER BY table_name, grantee, privilege;


select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

set echo off
set time off
exit