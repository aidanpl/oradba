set doc off
/*

 Name:          cr_sequences_generate.sql

 Purpose:       Generate Sequence creation 
 
 Usage:			Sequence creation with associated grants 
 
 Example:       sqlplus -s user/pw@sid @cr_roles_generate.sql
 
 Limitations:   As well as the CREATE SEQUENCE output, the script also includes grants 
 
				Note issue with CACHE 0 generation. The script deliberately outputs a ** APL ** warning to manually edit these out 

 Sanity checks: 
				Note the hardcoded list of schemas to ignore. These are generally roles that are created during database creation or through common add on products (e.g. sample schemas). 
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
set linesize 132
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

define script_name = 'cr_sequences_generate'

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

select 'spool cr_seguences_generate.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

-- NB - individual define has limit of 240 characters - use two :-) 
define ignore_schemas_1 = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
define ignore_schemas_2 = ('DMSYS','ANONYMOUS','MGMT_VIEW','SCOTT','TSMSYS','DIP','ORACLE_OCM')


--
-- Sequences last numbes cannot be altered. Need to drop, create and redo grants. 
 
--
-- First generate the drop commands
-- 
SELECT 'DROP SEQUENCE '
|| s.sequence_owner
|| '.'
|| s.sequence_name
|| ';' 
FROM dba_sequences s
where s.sequence_owner NOT IN  &ignore_schemas_1
AND s.sequence_owner NOT IN  &ignore_schemas_2
ORDER BY s.sequence_owner, s.sequence_name;

--
-- Now generate create commands, starting with (last_number plus increment_by)

prompt 
prompt ** APL ** Manually remove any CACHE 0 output 
 
SELECT 'CREATE SEQUENCE '
|| s.sequence_owner
|| '.'
|| s.sequence_name
|| ' INCREMENT BY ' 
|| s.increment_by 
|| ' START WITH ' 
|| (s.last_number + s.increment_by)
|| ' MINVALUE '
|| s.min_value
|| ' MAXVALUE '
|| s.max_value
|| ' CACHE '
|| s.cache_size 
|| CASE s.cycle_flag 
	WHEN 'Y' THEN ' CYCLE '
	ELSE ' '
   END 
|| CASE s.order_flag
	WHEN 'Y' THEN ' ORDER '
	ELSE ' '
   END    
|| ';'   
FROM dba_sequences s
where s.sequence_owner NOT IN  &ignore_schemas_1
AND s.sequence_owner NOT IN  &ignore_schemas_2
ORDER BY s.sequence_owner, s.sequence_name;

--
-- Add in any grants 

select 'GRANT '
|| p.privilege  
|| ' ON '
|| p.grantor 
|| '.'
|| p.table_name
|| ' TO ' 
|| p.grantee
|| ';'
FROM dba_tab_privs p
join dba_sequences s
ON p.owner = s.sequence_owner
and p.table_name = s.sequence_name
where s.sequence_owner NOT IN  &ignore_schemas_1
AND s.sequence_owner NOT IN  &ignore_schemas_2
ORDER BY s.sequence_owner, s.sequence_name;

/*

Optionally show the distribution of sequences for sanity check 

SELECT sequence_owner, count(*)
FROM dba_sequences
GROUP BY ROLLUP(sequence_owner);

*/


select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

set echo off
set time off
exit