/*

 Name:           sql_plus_autotrace_examples.sql

 Contents:       Autotrace examples

 Usage:			 A series of simple examples using the HR sample schema. Please see Oracle documentation SQL*Plus Users Guide for further detail, including guidance on how to interpret the database statistics
 
 Pre_requisite:  Check the schema has the correct permissions as described in sql_trace_schema_prep.sql 
 
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

define script_name = 'sql_plus_autotrace_examples'
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


/*

Autotrace options:
SET AUTOTRACE ON            Shows Execution plan, the SQL statement execution statistics and query output if any. 
SET AUTOTRACE ON EXPLAIN    Shows Execution plan and query output if any. 
SET AUTOTRACE ON STATISTICS Shows the SQL statement execution statistics and query output if any.
SET AUTOTRACE TRACEONLY     Suppresses the query output if any. 
SET AUTOTRACE OFF

TRACEONLY is useful for queries returning large numbers of rows not of interest during the tuning investigation. It is most often used in combination with EXPLAIN but works perfectly well on its own or with STATISTICS

For example 
SET AUTOTRACE TRACEONLY EXPLAIN - shows explain plan and suppresses output 

*/

--
-- AUTOTRACE on - explain plan and stats

set autotrace on

SELECT e.employee_id
, e.first_name
, e.last_name
, d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;

/*
SQL> /

EMPLOYEE_ID FIRST_NAME           LAST_NAME                 DEPARTMENT_NAME
----------- -------------------- ------------------------- ------------------------------
        200 Jennifer             Whalen                    Administration
        201 Michael              Hartstein                 Marketing
        202 Pat                  Fay                       Marketing
        114 Den                  Raphaely                  Purchasing
..
..
..		

Execution Plan
----------------------------------------------------------
Plan hash value: 1343509718

--------------------------------------------------------------------------------------------
| Id  | Operation                    | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |             |   106 |  4028 |     6  (17)| 00:00:01 |
|   1 |  MERGE JOIN                  |             |   106 |  4028 |     6  (17)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS |    27 |   432 |     2   (0)| 00:00:01 |
|   3 |    INDEX FULL SCAN           | DEPT_ID_PK  |    27 |       |     1   (0)| 00:00:01 |
|*  4 |   SORT JOIN                  |             |   107 |  2354 |     4  (25)| 00:00:01 |
|   5 |    TABLE ACCESS FULL         | EMPLOYEES   |   107 |  2354 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID")
       filter("E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID")
	   
	   
Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
         19  consistent gets
          0  physical reads
          0  redo size
       4627  bytes sent via SQL*Net to client
        629  bytes received via SQL*Net from client
          9  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
        106  rows processed

*/


--
-- AUTOTRACE traeonly eon - explain plan and stats

set autotrace traceonly explain 

SELECT e.employee_id
, e.first_name
, e.last_name
, d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;

/*
Execution Plan
----------------------------------------------------------
Plan hash value: 1343509718

--------------------------------------------------------------------------------------------
| Id  | Operation                    | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |             |   106 |  4028 |     6  (17)| 00:00:01 |
|   1 |  MERGE JOIN                  |             |   106 |  4028 |     6  (17)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPARTMENTS |    27 |   432 |     2   (0)| 00:00:01 |
|   3 |    INDEX FULL SCAN           | DEPT_ID_PK  |    27 |       |     1   (0)| 00:00:01 |
|*  4 |   SORT JOIN                  |             |   107 |  2354 |     4  (25)| 00:00:01 |
|   5 |    TABLE ACCESS FULL         | EMPLOYEES   |   107 |  2354 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - access("E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID")
       filter("E"."DEPARTMENT_ID"="D"."DEPARTMENT_ID")
	   
*/  

spool off
exit 
