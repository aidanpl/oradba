set doc off
/*

 Name:          cr_roles_generate.sql

 Purpose:       Generate roles prior to schema level import. Include grants to desired users 
 
 Usage:			Role creation
 
 Example:       sqlplus -s user/pw@sid @cr_roles_generate.sql
 
 Limitations:   None

 Sanity checks: 
				Note the hardcoded list of roles to ignore. These are generally roles that are created during database creation or through common add on products (e.g. sample schemas). 
                Feel free to tweak these for personal preferences or as different versions evolve. 
                
 Date            Who             Description

 11th Feb 2016   Aidan Lawrence  Fresh build 
 31st May 2017   Aidan Lawrence  Validated pre git publication 								 
 
*/

-- Set up generic environment

set heading off
set verify off
set pages 99
set feedback off
set trimspool on
set linesize 172
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

define script_name = 'cr_roles_generate'

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

select 'spool cr_roles_generate.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

-- NB - individual define has limit of 240 characters
define ignore_roles_1 = ('DBA','RESOURCE','CONNECT','IMP_FULL_DATABASE','EXP_FULL_DATABASE','DBSNMP','RECOVERY_CATALOG_OWNER','SYS','SYSTEM','SNMPAGENT','SELECT_CATALOG_ROLE')
define ignore_roles_2 = ('AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','DELETE_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','GATHER_SYSTEM_STATISTICS','GLOBAL_AQ_USER_ROLE','HS_ADMIN_ROLE','LOGSTDBY_ADMINISTRATOR','OEM_ADVISOR','OEM_MONITOR','SCHEDULER_ADMIN')

SELECT 'CREATE ROLE '
|| lower (r.role)
|| ';'
FROM dba_roles r
where r.role NOT IN  &ignore_roles_1
and r.role NOT IN  &ignore_roles_2
ORDER BY r.role;

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

set echo off
set time off
exit