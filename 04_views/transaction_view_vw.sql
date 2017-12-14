/*

 Name:          transaction_view_vw.sql

 Purpose:       Transaction level views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

--  Required direct Grants for view creations
 
 GRANT SELECT ON v_$session         to DBMON;
 GRANT SELECT ON v_$session_longops to DBMON;
 GRANT SELECT ON v_$process         to DBMON;
 GRANT SELECT ON v_$transaction     to DBMON;
 
 Next Steps:

 Date            Who             Description

 18th Apr 2017   Aidan Lawrence  Cloned from similar
 15th Jun 2017   Aidan Lawrence  Validated for git  

*/

CREATE OR REPLACE VIEW trn_1_current_transactions
AS 
SELECT 
  s.status 
, NVL(p.pname,'(Foreground)') 	AS processname 
, s.osuser 
, s.schemaname 
, TO_CHAR(s.logon_time,'DY-DD-MON-YYYY HH24:MI') AS ses_start_time 
, ROUND(p.pga_used_mem/1048976,1)  as pga_used_mb
, ROUND(p.pga_alloc_mem/1048976,1) as pga_alloc_mb
, SUBSTR(s.program,1,15) 		AS program 
, SUBSTR(s.event,1,15)   		AS event 
, s.wait_time 
, s.seconds_in_wait 
, s.state 
, t.start_time 					AS tran_start_time -- Yes this is a varchar2(20)!
, t.used_ublk 					AS undo_blocks 
, t.log_io 
, t.phy_io 
, s.sid 
, s.serial# 
, SUBSTR(p.spid,1,6) 			AS os_process
FROM v$session s
JOIN v$process p
ON p.addr = s.paddr
LEFT JOIN v$transaction t
ON s.taddr = t.addr
  --where s.program not like 'oracle%' -- Ignore background tasks
ORDER BY
  CASE p.background
    WHEN '1'
    THEN 'Background'
    ELSE 'Foreground'
  END DESC 
, s.status 
, ses_start_time 
, tran_start_time 
/

CREATE OR REPLACE VIEW trn_2_longops
AS 
--
--
--V$SESSION_LONGOPS displays the status of various operations that run for longer than 6
--seconds (in absolute time). These operations currently include many backup and
--recovery functions, statistics gathering, and query execution, and more operations are
--added for every Oracle release.
--
--	To monitor query execution progress, you must be using the cost-based optimizer and
--	you must:
--		Set the TIMED_STATISTICS or SQL_TRACE parameters to true
--		Gather statistics for your objects with the DBMS_STATS package
--
--NB lots of other things such as sql_hash, sql_plan_hash_value available in v$session_longops if desired		
--
--
SELECT
  s.sid
, s.status
, sl.target
, sl.opname
, to_char(sl.last_update_time,'DY-DD-MON HH24:MI') as update_time
, to_char(sl.start_time,'DY-DD-MON HH24:MI') as oper_start_time
, round((sl.sofar/nvl(sl.totalwork+0.01,0.01)),4)*100 percent_complete
, round((sl.elapsed_seconds/60),1) mins_elapsed
, round((sl.time_remaining/60),1) mins_remaining
, sl.sofar
, sl.totalwork
, sl.units
, sl.message
, s.osuser
, s.schemaname
, sl.username
, sl.sql_id
FROM v$session s 
JOIN v$session_longops sl
ON s.sid = sl.sid
WHERE  s.status <> 'KILLED'
AND sl.start_time > s.logon_time -- eliminates old values
ORDER BY sl.last_update_time DESC
/

