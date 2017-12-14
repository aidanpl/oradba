/*

 Name:          undo_ck_vw.sql

 Purpose:       Undo Tuning report as views

 Usage:         A series for views typically called from front end perl/cgi etc. etc.

 --
 --  Required direct Grants for view creations

 
 GRANT SELECT ON v_$parameter TO dbmon;
 GRANT SELECT ON v_$undostat TO dbmon;
 GRANT SELECT ON v_$rollstat TO dbmon;
 GRANT SELECT ON v_$waitstat TO dbmon;
 GRANT SELECT ON dba_undo_extents TO dbmon;
 GRANT SELECT ON dba_tablespaces TO dbmon;
 GRANT SELECT ON dba_data_files TO dbmon;
 
  

 Next Steps:

 Date            Who             Description

 5th Dec 2014    Aidan Lawrence  Recoded from undo_ck.sql
 24th Feb 2017   Aidan Lawrence  Tweak to grant notes during Ora12 sanity checks 
 15th Jun 2017   Aidan Lawrence  Validated pre git publication   

*/

CREATE OR REPLACE VIEW undo_1_parameters
--
-- Undo Parameters including converting retention to minutes 
-- Note arbitrary limits in WHERE clause
AS
SELECT
  name
  -- Essentially bring value back except specific processing for undo_retention
, CASE name
  WHEN 'undo_retention' THEN to_char(value/60) || ' minutes'
  ELSE value
  END as value
FROM v$parameter
WHERE name like 'undo%'
/

CREATE OR REPLACE VIEW undo_2_recent_volumes
--
-- Undo Parameters including converting retention to minutes 
-- Note arbitrary limits in WHERE clause
AS
SELECT
TO_CHAR(begin_time,'DD-MON-YYYY HH24:MI') as start_time
, ROUND(undoblks*(8192/1048976),0) undo_mb
FROM v$undostat
WHERE begin_time > sysdate - 7
ORDER by begin_time DESC
/

CREATE OR REPLACE VIEW undo_3_extent_sizes
AS
SELECT
  CASE grouping_id(status)
  WHEN 1 Then 'Total'
  ELSE status
  END as status
, tablespace_name
, round(sum(bytes/1048976),0) as size_Mbytes
from dba_undo_extents
group by rollup(status)
, tablespace_name
/

CREATE OR REPLACE VIEW undo_4_undo_storage
AS
SELECT f.tablespace_name
, round(sum(f.bytes/1048976),0) as size_Mbytes
from dba_data_files f
JOIN dba_tablespaces t
ON t.tablespace_name = f.tablespace_name
WHERE t.contents = 'UNDO'
GROUP BY f.tablespace_name
/

CREATE OR REPLACE VIEW undo_5_undo_extension
AS
SELECT 
  s.usn as undo_segment_id
, s.status as status 
, to_char(s.aveactive,'9,999,999,999') as avg_active_size 
, to_char(s.hwmsize,'9,999,999,999')   as high_watermark
, to_char(s.writes,'999,999,999,999')  as no_writes
, s.shrinks as no_shrinks
, s.wraps as no_wraps
, s.extends as no_extends
, to_char(s.aveshrink,'9,999,999,999') as avg_shrink_size 
FROM  v$rollstat s
ORDER BY s.hwmsize desc
/

CREATE OR REPLACE VIEW undo_6_undo_waits
AS
SELECT 
  class
, count
, time
FROM v$waitstat
WHERE class IN
( 'free list'
, 'system undo header'
, 'system undo block'
, 'undo header'
, 'undo block'
)
ORDER BY class
;

CREATE OR REPLACE VIEW undo_7_undo_hit_ratio
AS
SELECT 
  usn as undo_segment_id
, waits
, gets
, ROUND(100 -(waits/gets),8) AS hit_ratio -- high number of decimal places as this is usually > 99.999 .....
FROM v$rollstat a
ORDER BY hit_ratio DESC
/


