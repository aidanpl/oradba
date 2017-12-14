/*

 Name:          stats_vw.sql

 Purpose:       Stats level views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 --
 --  Required direct Grants for view creations
 
GRANT SELECT ON dba_tables 			   TO DBMON;
GRANT SELECT ON dba_optstat_operations TO DBMON;
GRANT SELECT ON dba_tab_stats_history  TO DBMON;

 Next Steps:

 Date            Who             Description

 12th Jan 2016   Aidan Lawrence  Cloned from similar
 31st Aug 2017   Aidan Lawrence  Validated pre git publication   

*/

CREATE OR REPLACE VIEW stats_1_tab_last_analyzed
--
-- Table stats by owner and last_analyzed
-- 
AS
SELECT
  tab.last_analyzed
, tab.owner AS table_owner
, tab.table_name
, '(Non-partitioned)' AS partition_name -- required for the UNION below
, tab.num_rows
, tab.blocks
FROM dba_tables tab
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),tab.owner) 
AND tab.partitioned = 'NO'
AND tab.num_rows is not null
--
-- Then UNION to partitioned tables
--
UNION
SELECT
  tab.last_analyzed
, tab.table_owner                                   
, tab.table_name
, tab.partition_name
, tab.num_rows
, tab.blocks
from dba_tab_partitions tab
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),tab.table_owner) 
AND tab.num_rows is not null
ORDER BY
  table_owner   
, last_analyzed desc
, table_name
, partition_name
/


CREATE OR REPLACE VIEW stats_2_ind_last_analyzed
--
-- Index stats by owner and last_analyzed
-- 
AS
SELECT
  ind.last_analyzed 
, ind.table_owner   as index_owner 
, ind.index_name
, '(Non-partitioned)' partition_name -- required for the UNION below
, ind.num_rows
, ind.blevel
, ind.leaf_blocks
FROM dba_indexes ind
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),ind.table_owner) 
AND ind.partitioned = 'NO'
AND ind.num_rows is not null
--
-- Then UNION to partitioned indexes
--
UNION
SELECT
  ind.last_analyzed
, ind.index_owner   
, ind.index_name
, ind.partition_name
, ind.num_rows
, ind.blevel
, ind.leaf_blocks
FROM dba_ind_partitions ind
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),ind.index_owner) 
AND ind.num_rows is not null
ORDER BY
  index_owner   
, last_analyzed desc
, index_name
, partition_name
/

CREATE OR REPLACE VIEW stats_3_auto_gather_times
--
-- Auto Gather times 
-- 
AS
SELECT 
  start_time
, end_time
, (end_time - start_time)  AS elapsed_time
--, TO_CHAR((end_time - start_time),'HH:MI:SS')  AS elapsed_time
FROM dba_optstat_operations
ORDER BY start_time desc
/



CREATE OR REPLACE VIEW stats_4_collected_recent
--
-- Auto Gather times 
-- 
AS
SELECT 
  owner
, table_name
, partition_name
, stats_count
FROM 
(SELECT
  owner
, table_name
, NVL(partition_name,'<non-partitioned>') partition_name
, COUNT(*) stats_count
FROM dba_tab_stats_history
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) 
AND partition_name IS NULL
AND table_name NOT LIKE 'BIN%'
GROUP BY owner, table_name, partition_name
UNION
SELECT
  owner
, table_name
, partition_name
, COUNT(*) stats_count
FROM dba_tab_stats_history
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) 
AND partition_name IS NOT NULL
GROUP BY owner,table_name, partition_name
)
ORDER BY 
 owner
, stats_count DESC
, table_name
, partition_name
/
