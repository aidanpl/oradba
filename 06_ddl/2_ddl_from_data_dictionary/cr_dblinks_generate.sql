/*

 Name:          cr_dblinks_generate.sql

 Purpose:       Generate dblink creation prior to schema level import. 
 
 Usage:         cr_dblinks_generate.sql
 
				Note output is deliberately created with 'IDENTIFIED BY <pw>'. Following script generation you should edit the file manually to provide the passwords 

 Example:       sqlplus -s user/pw@sid @cr_dblinks_generate.sql
                
 Date            Who             Description

 11th Feb 2016   Aidan Lawrence  Fresh rebuild
  5th Jun 2017   Aidan Lawrence  Validated pre git publication 								 
 
*/

/*

Typical output 

CREATE DATABASE LINK DBMON_DBAREP.TST21_DBMON CONNECT TO DBMON IDENTIFIED BY <pw>  USING 'tst21';
CREATE DATABASE LINK DBMON_DBAREP.TST22_DBMON CONNECT TO DBMON IDENTIFIED BY <pw>  USING 'tst22';

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

define script_name = 'cr_dblinks_generate'

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

select 'spool cr_dblinks_generate.log'
from dual
/

select 'Set time on' from dual;
select 'Set timing on' from dual;
select 'Set echo on' from dual;

select 'PROMPT Substitute <pw> with the appropriate password manually after script generation' from dual;

SELECT 'CREATE DATABASE LINK '
 || owner
 || '.'
 || db_link
 || ' CONNECT TO '
 || username
 || ' IDENTIFIED BY <pw> '
 || ' USING '
 || ''''
 || host
 || ''''
 || ';'
 FROM DBA_DB_LINKS
 ORDER BY owner, db_link;

select 'Set echo off' from dual;
select 'Spool off' from dual;
select 'exit' from dual;

spool off

set echo off
set time off
exit