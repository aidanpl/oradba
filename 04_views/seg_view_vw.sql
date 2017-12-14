/*

 Name:          seg_view_vw.sql

 Purpose:       Segment level views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 --
 --  Required direct Grants for view creations
 
GRANT SELECT ON dba_tables to DBMON;
GRANT SELECT ON dba_indexes to DBMON;
GRANT SELECT ON dba_tab_partitions to DBMON;
GRANT SELECT ON dba_tab_subpartitions to DBMON;
GRANT SELECT ON dba_ind_partitions to DBMON;
GRANT SELECT ON dba_ind_subpartitions to DBMON;
GRANT SELECT ON dba_segments to DBMON;
GRANT SELECT ON dba_lobs to DBMON;
GRANT SELECT ON dba_lob_partitions to DBMON;
GRANT SELECT ON dba_tablespaces to DBMON;
 
Covered so far:

TABLE
TABLE PARTITION
TABLE SUBPARTITION
INDEX
INDEX PARTITION
LOBSEGMENT
LOB PARTITION
 
Future considerations:
 
LOBINDEX
INDEX SUBPARTITION
NESTED TABLE
ROLLBACK
CLUSTER
TYPE2 UNDO


 Next Steps:

 Date            Who             Description

 12th Jan 2016   Aidan Lawrence  Cloned from similar
 15th Jun 2017   Aidan Lawrence  Validated pre git publication   

*/

CREATE OR REPLACE VIEW segment_1_tables_nonpart
--
-- Table (Non Partitioned) overview 
-- 
AS
  SELECT 
  tab.owner
, tab.table_name
, tab.tablespace_name
, ROUND((seg.bytes/1048976),0) as seg_mbytes
, seg.extents
, tab.num_rows
, tab.avg_row_len
, (seg.bytes/tbs.block_size)   as allocated_blocks -- How many blocks actually allocated by segment
, tab.blocks 				   as actual_blocks    -- How many blocks with rows in 
, ((tab.num_rows * avg_row_len)/tbs.block_size)*1.4  as calc_blocks -- How many blocks needed for rows. (The 1.4 is a factor based on Oracle overhead)
, tab.pct_free                 as pct_free
, TO_CHAR(tab.last_analyzed,'DD-MON-YYYY') 			 as last_analyzed
FROM dba_tables   tab
JOIN dba_segments seg
ON ( tab.owner 		= seg.owner
AND  tab.table_name = seg.segment_name
)
JOIN dba_tablespaces tbs
ON seg.tablespace_name = tbs.tablespace_name
WHERE tab.partitioned = 'NO'
AND seg.segment_type = 'TABLE'
AND NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),tab.owner) 
ORDER BY
  tab.owner
, tab.table_name
/

CREATE OR REPLACE VIEW segment_2_tables_part
--
-- Table (Partitioned) overview 
-- 
AS 
  SELECT 
  tab.table_owner as owner 
, tab.partition_name
, tab.table_name
, tab.tablespace_name
, tab.high_value high_value 
, ROUND((seg.bytes/1048976),0) as seg_mbytes
, seg.extents
, tab.num_rows
, tab.avg_row_len
, (seg.bytes/tbs.block_size)   as allocated_blocks -- How many blocks actually allocated by segment
, tab.blocks 				   as actual_blocks    -- How many blocks with rows in 
, ((tab.num_rows * avg_row_len)/tbs.block_size)*1.4  as calc_blocks -- How many blocks needed for rows. (The 1.4 is a factor based on Oracle overhead)
, tab.pct_free                 as pct_free
, TO_CHAR(tab.last_analyzed,'DD-MON-YYYY') 			 as last_analyzed
FROM dba_tab_partitions tab
JOIN dba_segments seg
ON ( tab.table_owner 		= seg.owner
AND  tab.table_name = seg.segment_name
AND  tab.partition_name = seg.partition_name
)
JOIN dba_tablespaces tbs
ON seg.tablespace_name = tbs.tablespace_name
WHERE seg.segment_type = 'TABLE PARTITION'
AND NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),tab.table_owner) 
ORDER BY
  tab.table_owner
, tab.table_name
, tab.partition_name
/

CREATE OR REPLACE VIEW segment_3_tables_subpart
--
-- Table (Partitioned) overview 
-- 
AS 
  SELECT 
  tab.table_owner as owner 
