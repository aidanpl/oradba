/*

 module:        cr_synonyms_public.sql

 purpose:       Script to recreate public synonyms for non-internal schemas 
 
 usage:         1) connect to sysdba and/or source schema and run this script
				2) connect to sysdba and/or target schema and run the output 

 Date            Who             Description 

 11th Feb 2016   Aidan Lawrence  Fresh clean build
  5th Jun 2017   Aidan Lawrence  Validated pre git publication 								 
*/


/*

Edited list - should only need synonyms to core package specs

CREATE PUBLIC SYNONYM  PKG_ERP_LOCATIONS      FOR  remedy.PKG_ERP_LOCATIONS;
CREATE PUBLIC  SYNONYM  PKG_ERP_PERSON_DETAILS FOR  remedy.PKG_ERP_PERSON_DETAILS;

etc.
etc.

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

define script_name = 'cr_synonyms_public'
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

set termout on

spool &spool_name


--
-- Synonyms to 
--

-- NB - individual define has limit of 240 characters - use two :-) 
define ignore_schemas_1 = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
define ignore_schemas_2 = ('DMSYS','ANONYMOUS','MGMT_VIEW','SCOTT','TSMSYS','DIP','ORACLE_OCM')


select 'spool cr_synonyms_public.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

select 'CREATE PUBLIC SYNONYM ' 
|| s.synonym_name 
|| ' FOR ' 
|| s.table_owner
|| '.'
|| s.table_name
|| ';'
FROM dba_synonyms s 
WHERE s.table_owner not in &ignore_schemas_1
AND s.table_owner not in &ignore_schemas_2
AND s.owner='PUBLIC' 
ORDER BY s.table_owner, s.table_name;


select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

set echo off
set time off
exit