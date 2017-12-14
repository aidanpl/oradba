/*

 Name:          seg_tbsp_ck.sql

 Purpose:       Segment details for a single tablespace 

 Usage:         A filtered version of seg_all_ck when working with contents at a tablespace level 
 
 Example:       sqlplus -s user/pw@sid @seg_tbsp_ck <tablespace_name>
                sqlplus -s dbmon/pw@dbarep @seg_tbsp_ck SAMPLE_SCHEMAS

 Date            Who             Description

  4th Sep 2017   Aidan Lawrence  Clean clone from seg_all_ck for git 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'seg_tbsp_ck'
set verify on
define tablespace_name  = '&1'
set verify off
--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;
       
select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || lower('&tablespace_name')
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
where tablespace_name = '&tablespace_name'
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
where tablespace_name = '&tablespace_name'
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
where tablespace_name = '&tablespace_name'
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
where tablespace_name = '&tablespace_name'
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
where tablespace_name = '&tablespace_name'
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit

