/*

 Name:          lock_view_vw.sql

 Purpose:       Lock level views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

  Required direct Grants for view creations
 
 GRANT SELECT ON dba_objects      to DBMON;
 GRANT SELECT ON v_$locked_object to DBMON;
 GRANT SELECT ON v_$session       to DBMON;
 GRANT SELECT ON v_$transaction   to DBMON;
 
 /*

Current locks 
 
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

NB dba_objects joined to in the subquery for performance reasons. Without this pre-join  to v$locked_object it runs and runs and runs...
 
 Next Steps:

 Date            Who             Description

 18th Apr 2017   Aidan Lawrence  Cloned from similar
 27th Jun 2017   Aidan Lawrence  Validated pre git publication     

*/

CREATE OR REPLACE VIEW lock_1_current_locks
AS
SELECT 
       s.username                                as schemaname 
     , lo.os_user_name                           as osuser 
     , a.owner                                   as object_owner
     , a.object_name
     , CASE lo.locked_mode
       WHEN 0 THEN 'None'
       WHEN 1 THEN 'Null (NULL)'
       WHEN 2 THEN 'Row-Share '
       WHEN 3 THEN 'Row-Exclusive'
       WHEN 4 THEN 'Share (S)'
       WHEN 5 THEN 'S/Row-X (SSX)'
       WHEN 6 THEN 'Exclusive (X)'
       END                                       as locked_mode
     , TO_CHAR(s.logon_Time,'DD-MON HH24:MI:SS') as ses_start_time
     , to_char(to_date(t.start_time,'MM/DD/YY HH24:MI:SS'),'DD-MON HH24:MI:SS') as tran_start_time -- Yes original is a varchar2(20)!
     , s.status       
     , substr(s.program,1,20)                    as program
     , s.machine
     , s.sid 
     , s.serial#
     , t.used_ublk                               as undo_blocks
     , t.log_io
FROM   v$locked_object lo
JOIN  v$session s
ON    lo.session_id = s.sid
LEFT JOIN  v$transaction t
ON s.taddr = t.addr
JOIN  (select lo2.session_id
               , do.object_id
               , do.owner
               , do.object_name
          from dba_objects do
             , v$locked_object lo2
          where do.object_id = lo2.object_id
         ) a
ON     (lo.object_id = a.object_id
and    s.sid = a.session_id 
)
ORDER BY 
       schemaname
       , object_name
       , locked_mode
       , osuser
       , sid
       , serial#
/

