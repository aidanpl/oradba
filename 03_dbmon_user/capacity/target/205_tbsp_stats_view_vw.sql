/*

 Name:          tbsp_stats_views_vw.sql

 Purpose:       tbsp_stats views 

 Usage:         A series for views typically called FROM front end perl/cgi etc. etc.

 Implementation Typically run under 'dbmon' type user. Initially cloned FROM tbsp_stats 
 
                Note tbsp_stats_7_json uses JSON_ARRAY function only available from Oracle 12.2 and later 
				It also uses the utility function date_to_unix_ts - see 03_dbmon_user/utilities/101_cr_utility_functions.sql for further information

 Next Steps:

 Date            Who             Description

 20th Oct 2015   Aidan Lawrence  cloned FROM similar
 26th Jan 2016   Aidan Lawrence  Included dbname in tbsp_stats_2_growth_predict in partition by clause to allow for multiple db repositories 
 28th Jun 2017   Aidan Lawrence  Validated for git 
  5th Jul 2017   Aidan Lawrence  Migrated tbsp over/under to views 
  7th Mar 2018   Aidan Lawrence  Added tbsp_stats_7_json for JSON output 

*/

CREATE OR REPLACE VIEW tbsp_stats_1_overview
--
-- All TBSP Stats  
-- (Note arbitrary limits in WHERE clause)
AS
SELECT 
  dbname
, to_char(generated_date,'DD-MON-YYYY') as generated_date
, tablespace_name
, mbytes_used
, mbytes_free_no_extend
, mbytes_max_no_extend
, pct_free_no_extend
, mbytes_free_with_extend
, mbytes_max_with_extend
, pct_free_with_extend
 FROM 
(
SELECT 
  tbsp.dbname
, tbsp.generated_date
, tbsp.tablespace_name
, ROUND((tbsp.bytes_used/1048976),0) as mbytes_used
, ROUND((tbsp.bytes_free_no_extend/1048976),0) as mbytes_free_no_extend
, pct_free_no_extend
, ROUND((tbsp.bytes_max_no_extend/1048976),0) as mbytes_max_no_extend
, ROUND((tbsp.bytes_free/1048976),0) as mbytes_free_with_extend
, ROUND((tbsp.bytes_max/1048976),0) as mbytes_max_with_extend
, pct_free_with_extend
, max(tbsp.generated_date) OVER(partition by tbsp.dbname, tbsp.tablespace_name) as max_generated_date 
FROM
tbsp_stats tbsp
WHERE bytes_max_no_extend <> 0 -- elimates any non-standard TEMP tablespaces coming over
) a
WHERE a.generated_date = a.max_generated_date
AND a.generated_date > sysdate - 31
--AND pct_free_no_extend > 20       -- Determine pct free threshold to report on  
--AND mbytes_free_no_extend >  1000 -- Determine Mbytes free threshold to report on  
AND tablespace_name not like 'UNDO%'
ORDER BY dbname, tablespace_name  
/

CREATE OR REPLACE VIEW tbsp_stats_2_growth_predict
--
-- TBSP Daily Growth 
-- 
-- Pick arbitrary high value when estimate days is negative or zero to have them appear at the end of the report 
AS
SELECT 
  dbname
, to_char(generated_date,'DD-MON-YYYY') as generated_date
, tablespace_name
, CASE 
    WHEN growth/growth_period <= 0 THEN 999999 
    ELSE ROUND(bytes_free_no_extend/(growth/growth_period),1)
  END  as estimate_days_free_no_extend  
, CASE 
    WHEN growth/growth_period <= 0 THEN 999999
    ELSE ROUND(bytes_free/(growth/growth_period),1)
  END  as estimate_days_free_with_extend     
--, ROUND(bytes_used/1048976,1) as Mbytes_used
--, ROUND(bytes_free_no_extend/1048976,1) as Mbytes_free_no_extend
--, ROUND(bytes_free/1048976,1) as Mbytes_free_with_extend
, ROUND(((growth/growth_period)/1048976),1) as daily_mb_growth
, growth_period  
FROM (
SELECT 
  dbname
, tablespace_name
, generated_date
, bytes_used
, bytes_free 
, bytes_free_no_extend  
, (bytes_used - prev_bytes_used) as growth
, prev_generated_date
, (generated_date - prev_generated_date ) as growth_period
, max_generated_date
FROM (
SELECT dbname
, tablespace_name
, generated_date
, bytes_used
, bytes_free
, bytes_free_no_extend  
, lag(bytes_used,1,0) OVER (PARTITION BY dbname, tablespace_name ORDER BY generated_date asc) as prev_bytes_used
, lag(generated_date,1) OVER (PARTITION BY dbname, tablespace_name ORDER BY generated_date asc) as prev_generated_date
, max(generated_date) OVER (PARTITION BY dbname, tablespace_name) as max_generated_date
FROM tbsp_stats
WHERE tablespace_name <> 'UNDO1'
)
WHERE prev_generated_date is not null
AND generated_date = max_generated_date
AND generated_date > sysdate - 30
)
ORDER BY estimate_days_free_no_extend asc 
, tablespace_name asc 
/


