/*

 Name:          gen_disable_enable_triggers.sql

 Purpose:       Generate trigger disable commands - for triggers that are currently enabled, use before dataonly imports 

 Date            Who             Description

  2nd Feb 2012    Aidan Lawrence  Refined for import 
 31st May 2017    Aidan Lawrence  Validated pre git publication 								  
 
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

define script_name = 'gen_disable_triggers'

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

select 'spool gen_disable_triggers.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

-- NB - individual define has limit of 240 characters - use two :-) 
define ignore_schemas_1 = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
define ignore_schemas_2 = ('DMSYS','ANONYMOUS','MGMT_VIEW','SCOTT','TSMSYS','DIP','ORACLE_OCM','APEX_050000')

select 'ALTER TRIGGER ' 
|| owner 
|| '.'
|| trigger_name 
|| ' DISABLE '
|| ';' 
FROM dba_triggers
where status = 'ENABLED'
AND owner NOT IN  &ignore_schemas_1
AND owner NOT IN  &ignore_schemas_2
ORDER BY owner, trigger_name
/

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off 

--
-- Repeat generating the equivalent enable commands in the correct order 
--

define script_name = 'gen_enable_triggers'

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

select 'spool gen_enable_triggers.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

-- NB - individual define has limit of 240 characters - use two :-) 
define ignore_schemas_1 = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
define ignore_schemas_2 = ('DMSYS','ANONYMOUS','MGMT_VIEW','SCOTT','TSMSYS','DIP','ORACLE_OCM','APEX_050000')

select 'ALTER TRIGGER ' 
|| owner 
|| '.'
|| trigger_name 
|| ' ENABLE '
|| ';' 
FROM dba_triggers
where status = 'ENABLED'
AND owner NOT IN  &ignore_schemas_1
AND owner NOT IN  &ignore_schemas_2
ORDER BY owner, trigger_name
/

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;


spool off
exit
