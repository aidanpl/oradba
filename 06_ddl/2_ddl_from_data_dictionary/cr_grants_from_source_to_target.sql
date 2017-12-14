/*

 Name:          cr_grants_from_source_to_target.sql

 Purpose:       Script to create suitable grants from source to target
 
 Usage:         cr_grants_from_source_to_target.sql <source_schema> <target_schema>
				Where <target_schema> will provide grants to the <source_schema>
				Note the order of parameters - FROM source TO target (This is the opposite of synonym creation)
 
 Example:       sqlplus -s user/pw@sid @cr_grants_from_source_to_target.sql SH HR 
 
 Date            Who             Description

 16th Jan 2012   Aidan Lawrence  Clone from similar
  5th Jun 2017   Aidan Lawrence  Validated pre git publication 								 

*/


/*

Typical output 

GRANT SELECT ON SH.CAL_MONTH_SALES_MV TO HR;
GRANT SELECT ON SH.CHANNELS TO HR;
GRANT SELECT ON SH.COSTS TO HR;

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

define script_name = 'cr_grants_from_source_to_target'
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

select 'spool cr_grants_from_&source_user._to_&target_user..log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

select 'GRANT EXECUTE ON' 
|| ' &source_user..' 
|| o.object_name
|| ' TO' 
|| ' &target_user.' 
|| ';'
FROM dba_objects o 
WHERE o.owner = '&source_user' 
AND o.object_type in 
( 'PACKAGE','PROCEDURE','FUNCTION','TYPE' )
ORDER BY o.object_type, o.object_name;

--
-- Tables, views, sequences etc SELECT 

select 'GRANT SELECT ON' 
|| ' &source_user..' 
|| o.object_name
|| ' TO' 
|| ' &target_user.' 
|| ';'
FROM dba_objects o 
WHERE o.owner = '&source_user' 
AND o.object_type in 
( 'TABLE','VIEW','SEQUENCE')
ORDER BY o.object_type, o.object_name;

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

set echo off
set time off
exit