CREATE OR REPLACE VIEW tbsp_stats_3_hwm_summary
--
-- Based on datafile High Watermark 
-- 
AS
SELECT
  dbname
  , to_char(generated_date,'DD-MON-YYYY') as generated_date
  , CASE TO_CHAR(GROUPING_ID(tablespace_name))
  WHEN '0' THEN tablespace_name
  ELSE 'total'
  END AS tablespace_name
, SUM(mbytes_highwatermark) AS mbytes_highwatermark
, SUM(mbytes_current)       AS mbytes_current
, SUM(mbytes_current - mbytes_highwatermark) AS mbytes_reclaimabile
, CASE recyclebin_count 
  WHEN 0 THEN 'Absent'
  ELSE 'Present'
  END as recyclebin_objects
FROM (
SELECT
  dh.dbname
, dh.tablespace_name
, dh.generated_date
, MAX(dh.generated_date) OVER(PARTITION BY file_name) AS max_generated_date
, ROUND(dh.bytes_highwatermark/1048976,1) AS mbytes_highwatermark
, ROUND(dh.bytes_current/1048976,1) AS mbytes_current
, (SELECT count(*) as recyclebin_count
   FROM dba_recyclebin r 
   WHERE dh.tablespace_name = r.ts_name) as recyclebin_count
FROM Datafile_highwatermark dh
)
WHERE generated_date = max_generated_date
GROUP BY dbname
, to_char(generated_date,'DD-MON-YYYY')
, rollup(tablespace_name)
, CASE recyclebin_count 
  WHEN 0 THEN 'Absent'
  ELSE 'Present'
  END 
ORDER BY
--  GROUPING_ID(tablespace_name)
tablespace_name
/

CREATE OR REPLACE VIEW tbsp_stats_4_hwm_by_file
--
-- Based on datafile High Watermark 
-- 
AS
SELECT 
  dbname
, to_char(generated_date,'DD-MON-YYYY') as generated_date
, file_name
, mbytes_highwatermark
, mbytes_current
, mbytes_reclaimabile 
, mbytes_max_with_extend
, CASE recyclebin_count 
  WHEN 0 THEN 'Absent'
  ELSE 'Present'
  END as recyclebin_objects
FROM (
SELECT 
  dh.dbname
, dh.file_name
, dh.generated_date
, max(dh.generated_date) OVER(PARTITION BY dh.file_name) AS max_generated_date
, ROUND(dh.bytes_highwatermark/1048976,1) AS mbytes_highwatermark
, ROUND(dh.bytes_current/1048976,1) AS mbytes_current
, ROUND(ddf.maxbytes/1048976,1) AS mbytes_max_with_extend
, dh.mbytes_reclaimabile -- NB See virtual column as need be 
, (SELECT count(*) as recyclebin_count
   FROM dba_recyclebin r 
   WHERE dh.tablespace_name = r.ts_name) as recyclebin_count
FROM Datafile_highwatermark dh
join dba_data_files ddf 
on dh.file_name = ddf.file_name
)
WHERE generated_date = max_generated_date
ORDER BY mbytes_reclaimabile desc
/

CREATE OR REPLACE VIEW tbsp_stats_5_over_size 
--
-- Tablespaces with capacity for size reduction 
-- 
AS
SELECT 
  dbname
, generated_date
, tablespace_name
, mbytes_used
, mbytes_free_no_extend
, mbytes_max_no_extend
, pct_free_no_extend
, mbytes_free_with_extend
, mbytes_max_with_extend
, pct_free_with_extend
 FROM
