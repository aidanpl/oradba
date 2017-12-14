/*

 Name:          0_switch_db.sql

 Purpose:       Update current reporting db 

 Date            Who             Description

 31st Dec 2015   Aidan Lawrence  Cleaned up version of 'switchdb' from OraSASH scripts 
 9th Mar 2016    Aidan Lawrence  Customised by adding synonym to v$session on database link 

*/

--
-- Easiest is for one off hardcoding for databases in use 
--
/*

requires GRANT CREATE SYNONYM to SASH; --on repository database and
requires GRANT SELECT ON V_$SESSION TO SASH; --on each target 

CREATE SYNONYM v$session_target_apl01 FOR v$session@APL01;
CREATE SYNONYM v$session_target_apl21 FOR v$session@APL21;
CREATE SYNONYM v$session_target_apl22 FOR v$session@APL22;


*/

--
-- Get list of current databases

SELECT s.dbname, s.dbid, s.host, s.inst_num
,  CASE
   WHEN t.dbid IS NULL THEN ' ' ELSE '*'  END as current_db
FROM sash_targets s
LEFT JOIN sash_target t
ON (s.dbid   = t.dbid 
AND s.inst_num = t.inst_num
)
ORDER BY dbid,
  inst_num;
  
prompt 
accept DBID prompt "Switch to database with DBID "

prompt 
accept INST_NUM prompt "Switch to instance with INST_NUM "  
  
var output varchar2(2000)

begin
  :output:='';
end;
/  
  
DECLARE
  i NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO i
  FROM sash_targets
  WHERE dbid   = &DBID
  AND inst_num = &INST_NUM ;
  IF (i > 0) THEN
    UPDATE sash_target_static SET dbid = '&DBID', inst_num = &INST_NUM;
    :output := 'Database switched.';
    COMMIT;
  ELSE
    :output := 'Database DBID ' || '&DBID' || ' and instance nuber ' || &INST_NUM || ' not found as a target';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20001,'Something went wrong. Target database didn''t change. Error - ' || SQLERRM);
END;
/

set head off
select :output as result from dual;
set head on  

SELECT s.dbname, s.dbid, s.host, s.inst_num
,  CASE
    WHEN t.dbid IS NULL THEN ' ' ELSE '*'  END as current_db
FROM sash_targets s
LEFT JOIN sash_target t
ON (s.dbid   = t.dbid 
AND s.inst_num = t.inst_num
)
ORDER BY dbid,
  inst_num;

--
-- Sanity check 
--
select instance_name
, host_name
from v$instance;

--
-- Repoint the v$session_target synonym to the switched db 

column switch_target new_value targetdb 
select 'v$session_target_' || instance_name as switch_target 
from v$instance;

DROP SYNONYM v$session_target;
CREATE SYNONYM v$session_target FOR &targetdb;

select * from v$session_target
where rownum < 5;
