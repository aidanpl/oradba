/*

 Name:          schema_frag_ck.sql

 Purpose:       Adhoc query to list tables within a schema with a low number of rows per block - candidates for some improvement.

 Usage:         Adhoc investigations for fragmented data. Need to specify various settings/thresholds to control output:
 
				schema_name = schema to investigate 
				block_size = block size for database (no attempt to allow for multiple block sizes)
				define num_rows_cutoff = lower row limit for tables of interest
				define num_blocks_cutoff = lower block limit for tables of interest
				define rows_per_block_cutoff = upper rows/block limit 
 
 
 Example:       sqlplus -s user/pw@sid @schema_frag_ck <schema_name> <block_size> <num_rows_cutoff> <num_blocks_cutoff> <rows_per_block_cutoff>
                sqlplus -s dbmon/pw@dbarep @schema_frag_ck SH 8192 1000 20000 10 

 Date            Who             Description

  4th Sep 2017   Aidan Lawrence  Clean clone from seg_all_ck for git 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'schema_frag_ck'
set verify on
define schema_name = '&1'
define block_size = &2
define num_rows_cutoff = &3
define num_blocks_cutoff = &4
define rows_per_block_cutoff = &5
set verify off
--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;
       
SELECT '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || lower('&schema_name')
       || '_'	   
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI') 
       || '.lst' spool_name      
  FROM v$database d;
  
SELECT 'Output report name is ' 
       || '&spool_name'
  FROM dual;  

spool &spool_name

prompt 
prompt Report Details are &spool_name                     
prompt


--
-- Main report begins
--

set heading on

-- See login.sql for col definitions 

prompt
prompt ################################################
prompt #                                              #
prompt #  Table high unused blocks                    #
prompt #                                              #
prompt ################################################
prompt

SELECT
  owner
, table_name
, tablespace_name
, seg_mbytes
, extents
, num_rows
, avg_row_len
, allocated_blocks 
, actual_blocks    
, calc_blocks 
, round(num_rows / allocated_blocks,0)      AS rows_per_block 
, round(allocated_blocks - actual_blocks,0) AS unused_blocks 
, round(allocated_blocks - calc_blocks,0)   AS unused_blocks_potential
, pct_free
, last_analyzed
FROM segment_1_tables_nonpart
WHERE owner = '&schema_name'
AND num_rows is not null
AND allocated_blocks - actual_blocks >  &num_blocks_cutoff -- compare allocation with actual block usage actual
/

prompt
prompt ################################################
prompt #                                              #
prompt #  Table high unused blocks potential          #
prompt #                                              #
prompt ################################################
prompt

SELECT
  owner
, table_name
, tablespace_name
, seg_mbytes
, extents
, num_rows
, avg_row_len
, allocated_blocks 
, actual_blocks    
, calc_blocks 
, round(num_rows / allocated_blocks,0)      AS rows_per_block 
, round(allocated_blocks - actual_blocks,0) AS unused_blocks 
, round(allocated_blocks - calc_blocks,0)   AS unused_blocks_potential
, pct_free
, last_analyzed
FROM segment_1_tables_nonpart
WHERE owner = '&schema_name'
AND num_rows is not null
AND allocated_blocks - calc_blocks >  &num_blocks_cutoff -- compare allocation with actual block usage actual
/

prompt
prompt ################################################
prompt #                                              #
prompt #  Table low rows per block                    #
prompt #                                              #
prompt ################################################
prompt

SELECT
  owner
, table_name
, tablespace_name
, seg_mbytes
, extents
, num_rows
, avg_row_len
, allocated_blocks 
, actual_blocks    
, calc_blocks 
, round(num_rows / allocated_blocks,0)      AS rows_per_block 
, round(allocated_blocks - actual_blocks,0) AS unused_blocks 
, round(allocated_blocks - calc_blocks,0)   AS unused_blocks_potential
, pct_free
, last_analyzed
FROM segment_1_tables_nonpart
WHERE owner = '&schema_name'
AND num_rows is not null
AND num_rows > &num_rows_cutoff  -- only interested in tables above a certain size in terms of rows
AND actual_blocks > &num_blocks_cutoff  -- only interested in tables above a certain size in terms of blocks
AND (num_rows/actual_blocks) <  &rows_per_block_cutoff -- only interested in tables below a certain size rows per 
/

prompt
prompt ################################################
prompt #                                              #
prompt #  Partitioned Table low rows per block        #
prompt #                                              #
prompt ################################################
prompt

SELECT
  owner
, partition_name
, table_name
, tablespace_name
, high_value
, seg_mbytes
, extents
, num_rows
, avg_row_len
, allocated_blocks 
, actual_blocks    
, calc_blocks
, round(num_rows / allocated_blocks,0)      AS rows_per_block 
, round(allocated_blocks - actual_blocks,0) AS unused_blocks 
, round(allocated_blocks - calc_blocks,0)   AS unused_blocks_potential 
, pct_free
, last_analyzed
FROM segment_2_tables_part
WHERE owner = '&schema_name'
AND num_rows is not null
AND num_rows > &num_rows_cutoff  -- only interested in tables above a certain size in terms of rows
AND actual_blocks > &num_blocks_cutoff  -- only interested in tables above a certain size in terms of blocks
AND (num_rows/actual_blocks) <  &rows_per_block_cutoff -- only interested in tables below a certain size row
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

--edit &spool_name
exit
