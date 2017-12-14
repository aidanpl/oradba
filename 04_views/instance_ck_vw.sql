/*

 Name:          instance_ck_vw.sql

 Purpose:       Instance report as views

 Usage:         A series for views typically called from front end perl/cgi etc. etc.

--
--  Required direct Grants for view creations

GRANT SELECT ON v_$instance     TO dbmon;
GRANT SELECT ON v_$database     TO dbmon;
GRANT SELECT ON v_$license      TO dbmon;
GRANT SELECT ON v_$rowcache     TO dbmon;
GRANT SELECT ON v_$latch        TO dbmon;
GRANT SELECT ON v_$librarycache TO dbmon;
GRANT SELECT ON v_$session      TO dbmon;
GRANT SELECT ON v_$sysstat      TO dbmon;
GRANT SELECT ON v_$sesstat      TO dbmon;
GRANT SELECT ON v_$statname     TO dbmon;
GRANT SELECT ON v_$sort_segment TO dbmon;
GRANT SELECT ON dba_tablespaces TO dbmon;

 Next Steps:

 Date            Who             Description

 11th Apr 2017   Aidan Lawrence  Consolidated from various sources 
  8th Jun 2017   Aidan Lawrence  Validated pre git publication   
*/


CREATE OR REPLACE VIEW inst_1_instance
--
-- General instance info
-- 
AS
SELECT
  instance_name
, host_name
, version
, TO_CHAR(startup_time,'DY DD-MON-YY HH24:MI') last_start
, instance_role 
, status 
FROM v$instance;

-- SELECT * FROM inst_1_instance;

CREATE OR REPLACE VIEW inst_2_license
--
-- General license info
-- 
AS
SELECT
sessions_current
, sessions_highwater
, CASE TO_CHAR(sessions_max)
    WHEN '0' THEN 'Unlimited'
    ELSE TO_CHAR(sessions_max)
  END AS sessions_max 
, cpu_count_highwater
FROM v$license;

-- SELECT * FROM inst_2_license;

CREATE OR REPLACE VIEW inst_3_param_nondefault
--
-- Non default parameters 
-- 
AS
SELECT
  name           as parameter_name
, display_value  as parameter_display_value
, description    as parameter_description  
, ismodified     as parameter_modified
, issys_modifiable as parameter_modifiable 
FROM v$parameter
WHERE isdefault = 'FALSE'
ORDER BY 
type
, name
/

CREATE OR REPLACE VIEW inst_4_core_parameters
--
-- Core tuning parameters - tweak based on your specific version 
-- 
AS
SELECT
  name           as parameter_name
, display_value  as parameter_display_value
, description    as parameter_description  
, ismodified     as parameter_modified
, issys_modifiable as parameter_modifiable 
FROM v$parameter
WHERE name IN 
( 
'shared_pool_size'
, 'db_block_size'
, 'db_cache_size'
, 'cursor_sharing'
, 'db_file_multiblock_read_count'
, 'hash_area_size'
, 'hash_join_enabled'
, 'optimizer_features_enable'
, 'optimizer_mode'
, 'optimizer_index_caching'
, 'optimizer_index_cost_adj'
, 'pga_aggregate_target'
, 'query_rewrite_enabled'
, 'sort_area_size'
, 'sga_max_size'
, 'star_transformation_enabled'
, 'timed_statistics'
, 'workarea_size_policy'
)
ORDER BY name
/

CREATE OR REPLACE VIEW inst_5_db_buf_cache_ratio
--
-- Buffer cache hit ratio
-- Essentially (1 - reads/(block gets + consistent gets)
-- 
AS
SELECT
    ROUND(
    ( 1 - ( SUM(CASE  name  WHEN 'physical reads'  THEN value ELSE 0  END ) )
        / ( SUM(CASE  name  WHEN 'db block gets'   THEN value ELSE 0  END )
        +   SUM(CASE  name  WHEN 'consistent gets' THEN value ELSE 0  END )
          )
    ) * 100
    , 2 ) AS buffer_cache_hit_ratio
FROM
v$sysstat 
/

CREATE OR REPLACE VIEW inst_6_dict_cache_ratio
--
-- Data Dictionary cache miss ratio
-- 
AS
SELECT sum(getmisses)/sum(gets) * 100 AS dd_cache_miss_ratio
FROM v$rowcache
/

CREATE OR REPLACE VIEW inst_7_lib_cache_ratio
--
-- Library cache miss ratio
-- 
AS
SELECT sum(reloads)/sum(pins) *100 AS lib_cache_miss_ratio
FROM v$librarycache;
/

CREATE OR REPLACE VIEW inst_8_redo_log_latches
--
-- Redo Log Latches
-- 
AS
SELECT 
  name                  AS latch_name
, sum(gets)             AS redo_gets
, sum(misses) 		    AS redo_misses
, sum(immediate_gets)   AS redo_im_gets
, sum(immediate_misses) AS redo_im_misses
FROM v$latch
WHERE name like '%redo%'
GROUP BY name
ORDER BY redo_misses desc
/

CREATE OR REPLACE VIEW inst_9_redo_space_req
--
-- Redo Space Requests
-- 
AS
SELECT 
  name  AS stat_name
, value AS stat_value
FROM v$sysstat
WHERE name='redo log space requests'
/

CREATE OR REPLACE VIEW inst_10_sort_mem_contention
--
-- Sort Memory Contention
-- 
AS
SELECT 
  name  AS stat_name
, value AS stat_value
FROM v$sysstat
WHERE name in ('sorts (memory)','sorts (disk)', 'sorts (rows)')
/

CREATE OR REPLACE VIEW inst_11_sort_segs
--
-- Sort Segments
-- 
AS
SELECT 
  s.tablespace_name
, round(total_blocks*(t.block_size/1048976),0) AS sort_total_mb 
, round(used_blocks*(t.block_size/1048976),0)  AS sort_used_mb
, round(free_blocks*(t.block_size/1048976),0)  AS sort_free_mb
FROM v$sort_segment s
JOIN dba_tablespaces t
ON s.tablespace_name = t.tablespace_name
/

CREATE OR REPLACE VIEW inst_12_sort_sessions
--
-- Sort Sessions
-- 
AS
SELECT
  vs.username as schemaname
, vs.osuser
, vs.sid
, vsn.name    AS stat_name
, vss.value   AS stat_value 
FROM
v$session vs
JOIN v$sesstat vss
ON (vs.sid = vss.sid)
JOIN v$statname vsn
ON (vss.statistic#=vsn.statistic#)
WHERE vsn.name LIKE '%sort%'
AND vs.username is not null
ORDER BY sid
;
