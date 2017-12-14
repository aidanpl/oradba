/*

 Name:          cre_syn_repository.sql

 Purpose:       Additional OraSASH views make use of v$session on the target database. To facilitate this create a named synonym on the repository for each target and then a single generic synonym which will point to the active target 

 PreRequisites:  
				Repository SASH schema is given CREATE SYNONYM privilege 
				SASH@target has been given access to v_$session - see cre_gr_target
 
 Usage:       sqlplus -s sash/pw@repo @cre_syn_repository <target> 
 
 Date            Who             Description

 9th Aug 2017    Aidan Lawrence  Revalidated for git

*/

--
-- As SYSDBA 

--CONNECT sys/<pw>@repository AS sysdba 
--GRANT CREATE SYNONYM TO sash;

--
-- As SASH - Repeat for each new database 
--

set heading off
set verify off
set pages 99
set feedback off
set trimspool on
set linesize 132
set termout off

define script_name = 'cre_syn_repository'
set verify on
define target  = '&1'
set verify off

--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower('&target')
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI')
       || '.lst' spool_name
  from dual d;

select 'Output report name is '
       || '&spool_name'
  from dual;

-- Adjust environment for specific scripts
--

set verify off
set feedback on
set termout on
set heading on
set echo on
set time on

spool &spool_name

column db_link       format a40 new_value target_db_link 
column db_target     format a40 new_value target_db
SELECT 
 st.db_link                             as db_link
, 'v$session_target_' || st.dbname      as db_target 
FROM sash_targets st
WHERE st.dbname = '&target'
 ;

--
-- Create the target specific synonym 

DROP SYNONYM &target_db
/
CREATE SYNONYM &target_db FOR v$session@&target_db_link
/

DROP SYNONYM v$session_target
/
CREATE SYNONYM v$session_target FOR &target_db
/

spool off 
exit