/*

 Name:          lob_view_vw.sql

 Purpose:       LOB level views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 --
 --  Required direct Grants for view creations
 
GRANT SELECT ON dba_lobs to DBMON;
GRANT SELECT ON dba_segments to DBMON;
GRANT SELECT ON dba_tables to DBMON;

 Next Steps:

 Date            Who             Description

 3rd Sep 2017   Aidan Lawrence  Cloned from similar

*/

CREATE OR REPLACE VIEW lob_1_segments
--
-- Lob Segment overview
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
;

CREATE OR REPLACE VIEW lob_2_partitions
--
-- LOB Partitions
-- 
AS
SELECT 
  l.table_owner
, l.table_name
, l.column_name
, l.lob_name
, l.partition_name
, l.in_row 
, l.chunk
, l.pctversion
FROM dba_lob_partitions l
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),l.table_owner) 
ORDER BY 
l.table_owner
, l.table_name
, l.column_name
, l.partition_name
;

