/*

 Name:          seg_all_ck.sql

 Purpose:       Segment details all including block usage, last analyzed etc.

 Usage:          Be a little careful with this script - can run for a moderate period of time on large systems

 Date            Who             Description

 2nd Apr 2008    Aidan Lawrence  Merger from various scripts plus sanity check and general tidy up
19th Jun 2008    AIdan Lawrence  Added in calculation for estimated blocks required as well as actually used to help spot tables
                                 that have been oversized
                                 
 14th Sep 2009   Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication                                  
 11th Jan 2016   Aidan Lawrence  Changed to access from views and col definitions to login.sql 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'seg_all_ck'
--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;
       
select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI') 
       || '.lst' spool_name      
  from v$database d;
  
select 'Output report name is ' 
       || '&spool_name'
  from dual;  

spool &spool_name

prompt 
prompt Report Details are &spool_name                     
prompt


prompt
prompt ################################################
prompt #                                              #
prompt #  Oracle Table Details Report                 #
prompt #                                              #
prompt ################################################
prompt

--
-- Main report begins
--

set heading on

-- See login.sql for col definitions 

select
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
, pct_free
, last_analyzed
from segment_1_tables_nonpart
/

prompt
prompt ################################################
prompt #                                              #
prompt #  Oracle Partition Table Details Report       #
prompt #                                              #
prompt ################################################
prompt

select
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
, pct_free
, last_analyzed
from segment_2_tables_part
/

prompt
prompt ################################################
prompt #                                              #
prompt #  Oracle Subpartition Table Details Report    #
prompt #                                              #
prompt ################################################
prompt

select
  owner
, table_name  
, partition_name
, subpartition_name
, subpartition_position
, tablespace_name
, seg_mbytes
, extents
, allocated_blocks 
, pct_free
, last_analyzed
from segment_3_tables_subpart
/

prompt
prompt ################################################
prompt #                                              #
prompt #  Oracle Index Details Report                 #
prompt #                                              #
prompt ################################################
prompt


select
  owner
, index_name
, table_name 
, tablespace_name
, seg_mbytes
, extents
, blevel 
, num_rows
, distinct_keys
, allocated_blocks 
, leaf_blocks 
, last_analyzed
from segment_4_indexes_nonpart
/

prompt
prompt ################################################
prompt #                                              #
prompt #  Oracle Partition Index Details Report       #
prompt #                                              #
prompt ################################################
prompt

select
  owner
, index_name
, partition_name
, tablespace_name
, seg_mbytes
, extents
, blevel 
, num_rows
, distinct_keys
, allocated_blocks 
, leaf_blocks 
, last_analyzed
from segment_5_indexes_part
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit

