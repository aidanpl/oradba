/*

 Name:          07_highio_views_vw.sql

 Purpose:       Dynamic views based on high_resource_sql_ck.sql script

 Usage:         A series for views typically called from front end perl/cgi etc. etc.

 Implementation Typically run under 'dbmon' type user.
 
				Note dependent on PERFSTAT parameter tables 
				
--
-- Required GRANTS from SYS to dbmon: 

GRANT SELECT ON v_$segment_statistics  			   TO dbmon;
GRANT SELECT ON v_$filemetric  					   TO dbmon;
GRANT SELECT ON v_$filemetric_history  			   TO dbmon;
GRANT SELECT ON v_$osstat 				           TO dbmon;
GRANT SELECT ON perfstat.stats$statspack_parameter TO dbmon;
				
 
 Date            Who             Description

 18th Dec 2015   Aidan Lawrence  Continued end of year tidy up
 24th Feb 2017   Aidan Lawrence  Tweak to grant notes during Ora12 sanity checks 

*/

  CREATE OR REPLACE FORCE VIEW highio_1_segstats AS 
  select /*+  ordered use_nl(s1.gv$segstat.X$KSOLSFTS) */
               s1.owner
             , s1.object_name
             , NVL(s1.subobject_name,'N/A') as partition_name
             , s1.tablespace_name
             , sum(decode(s1.statistic_name,'logical reads',s1.value,0))           as logical_reads
             , sum(decode(s1.statistic_name,'buffer busy waits',s1.value,0))       as buffer_busy_waits
             , sum(decode(s1.statistic_name,'db block changes',s1.value,0))        as db_block_changes
             , sum(decode(s1.statistic_name,'physical reads',s1.value,0))          as physical_reads
             , sum(decode(s1.statistic_name,'physical writes',s1.value,0))         as physical_writes
             , sum(decode(s1.statistic_name,'physical reads direct',s1.value,0))   as physical_reads_direct
             , sum(decode(s1.statistic_name,'physical writes direct',s1.value,0))  as physical_writes_direct
             , sum(decode(s1.statistic_name,'gc cr blocks received',s1.value,0))   as gc_cr_blocks_received
             , sum(decode(s1.statistic_name,'gc current blocks received',s1.value,0)) as gc_current_blocks_received
             , sum(decode(s1.statistic_name,'gc buffer busy',s1.value,0))             as gc_buffer_busy
             , sum(decode(s1.statistic_name,'ITL waits',s1.value,0))                  as ITL_waits
             , sum(decode(s1.statistic_name,'row lock waits',s1.value,0))             as row_lock_waits
          from v$segment_statistics s1
          where (s1.dataobj#, s1.obj#, s1.ts#) in (
                                 select /*+ unnest */
                                        s2.dataobj#
                                      , s2.obj#
                                      , s2.ts#
                                   from v$segment_statistics s2
                                  where s2.obj# > 0
                                    and s2.obj# < 4254950912
                                    and  ( decode(s2.statistic_name,'logical reads',s2.value,0)              > (SELECT seg_log_reads_th FROM perfstat.stats$statspack_parameter)
                                        or decode(s2.statistic_name,'physical reads',s2.value,0)             > (SELECT seg_phy_reads_th FROM perfstat.stats$statspack_parameter)
                                        or decode(s2.statistic_name,'buffer busy waits',s2.value,0)          > (SELECT seg_buff_busy_th FROM perfstat.stats$statspack_parameter)
                                        or decode(s2.statistic_name,'row lock waits',s2.value,0)             > (SELECT seg_rowlock_w_th FROM perfstat.stats$statspack_parameter)
                                        or decode(s2.statistic_name,'ITL waits',s2.value,0)                  > (SELECT seg_itl_waits_th FROM perfstat.stats$statspack_parameter)
                                        or decode(s2.statistic_name,'gc cr blocks received',s2.value,0)      > (SELECT seg_cr_bks_rc_th FROM perfstat.stats$statspack_parameter)
                                        or decode(s2.statistic_name,'gc current blocks received',s2.value,0) > (SELECT seg_cu_bks_rc_th FROM perfstat.stats$statspack_parameter)
                                         )
                                       )
      group by
      s1.owner
      , s1.object_name
      , s1.subobject_name
      , s1.tablespace_name
      order by
	  physical_reads desc
      , s1.owner
      , s1.object_name
      , s1.subobject_name;
	  
CREATE OR REPLACE VIEW highio_2_filemetric_recent AS 
  select
  ddf.tablespace_name                     as tablespace_name
, substr(ddf.file_name,1,50)              as file_name
, to_char(begin_time,'HH24:MI')           as from_time
, to_char(end_time,'HH24:MI')             as to_time
, physical_reads                          as phys_reads
, physical_block_reads                    as phys_block_reads
, physical_writes                         as phys_writes
, physical_block_writes                   as phys_block_writes
, round(average_read_time,4)              as avg_read_time_100s
, round(average_write_time,4)             as avg_write_time_100s
from v$filemetric vh
join dba_data_files ddf
on vh.file_id = ddf.file_id
order by phys_reads desc, file_name asc;


	  
CREATE OR REPLACE VIEW highio_3_filemetric_history AS 
  select
  ddf.tablespace_name                     as tablespace_name
, substr(ddf.file_name,1,50)              as file_name
, to_char(begin_time,'HH24:MI')           as from_time
, to_char(end_time,'HH24:MI')             as to_time
, physical_reads                          as phys_reads
, physical_block_reads                    as phys_block_reads
, physical_writes                         as phys_writes
, physical_block_writes                   as phys_block_writes
, round(average_read_time,4)              as avg_read_time_100s
, round(average_write_time,4)             as avg_write_time_100s
from v$filemetric_history vh
join dba_data_files ddf
on vh.file_id = ddf.file_id
order by phys_reads desc, file_name asc;

CREATE OR REPLACE VIEW highio_4_osstats AS 
  select 
  stat_name  as statname
, value as value 
, comments as comments   
, cumulative as cumulative
, osstat_id
from v$osstat os
order by osstat_id;
	  

