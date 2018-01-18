/*

 Name:           sql_trace_session_for_tkprof_analysis.sql

 Contents:       Example for generating trace files at session level for tkprof 

 Usage:			 A series of simple examples using the HR sample schema. Please see Oracle documentation Performance Tuning Guide for further detail.
 
				 NB This example deliberately sticks to tracing at session level. Tracing at instance level can generate vast quanties of data - please look that up yourself if you really really - yes really - want to do that. 
 
 Pre_requisite:  
				1) Validate the settings of TIMED_STATISTICS, MAX_DUMP_FILE_SIZE and DIAGNOSTIC_DEST as described in Oracle documentation. 
				2) Check the schema has the correct permissions as described in sql_trace_schema_prep.sql 
 
 Date            Who             Description

 16th Jan 2018   Aidan Lawrence  Cleaned up notes for git 

*/

-- Set up environment

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

define script_name = 'sql_trace_session_for_tkprof_analysis'
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

spool &spool_name

-- Set up environment

set echo on
set timing on


-- 1) Optionally set a specific identifier to help identify trace file. 
--    Choose an identifier that will generate a workable file name at OS level - e.g. avoid spaces. 
--    This will actually name the trace file in the diag directory.  

ALTER SESSION SET TRACEFILE_IDENTIFIER = 'BUG-123_HR_emp_dept';

/*

opt/oracle/diag/rdbms/dbarep/dbarep/trace $ ls -ltr
..
-rw-r----- 1 oracle dba      142 Jan 18 09:54 dbarep_ora_1679_BUG-123_HR_emp_dept.trm
-rw-r----- 1 oracle dba     5367 Jan 18 09:54 dbarep_ora_1679_BUG-123_HR_emp_dept.trc
..

*/

-- 2) Turn on session trace  

EXEC DBMS_SESSION.SET_SQL_TRACE(sql_trace => TRUE); 

-- 3) Run some queries and/or PL/SQL as desired 

SELECT e.employee_id
, e.first_name
, e.last_name
, d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;

SELECT DISTINCT location_id
FROM departments;

-- 4) Turn off session trace  
 
EXEC DBMS_SESSION.SET_SQL_TRACE(sql_trace => FALSE); 

spool off
exit 