, tab.table_name
, tab.partition_name
, tab.subpartition_name  
, tab.subpartition_position 
, tab.tablespace_name
, ROUND((seg.bytes/1048976),0) as seg_mbytes
, seg.extents
, (seg.bytes/tbs.block_size)   as allocated_blocks -- How many blocks actually allocated by segment
, tab.pct_free                 as pct_free
, TO_CHAR(tab.last_analyzed,'DD-MON-YYYY') 			 as last_analyzed
FROM dba_tab_subpartitions tab
JOIN dba_segments seg
ON ( tab.table_owner 	= seg.owner
AND  tab.table_name     = seg.segment_name
AND  tab.subpartition_name = seg.partition_name
)
JOIN dba_tablespaces tbs
ON seg.tablespace_name = tbs.tablespace_name
WHERE seg.segment_type = 'TABLE SUBPARTITION'
AND NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),tab.table_owner) 
ORDER BY
  tab.table_owner
, tab.table_name
, tab.partition_name
, tab.subpartition_name  
, tab.subpartition_position 
/

CREATE OR REPLACE VIEW segment_4_indexes_nonpart
--
-- Index (Non Partitioned) overview 
-- 
AS
  SELECT 
  ind.owner
, ind.index_name
, ind.table_name 
, ind.tablespace_name
, ROUND((seg.bytes/1048976),0) as seg_mbytes
, seg.extents
, ind.num_rows
, ind.blevel
, ind.distinct_keys
, (seg.bytes/tbs.block_size)   as allocated_blocks -- How many blocks actually allocated by segment
, ind.leaf_blocks 
, TO_CHAR(ind.last_analyzed,'DD-MON-YYYY') 			 as last_analyzed
FROM dba_indexes   ind
JOIN dba_segments seg
ON ( ind.owner 		= seg.owner
AND  ind.index_name = seg.segment_name
)
JOIN dba_tablespaces tbs
ON seg.tablespace_name = tbs.tablespace_name
WHERE ind.partitioned = 'NO'
AND NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),ind.owner) 
AND seg.segment_type = 'INDEX'
ORDER BY
  ind.owner
, ind.index_name
/

CREATE OR REPLACE VIEW segment_5_indexes_part
--
-- Index (Partitioned) overview 
-- 
AS
SELECT 
  ind.index_owner as owner 
, ind.partition_name
, ind.index_name
, ind.tablespace_name
, ind.high_value high_value
, ROUND((seg.bytes/1048976),0) as seg_mbytes
, seg.extents
, ind.blevel
, ind.num_rows
, ind.distinct_keys
, (seg.bytes/tbs.block_size)   as allocated_blocks -- How many blocks actually allocated by segment
, ind.leaf_blocks 
, TO_CHAR(ind.last_analyzed,'DD-MON-YYYY') 			 as last_analyzed
FROM dba_ind_partitions  ind
JOIN dba_segments seg
ON ( ind.index_owner = seg.owner
AND  ind.index_name  = seg.segment_name
AND  ind.partition_name = seg.partition_name
)
JOIN dba_tablespaces tbs
ON seg.tablespace_name = tbs.tablespace_name
WHERE  seg.segment_type = 'INDEX PARTITION'
AND NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),ind.index_owner) 
ORDER BY
  ind.index_owner
, ind.index_name
, ind.partition_name
/


CREATE OR REPLACE VIEW segment_6_lobs_non_part
--
-- Lob Segments
-- 
AS
SELECT 
  l.owner
, l.table_name
, l.column_name
, l.in_row 
, l.chunk
, l.pctversion
, s.segment_name
, ROUND(s.bytes/1048976,1)           AS lob_mbytes
, ROUND((t.blocks * 8192)/1048976,1) AS table_mbytes
, t.num_rows
, t.avg_row_len
FROM dba_lobs l
JOIN dba_segments s
ON (l.owner = s.owner
AND l.segment_name = s.segment_name
)
JOIN dba_tables t
ON (l.owner = t.owner
AND t.table_name = l.table_name
)
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),l.owner) 
AND s.segment_type = 'LOBSEGMENT' 
ORDER BY 
l.owner
, l.table_name
, l.column_name
/


CREATE OR REPLACE VIEW segment_7_lobs_part
--
-- Lob Part Segments
-- 
AS
  SELECT 
  l.table_owner
, l.table_name
, l.column_name
, l.in_row 
, l.chunk
, l.pctversion
, l.partition_name
, l.lob_partition_name
, ROUND(s.bytes/1048976,1)           AS lob_mbytes
, ROUND((p.blocks * 8192)/1048976,1) AS part_mbytes
, p.num_rows
, p.avg_row_len
FROM dba_lob_partitions l
JOIN dba_tab_partitions p
ON (l.table_owner = p.table_owner
AND p.table_name = l.table_name
AND p.partition_name = l.partition_name
)
JOIN dba_segments s
ON (l.table_owner = s.owner
AND p.table_name = s.segment_name
AND p.partition_name = s.partition_name
)
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),l.table_owner) 
ORDER BY 
l.table_owner
, l.table_name
, l.column_name
, l.partition_name
/
