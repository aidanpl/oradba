/*

 Name:          cr_synonyms_for_target_to_source.sql

 Purpose:       Script to generate synonyms to source schemae
 			
 Usage:         cr_synonyms_for_target_to_source <source_schema> <target_schema>
				Where <target_schema> will have private synonyms created to objects in <source_schema>
				Note the order of parameters - ON source FROM target (This is the opposite of grant applications)				
 
 Example:       sqlplus -s user/pw@sid @cr_synonyms_for_target_to_source.sql HR SH
				

  Date           Who             Description

 13th Jul 2012   Aidan Lawrence  Clone from similar
  5th Jun 2017   Aidan Lawrence  Validated pre git publication 								 

*/


/*
Example outpout 

CREATE SYNONYM  SH.ADD_JOB_HISTORY FOR  HR.ADD_JOB_HISTORY;
CREATE SYNONYM  SH.SECURE_DML FOR  HR.SECURE_DML;
CREATE SYNONYM  SH.DEPARTMENTS_SEQ FOR  HR.DEPARTMENTS_SEQ;

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

define script_name = 'cr_synonyms_for_target_to_source'
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

define source_user = '&1'
define target_user = '&2'

select 'spool cr_synonyms_for_&target_user._to_&source_user..log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

select 'CREATE SYNONYM ' 
|| ' &target_user.' 
|| '.'
|| o.object_name
|| ' FOR ' 
|| ' &source_user.' 
|| '.'
|| o.object_name
|| ';'
FROM dba_objects o 
WHERE o.owner = '&source_user' 
AND o.object_type in 
( 'FUNCTION'
, 'PACKAGE'
, 'PROCEDURE'
, 'SEQUENCE'
, 'TABLE'
, 'VIEW'
)
ORDER BY o.object_type, o.object_name;


select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

set echo off
set time off
exit