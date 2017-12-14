/*

 Name:          lock_ck.sql

 Purpose:       Current locks on a system

 Date            Who             Description

20th Oct 2009    Aidan Lawrence  Tidied up from similar
20th Apr 2017    Aidan Lawrence  Changed to access from views and col definitions to login.sql  
*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'lock_ck'
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

prompt 
prompt Report Details are &spool_name                     
prompt

set heading off
set feedback off 

SELECT 'Database Name: ' || value FROM v$parameter where name='db_name'
/

SELECT 'Generated On ' ||  to_char(sysdate,'dd Month YYYY  HH24:MI') today from dual
/

set heading on
set feedback on 

-- See login.sql for col definitions 
--
-- Current Locks 
--

prompt
prompt Current locks

/*

Comments on the what the most common locks mean: 

Row Share Table Locks (RS) A row share table lock (also sometimes called a subshare table lock, SS)
                           indicates that the transaction holding the lock on the table has
                           locked rows in the table and intends to update them.
                           
                           SELECT ... FROM table ... FOR UPDATE OF ...
                           
Row Exclusive Table Locks (RX) A row exclusive table lock (also called a subexclusive table lock, SX) 
                               generally indicates that the transaction holding the lock has made
                               one or more updates to rows in the table. A row exclusive table lock is acquired
                               automatically for a table modified by the following types of statements:
                               
                               INSERT INTO table ... ;
                               UPDATE table ... ;
                               DELETE FROM table ... ;                           

Any of RS/SS or RX/SX basically means one or more rows on the table is locked and cannot be updated by another transaction. 

Other locks should only be seen in very specific scenarios such as use of the rare LOCK command, or when DDL (e.g. index rebuilds) is taking place)
                               
*/
--
-- Current locks 
-- 
SELECT 
       schemaname 
     , osuser
     , object_owner
     , object_name
     , locked_mode
     , ses_start_time
     , tran_start_time 
     , status       
     , program
     , machine
     , sid 
     , serial#
     , undo_blocks
     , log_io
FROM lock_1_current_locks
/

prompt
prompt end of report

spool off
-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit
