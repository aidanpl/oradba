/*

 Name:          obj_view_vw.sql

 Purpose:       Object level views for general activity. 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 Required direct Grants for view creations
 
GRANT SELECT ON dba_objects to DBMON;
GRANT SELECT ON dba_tables to DBMON;
GRANT SELECT ON dba_views to DBMON;
GRANT SELECT ON dba_sequences to DBMON;
GRANT SELECT ON dba_dependencies to DBMON;

 
Implemented to date 
 01 Tables
 02 Views
 03 Sequences
 
 31 Object creation  
 32 Object changes 
 33 Partition/Sub partition counts by table/index 
 34 Recent Job Runs 
 35 Recent Partition Changes 
 
  Plausible additions 
 
 04 Indexes
 05 Package, procedure, function 
 06 Triggers
 07 Jobs (old and new)
 08 Directories 
 09 Mviews
 10 Mview logs
 11 Synoymns
 12 Public Synoynms
 13 Database links 
 14 Public Database Links 
 15 Types
 
 Next Steps:

 Date            Who             Description

 18th Apr 2017   Aidan Lawrence  Cloned from similar
 27th Jun 2017   Aidan Lawrence  Validated pre git publication     
 
*/

CREATE OR REPLACE VIEW obj_01_tables
--
-- Trivial table lists 
-- 
AS SELECT
  tab.owner
, tab.table_name 
, CASE 
  WHEN tab.num_rows IS NULL THEN 'not/aval'
  ELSE TO_CHAR(tab.num_rows)
  END as num_rows 
, CASE 
  WHEN tab.blocks IS NULL THEN 'not/aval'
  ELSE TO_CHAR(tab.blocks)
  END as blocks   
, CASE 
  WHEN tab.last_analyzed  IS NULL THEN 'not/aval'
  ELSE to_char(last_analyzed,'DD-MON-YYYY HH24:MI')
  END as last_analyzed   
FROM dba_tables tab
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),tab.owner) 
ORDER BY owner
, table_name
/

CREATE OR REPLACE VIEW obj_02_views
--
-- Views with dependencies
-- 
AS
SELECT 
  v.owner
, v.view_name
, d.referenced_type
, d.referenced_name
, d.referenced_owner
FROM dba_views v
LEFT JOIN dba_dependencies d 
ON 
(v.owner = d.owner
AND v.view_name = d.name)
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),v.owner) 
ORDER BY v.owner
, v.view_name
, d.referenced_type
, d.referenced_name
/

CREATE OR REPLACE VIEW obj_03_sequences
--
-- Sequences
-- 
AS
SELECT 
  s.sequence_owner
, s.sequence_name
, s.last_number
, s.increment_by
FROM dba_sequences s
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),s.sequence_owner) 
ORDER BY s.sequence_owner
, s.sequence_name
/


CREATE OR REPLACE VIEW obj_31_created_recent
--
-- Recent object creation (Excluding partitions)
-- 
AS
SELECT 
  TO_CHAR(created,'DY DD-MON HH24:MI') AS creation_time
, owner
, object_name
, object_type
FROM dba_objects
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner)
AND object_type NOT LIKE '%PARTITION%'
AND created > sysdate - 7
ORDER BY 
owner
, created DESC
, object_type
, object_name 
/

CREATE OR REPLACE VIEW obj_32_changed_recent
--
-- Recent object changes (Excluding partitions but will flag object with partition changes AS changed 
-- 
AS
SELECT 
  TO_CHAR(last_ddl_time,'DY DD-MON HH24:MI') AS ddl_time
, owner
, object_name
, object_type
FROM dba_objects
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner)
AND object_type NOT LIKE '%PARTITION%'
AND object_type NOT LIKE 'MATERIALIZED VIEW'
AND object_type NOT LIKE 'JOB'
AND last_ddl_time <> created
AND last_ddl_time > sysdate - 7
ORDER BY 
  owner
, last_ddl_time DESC
, object_type
, object_name 
/

CREATE OR REPLACE VIEW obj_33_mview_refreshes
--
-- Recent mview refreshes - flagged via object changes 
-- 
AS
SELECT 
  TO_CHAR(last_ddl_time,'DY DD-MON HH24:MI') AS ddl_time
, owner
, object_name
, object_type
FROM dba_objects
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner)
AND object_type LIKE 'MATERIALIZED VIEW'
AND last_ddl_time <> created
AND last_ddl_time > sysdate - 7
ORDER BY 
owner
, last_ddl_time DESC
, object_type
, object_name 
/

CREATE OR REPLACE VIEW obj_34_job_runs
--
-- Recent job runs - flagged via object changes 
-- 
AS
SELECT 
  TO_CHAR(last_ddl_time,'DY DD-MON HH24:MI') AS ddl_time
, owner
, object_name
, object_type
FROM dba_objects
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner)
AND object_type LIKE 'JOB'
AND last_ddl_time <> created
AND last_ddl_time > sysdate - 7
ORDER BY 
  owner
, last_ddl_time DESC
, object_type
, object_name 
/

CREATE OR REPLACE VIEW obj_35_partition_changes
--
-- Recent partition creation - flagged via object changes 
-- 
AS 
SELECT 
  owner
, object_name
, object_type
, count(*) AS partition_count 
, TO_CHAR(created,'DD-MON-YYYY') AS creation_time
FROM dba_objects
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner)
AND object_type LIKE '%PARTITION%'
AND created > sysdate - 7
GROUP BY 
  owner
, object_name
, object_type
, TO_CHAR(created,'DD-MON-YYYY')
ORDER BY 
  owner
, object_name
, object_type
, TO_CHAR(created,'DD-MON-YYYY') DESC 
/
