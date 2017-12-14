/*

 Name:          login.sql

 Purpose:       Specify sql*plus environment and column definitions for a given directory for consistency across reports. 

 Usage:         Edit column definitions to suit an individual environment

 Implementation: For Oracle 12.1 or before login.sql will be executed as part of the sql*plus execution
				 For Oracle 12.2 or later this is no longer the case. Instead Oracle searchs directories specified in the ORACLE_PATH environment variable - which by default is unset. 
				 
				 To continue using login.sql functionality in Oracle 12.2 then set ORACLE_PATH=. before executing SQL*PLUS

 Date            Who             Description

  4th Sep 2017   Aidan Lawrence  Comments on changed behaviour in Oracle 12.2 

*/
prompt
prompt ###############################################################
prompt #                                                             #
prompt #  Login.sql present in this directory                        #
prompt #                                                             #
prompt ###############################################################
prompt

--
-- Basic formatting
--
set pages 99
set linesize 172
set verify off
set trimspool on
set feedback off
set heading off
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

set heading on
set termout on
set feedback on


-- NB - Careful adding any more to this - max string size is 240 characters :-o
define ignore_schemas = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')

column owner             format a18 Heading Owner
column table_owner       format a18 Heading Owner
column table_name        format a30 Heading 'Table|Name'
column partition_name    format a25 Heading 'Partition|Name'
column subpartition_name format a25 Heading 'SubPartition|Name'
column index_name        format a30 Heading 'Index|Name'
column subpartition_position format 999 Heading 'SubPartition|Position'
column tablespace_name   format a25 Heading 'Tablespace|Name'
column seg_mbytes        format 999,999 Heading "Total|Bytes (Mb)"
column seg_count         format 999,999 Heading "Seg|Count"
column seg_type          format a25 Heading 'Segment|Type'
column obj_count         format 999,999 Heading "Obj|Count"
column obj_type          format a25 Heading 'Object|Type'
column extents           format 99,999 Heading "Total|Extents"
column num_rows          format 999,999,999 Heading "Row|Count"
column avg_row_len       format 9,999 Heading "Avg|Lgnth"
column allocated_blocks  format 999,999 Heading "Alloc|Blocks"
column actual_blocks     format 999,999 Heading "Used|Blocks"
column calc_blocks       format 999,999 Heading "Calc|Blocks"
column rows_per_block    format 9,999 Heading "Rows per|Block"
column unused_blocks     format 999,999 Heading "Unused|Blocks"
column unused_blocks_potential   format 999,999 Heading "Potential|Unused Blocks"
column pct_free          format 999 Heading "PCT|Free"
column last_analyzed     format a11 Heading "Last|Analyzed"
column high_value        format a30 Heading 'High|Value'
column blevel            format 9   Heading "Branches"
column distinct_keys     format 999,999,999 Heading "Distinct|Keys"
column leaf_blocks       format 999,999 Heading "Leaf|Blocks"
column seg_csv           format a1000

--
-- lob specific

column column_name       format a30       Heading "Column|Name"
column segment_name      format a30       Heading "Segment|Name"
column lob_name          format a30       Heading "Lob|Name"
column lob_format        format a4        Heading "Lob|Format"
column lob_mbytes        format 999,990.9 Heading "Lob|MBytes"
column table_mbytes      format 999,990.9 Heading "Table|MBytes"
column in_row            format a4        Heading "In|Row"
column chunk             format 999,999   Heading "Chunk"
column pctversion        format 999       Heading "Pct"



