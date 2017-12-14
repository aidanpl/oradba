/*

 Name:          sga_pga_vw.sql

 Purpose:       SGA/PGA level views 

 Usage:         A series for views typically called FROM front end sh,perl/cgi anything you like  etc.

 --
 --  Required direct Grants for view creations
 
GRANT SELECT ON v_$sgainfo		          TO DBMON;
GRANT SELECT ON v_$sga_dynamic_components TO DBMON;
GRANT SELECT ON v_$sga_resize_ops         TO DBMON;  
GRANT SELECT ON v_$sga_target_advice      TO DBMON;  
GRANT SELECT ON v_$pgastat                TO DBMON;
GRANT SELECT ON v_$pga_target_advice      TO DBMON;

 Next Steps:

 Date            Who             Description

 12th Jan 2016   Aidan Lawrence  Cloned FROM similar
 31st Aug 2017   Aidan Lawrence  Validated pre git publication   

*/

CREATE OR REPLACE VIEW sga_1_info
--
-- SGA High level info 
-- 
AS
SELECT 
  name                     AS sga_component_name
, ROUND((bytes/1048976),0) AS component_size_mb
, resizeable      
FROM v$sgainfo
ORDER BY component_size_mb DESC, sga_component_name
/

CREATE OR REPLACE VIEW sga_2_dyn_components
--
-- SGA Dynamic components
-- 
AS
SELECT 
component                         AS sga_component_name
, ROUND((current_size/1048976),0) AS current_size_mb
, ROUND((min_size/1048976),0)     AS min_size_mb
, ROUND((max_size/1048976),0)     AS max_size_mb
, last_oper_type
, TO_CHAR(last_oper_time,'DD-MON-YYYY HH24:MI:SS') AS disp_last_oper_time
FROM v$sga_dynamic_components
WHERE current_size <> 0
ORDER BY sga_component_name asc
/

CREATE OR REPLACE VIEW sga_3_resize
--
-- SGA Dynamic components
-- 
AS
SELECT 
component                         AS sga_component_name
, ROUND((final_size/1048976),0)   AS final_size_mb
, ROUND((target_size/1048976),0)  AS target_size_mb
, ROUND((initial_size/1048976),0) AS initial_size_mb
, oper_type
, TO_CHAR(start_time,'DD-MON-YYYY HH24:MI:SS') AS oper_start_time
FROM v$sga_resize_ops
--WHERE final_size <> 0
WHERE start_time > sysdate - 28
ORDER BY sga_component_name
, start_time DESC
, oper_type
/

CREATE OR REPLACE VIEW sga_4_target_advice
--
-- SGA Target Advice 
-- 
AS
SELECT 
  sga_size
, sga_size_factor
, estd_db_time
, estd_db_time_factor
, estd_physical_reads
FROM v$sga_target_advice
ORDER BY sga_size
/

CREATE OR REPLACE VIEW pga_1_info
--
-- PGA Info 
-- 
AS
SELECT 
  name                     AS pga_component_name
, CASE unit 
  WHEN 'bytes' THEN ROUND((value/1048976),0) || ' Mb'
  ELSE value || ' ' || unit 
  END AS component_size_mb
FROM v$pgastat
ORDER BY unit nulls last, name, value
/

CREATE OR REPLACE VIEW pga_2_target_advice
--
-- PGA Target Advice 
-- 
AS
SELECT 
  pga_target_for_estimate
, pga_target_factor
, estd_time
, estd_pga_cache_hit_percentage
FROM v$pga_target_advice
/


