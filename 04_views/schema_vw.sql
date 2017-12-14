/*

 Name:          schema_vw.sql

 Purpose:       Schema level views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 --
 --  Required direct Grants for view creations
 
GRANT SELECT ON dba_segments to DBMON;

 Next Steps:

 Date            Who             Description

 12th Jan 2016   Aidan Lawrence  Cloned from similar
 31st Aug 2017   Aidan Lawrence  Validated pre git publication   

*/

CREATE OR REPLACE VIEW schema_1_overview
--
-- Schema Segment summary overview
-- 
AS
SELECT 
  seg.owner
, ROUND(SUM(seg.bytes)/1048976,0)   AS seg_mbytes
, COUNT(seg.bytes) 				    AS seg_count
FROM dba_segments seg
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) 
GROUP BY seg.owner
ORDER BY
  seg.owner
/

CREATE OR REPLACE VIEW schema_2_by_tbsp
--
-- Schema Segment summary by tablespace 
-- 
AS
SELECT 
  seg.owner
, seg.tablespace_name
, ROUND(SUM(seg.bytes)/1048976,0)   AS seg_mbytes
, COUNT(seg.bytes) 				    AS seg_count
FROM dba_segments seg
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) 
GROUP BY seg.owner
, seg.tablespace_name
ORDER BY
  seg.owner
, seg.tablespace_name
/

CREATE OR REPLACE VIEW schema_3_by_tbsp_by_type
--
-- Schema Segment summary by tablespace by type 
-- 
AS
SELECT 
  seg.owner
, seg.tablespace_name
, seg.segment_type                  AS seg_type
, ROUND(SUM(seg.bytes)/1048976,0)   AS seg_mbytes
, COUNT(seg.bytes) 				    AS seg_count
FROM dba_segments seg
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) 
GROUP BY seg.owner
, seg.tablespace_name
, seg.segment_type
ORDER BY
  seg.owner
, seg.tablespace_name
, seg.segment_type
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
WHERE tab.table_owner NOT IN ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
AND seg.segment_type = 'TABLE PARTITION'
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
WHERE tab.table_owner NOT IN ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
AND seg.segment_type = 'TABLE SUBPARTITION'
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
AND   ind.owner NOT IN ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
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
WHERE  ind.index_owner NOT IN ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')
AND seg.segment_type = 'INDEX PARTITION'
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