(
SELECT 
tbsp.dbname
, tbsp.generated_date
, tbsp.tablespace_name
, ROUND((tbsp.bytes_used/1048976),0) as mbytes_used
, ROUND((tbsp.bytes_free_no_extend/1048976),0) as mbytes_free_no_extend
, ROUND(100*(1-((bytes_max_no_extend - bytes_free_no_extend)/bytes_max_no_extend)),2) pct_free_no_extend
, ROUND((tbsp.bytes_max_no_extend/1048976),0) as mbytes_max_no_extend
, ROUND((tbsp.bytes_free/1048976),0) as mbytes_free_with_extend
, ROUND((tbsp.bytes_max/1048976),0) as mbytes_max_with_extend
, ROUND(100*(1-((bytes_max - bytes_free)/bytes_max)),2) pct_free_with_extend
, max(tbsp.generated_date) OVER(partition by tbsp.dbname, tbsp.tablespace_name) as max_generated_date
FROM
tbsp_stats tbsp
WHERE bytes_max_no_extend <> 0 -- elimates any non-standard TEMP tablespaces coming over
) a
WHERE a.generated_date = a.max_generated_date
AND pct_free_no_extend > (SELECT param_value 
                         FROM  dbarep_parameters
                         WHERE param_name = 'TBSP_OVER_REPORT_PCT_FREE_THRESHOLD'
                         AND valid = 'Y')
AND mbytes_free_no_extend > (SELECT param_value 
                         FROM  dbarep_parameters
                         WHERE param_name = 'TBSP_OVER_REPORT_MBYTES_FREE_THRESHOLD'
                         AND valid = 'Y') 
AND tablespace_name not like 'UNDO%'
ORDER BY dbname, tablespace_name
;

CREATE OR REPLACE VIEW tbsp_stats_6_under_size 
--
-- Tablespaces plausibly undersized 
-- 
AS
SELECT 
  r.priority
, a.dbname
, a.generated_date
, a.tablespace_name
, a.mbytes_used
, a.mbytes_free_with_extend
, a.mbytes_max_with_extend
, a.pct_free_with_extend
 FROM
(
SELECT 
tbsp.dbname
, tbsp.generated_date
, tbsp.tablespace_name
, ROUND((tbsp.bytes_used/1048976),0) as mbytes_used
, ROUND((tbsp.bytes_free/1048976),0) as mbytes_free_with_extend
, ROUND((tbsp.bytes_max/1048976),0)  as mbytes_max_with_extend
, ROUND(100*(1-((bytes_max - bytes_free)/bytes_max)),2) pct_free_with_extend
, max(tbsp.generated_date) OVER(partition by tbsp.dbname, tbsp.tablespace_name) as max_generated_date
FROM
tbsp_stats tbsp
WHERE bytes_max_no_extend <> 0 -- elimates any non-standard TEMP tablespaces coming over
) a
join dbarep_roadmap r
on a.dbname = r.db_name
WHERE a.generated_date = a.max_generated_date
AND pct_free_with_extend < (SELECT param_value 
                         FROM  dbarep_parameters
                         WHERE param_name = 'TBSP_UNDER_REPORT_PCT_FREE_THRESHOLD'
                         AND valid = 'Y')
AND tablespace_name not like 'UNDO%'
;

CREATE OR REPLACE VIEW tbsp_stats_7_json
--
-- Common TBSP Stats in both JSON_ARRAY and JSON_OBJECT format
-- generated_date is provided as a unix_timestamp * 1000 as a common format for flot charsts
-- dbname, tablespace_name and generated_date are provided as individual columns to allow flexibilty when querying the view
AS
SELECT 
  tbsp.dbname
, tbsp.tablespace_name
, tbsp.generated_date
, JSON_ARRAY(
  tbsp.dbname
, tbsp.tablespace_name
, date_to_unix_ts(tbsp.generated_date) * 1000
, ROUND((tbsp.bytes_used/1048976),0) 
, ROUND((tbsp.bytes_max_no_extend/1048976),0) 
) AS tbsp_stats_json_array
, JSON_OBJECT(
  'Dbname' VALUE tbsp.dbname
, 'Tablespace' VALUE tbsp.tablespace_name
, 'GeneratedDateTS' VALUE date_to_unix_ts(tbsp.generated_date) * 1000
, 'MbytesUsed' VALUE ROUND((tbsp.bytes_used/1048976),0) 
, 'MbytesMaxNoExtend' VALUE ROUND((tbsp.bytes_max_no_extend/1048976),0) 
FORMAT JSON
) AS tbsp_stats_json_object
FROM
tbsp_stats tbsp
WHERE tablespace_name not like 'UNDO%'
ORDER BY dbname, tablespace_name , generated_date 
/
