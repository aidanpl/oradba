set doc off
/*

 Name:          cr_app_users_pw_10g.sql

 Purpose:       Generate User creation with original pw - version specific - 10g and before 
 
 Usage:			Schema creation in a new database 
 
 Example:       sqlplus -s user/pw@sid @cr_app_users_pw_10g.sql
 
 Limitations:   None

 Sanity checks: 
				Note the hardcoded list of schemas to ignore. These are generally schemas that are created during database creation or through common add on products (e.g. sample schemas). 
                Feel free to tweak these for personal preferences or as different versions evolve. 
                
 Date            Who             Description

 11th Feb 2016   Aidan Lawrence  Fresh clean build 
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

define script_name = 'cr_app_users_pw_10g'

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


set lines 172
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
|| u1.username
|| ' IDENTIFIED BY VALUES '
|| ''''
|| u1.password
|| ''''
|| ' DEFAULT TABLESPACE ' 
|| u1.default_tablespace 
|| ' TEMPORARY TABLESPACE ' 
|| u1.temporary_tablespace
|| ' PROFILE '
|| u1.profile 
|| ';'
FROM dba_users u1
join user$ u2 
on u1.username = u2.name 
where u1.username NOT IN  &ignore_schemas_1
AND u1.username NOT IN  &ignore_schemas_2
ORDER BY u1.username;

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

set echo off
set time off
exit