/*

 Name:          cr_app_users_generate.sql

 Purpose:       Generate User creation with default pw to pre-empt schema level import on new, clean databases
 
 Usage:			Schema creation
                
 Example:       sqlplus -s user/pw@sid @cr_app_users_generate.sql
 
 Limitations:   None

 Sanity checks: 
				Note the hardcoded list of schemas to ignore. These are generally schemas that are created during database creation or through common add on products (e.g. sample schemas). 
                Feel free to tweak these for personal preferences or as different versions evolve. 
				
 Date            Who             Description

 11th Feb 2016   Aidan Lawrence  Fresh clean build 
  3rd Mar 2016   Aidan Lawrence  Added second spool file to generate comma delimited user list using LISTAGG for things like datapump import 
								 NB This will only work against an 11.2 or higher database. May need to run run on target rather than source database 
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

define script_name = 'cr_app_users_generate'

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

select 'spool cr_app_users_generate.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

-- NB - individual define has limit of 240 characters - use two :-) 
define ignore_schemas_1 = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
define ignore_schemas_2 = ('DMSYS','ANONYMOUS','MGMT_VIEW','SCOTT','TSMSYS','DIP','ORACLE_OCM')

SELECT 'CREATE USER '
|| lower (u.username)
|| ' IDENTIFIED BY '
|| lower (u.username) 
|| '_' 
|| lower (i.instance_name)
|| ' DEFAULT TABLESPACE ' 
|| u.default_tablespace 
|| ' TEMPORARY TABLESPACE ' 
|| u.temporary_tablespace
|| ';'
FROM dba_users u
CROSS JOIN v$instance i
WHERE u.username NOT IN  &ignore_schemas_1
AND u.username NOT IN  &ignore_schemas_2
ORDER BY u.username;

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

--
-- Repeat above query this time to generate comma delimited list 
--

select 'spool cr_app_users_comma_delimited.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

--
-- Lists copied from above to aid adhoc manual running of these scripts 

-- NB - individual define has limit of 240 characters - use two :-) 
define ignore_schemas_1 = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
define ignore_schemas_2 = ('DMSYS','ANONYMOUS','MGMT_VIEW','SCOTT','TSMSYS','DIP','ORACLE_OCM')

SELECT LISTAGG(username, ',') WITHIN GROUP (order BY username) as users
  FROM dba_users
WHERE u.username NOT IN  &ignore_schemas_1
AND u.username NOT IN  &ignore_schemas_2;

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

set echo off
set time off
exit