/*

 Name:          redo_ck_vw.sql

 Purpose:       Redo report as views

 Usage:         A series for views typically called from front end perl/cgi etc. etc.

 Implementation may requires GRANT SELECT ON V_xxx TO <schema> if not running from general DBA standards
 
 GRANT SELECT ON v_$log TO dbmon;
 GRANT SELECT ON v_$log_history TO dbmon;
 GRANT SELECT ON v_$archive_dest TO dbmon;
 GRANT SELECT ON v_$archived_log TO dbmon;
 GRANT SELECT ON v_$recovery_area_usage TO dbmon;

 Next Steps:

 Date            Who             Description

 4th Feb 2016    Aidan Lawrence  Consolidated from various sources 
 27th Jun 2017   Aidan Lawrence  Validated pre git publication      

*/

CREATE OR REPLACE VIEW redo_1_online_logs 
--
-- State of online redo logs 
-- 
AS
  select 
  group# as redo_group
, sequence#   as redo_sequence
, status      as status 
, archived    as Archived
, round(bytes/1048976,0) as log_mbytes
, to_char(first_time,'DD-MON-YY HH24:MI:SS') as log_time
from v$log
order by first_time desc
/

--SELECT * FROM redo_1_online_logs;

CREATE OR REPLACE VIEW redo_2_destinations 
--
-- Redo destinations Undo Parameters including converting retention to minutes 
-- Note arbitrary limits in WHERE clause
AS
SELECT 
  a.dest_name
, CASE a.destination
  WHEN 'USE_DB_RECOVERY_FILE_DEST' 
  THEN (SELECT value FROM v$parameter
	    WHERE name = 'db_recovery_file_dest')
  ELSE a.destination
  END as destination 
, a.status as status 
, nvl(a.error,'Null') as Error
, a.target
, a.valid_type
, a.valid_role 
, a.log_sequence  
, a.fail_sequence
FROM
  v$archive_dest a
WHERE
  a.destination is not null
ORDER BY dest_name
;

--SELECT * FROM redo_2_destinations;

CREATE OR REPLACE VIEW redo_3_recovery_area_usage
AS
SELECT 
file_type 
, percent_space_used
, percent_space_reclaimable
, percent_space_used-percent_space_reclaimable AS percent_space_not_reclaimable
, number_of_files
FROM v$recovery_area_usage
WHERE percent_space_used > 0
ORDER BY percent_space_used desc 
, file_type
;

--SELECT * FROM redo_3_recovery_area_usage;


CREATE OR REPLACE VIEW redo_4_log_switches_per_hour
AS 
  select to_char(trunc(first_time,'HH24'),'DD : HH24') as Hour
, count(*) as switches
from v$log_history
where first_time >= sysdate-1
group by trunc(first_time,'HH24')
order by Hour desc;

--SELECT * FROM redo_4_log_switches_per_hour;

CREATE OR REPLACE VIEW redo_5_log_switch_frequency
AS 
SELECT 
  TO_CHAR(first_time,'YYYY-MM-DD') as log_date
, TO_CHAR(first_time, 'Dy') as day
, COUNT(1) as total,
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'00',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'00',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'00',1,0)) ||'</font>' as "00",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'01',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'01',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'01',1,0)) ||'</font>' as "01",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'02',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'02',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'02',1,0)) ||'</font>' as "02",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'03',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'03',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'03',1,0)) ||'</font>' as "03",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'04',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'04',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'04',1,0)) ||'</font>' as "04",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'05',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'05',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'05',1,0)) ||'</font>' as "05",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'06',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'06',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'06',1,0)) ||'</font>' as "06",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'07',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'07',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'07',1,0)) ||'</font>' as "07",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'08',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'08',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'08',1,0)) ||'</font>' as "08",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'09',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'09',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'09',1,0)) ||'</font>' as "09",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'10',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'10',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'10',1,0)) ||'</font>' as "10",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'11',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'11',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'11',1,0)) ||'</font>' as "11",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'12',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'12',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'12',1,0)) ||'</font>' as "12",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'13',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'13',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'13',1,0)) ||'</font>' as "13",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'14',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'14',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'14',1,0)) ||'</font>' as "14",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'15',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'15',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'15',1,0)) ||'</font>' as "15",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'16',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'16',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'16',1,0)) ||'</font>' as "16",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'17',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'17',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'17',1,0)) ||'</font>' as "17",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'18',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'18',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'18',1,0)) ||'</font>' as "18",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'19',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'19',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'19',1,0)) ||'</font>' as "19",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'20',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'20',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'20',1,0)) ||'</font>' as "20",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'21',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'21',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'21',1,0)) ||'</font>' as "21",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'22',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'22',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'22',1,0)) ||'</font>' as "22",
    CASE WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'23',1,0)) > 12 THEN '<font color="red">'
         WHEN SUM(DECODE(TO_CHAR(first_time, 'hh24'),'23',1,0)) > 6 THEN '<font color="orange">'
         ELSE '<font color="black">'
    end || SUM(DECODE(TO_CHAR(first_time, 'hh24'),'23',1,0)) ||'</font>' as "23"
FROM v$log_history
WHERE TRUNC(first_time) > sysdate - 35
GROUP BY TO_CHAR(first_time,'YYYY-MM-DD')
, TO_CHAR(first_time, 'Dy')
ORDER BY log_date desc ;

--SELECT * FROM redo_5_log_switch_frequency;


CREATE OR REPLACE VIEW redo_6_log_history_recent
AS 
SELECT 
  sequence#
, to_char(first_time,'DD-MON-YY HH24:MI:SS') log_time
--, first_change# 
FROM v$log_history
WHERE first_time >= sysdate - 1
ORDER BY first_time desc
/

CREATE OR REPLACE VIEW redo_7_archive_history_recent
AS 
SELECT
  sequence#                                         
, to_char(first_time,'DY DD-MON-YY HH24:MI')      as archive_log_start_time
, to_char(completion_time,'DY DD-MON-YY HH24:MI') as archive_log_end_time
, (blocks * block_size/1024)                      as archive_log_size
FROM v$archived_log
WHERE first_time > (sysdate - 1)
ORDER BY first_time desc
/
