/*

 Name:          invalid_views_vw.sql

 Purpose:       Invalid, generally broken level views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

--
--  Required direct Grants for view creations

GRANT SELECT ON dba_objects    TO dbmon;
GRANT SELECT ON dba_data_files TO dbmon;
GRANT SELECT ON v_$datafile TO dbmon;
GRANT SELECT ON v_$logfile TO dbmon;
 
 Next Steps:

 Date            Who             Description

  4th Apr 2017   Aidan Lawrence  Ongoing tidyup
 27th Jun 2017   Aidan Lawrence  Validated pre git publication     

*/

CREATE OR REPLACE VIEW inv_1_invalid_objects
--
-- Invalid Objects 
-- 
AS SELECT
-- 
-- Show objects NOT including the ignore schemas 
--
    '1' as view_order  
  , owner
  , object_type
  , object_name
  , status 
FROM dba_objects
WHERE status != 'VALID'
AND object_type NOT IN ('MATERIALIZED VIEW') -- exclude as often show as invalid when not relevant 
AND object_type NOT IN ('SYNONYM')  -- common invalid in test - show separately 
AND NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) -- NOT including ignored schemas 
UNION ALL 
SELECT 
-- 
-- Show objects belonging to ignore schemas 
--
    '2' as view_order  
  , owner
  , object_type
  , object_name
  , status 
FROM dba_objects
WHERE status != 'VALID'
AND object_type NOT IN ('MATERIALIZED VIEW') -- exclude as often show as invalid when not relevant 
AND object_type NOT IN ('SYNONYM')  -- common invalid in test - show separately 
AND REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner)  -- including ignored schemas
ORDER BY 
  view_order
, owner
, object_type
, object_name
, status 
/

CREATE OR REPLACE VIEW inv_2_invalid_synonyms
--
-- Invalid Synonyms - just focus on non-ignored schemas  
-- 
AS SELECT
-- 
-- Show objects NOT including the ignore schemas 
--
    owner
  , object_type
  , object_name
  , status 
FROM dba_objects
WHERE status != 'VALID'
AND object_type = 'SYNONYM'  
AND NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) -- NOT including ignored schemas 
/

CREATE OR REPLACE VIEW inv_3_invalid_mviews
--
-- Invalid Mviews - just focus on non-ignored schemas  
-- Don't give any detail on mview such as refresh times - keep it simple for this base invalid views 
-- 
AS SELECT
-- 
-- Show objects NOT including the ignore schemas 
--
    owner
  , object_type
  , object_name
  , status 
FROM dba_objects
WHERE status != 'VALID'
AND object_type IN ('MATERIALIZED VIEW') -- exclude as often show as invalid when not relevant 
AND NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) -- NOT including ignored schemas 
/

CREATE OR REPLACE VIEW inv_4_datafile_problems
--
-- Offline datafiles 
-- 
AS SELECT
-- substr(dba.file_name,1,72) as file_name
 file_name
, vdf.status 
FROM dba_data_files dba
JOIN v$datafile vdf
ON vdf.file# = dba.file_id
WHERE vdf.status NOT IN ('SYSTEM','ONLINE')
ORDER BY file_name;


CREATE OR REPLACE VIEW inv_5_redolog_problems
--
-- Problem redologs 
-- 
AS SELECT
  member 
, status 
FROM v$logfile
WHERE status not in (' ', 'STALE')
ORDER BY member;
