/*

 Name:          rmancat_views_vw.sql

 Purpose:       Views to RMAN catalog (driven by dba_roadmap)
 
 Usage:			
				If running Oracle 12 or higher create these views directly in the RMANCAT schema 
				If running Oracle 11 or lower these views maybe created in DBMON with suitable grants/synonyms created 
					Please see script rmancat_permissions_11g.sql for information on how permissions can be granted to the DBMON monitoring user. 
 
Assuming schema names are DBMON and RMANCAT respectively 

GRANT SELECT ON dbmon.DBAREP_ROADMAP TO RMANCAT;
and 
CREATE SYNONYM  RMANCAT.DBAREP_ROADMAP     FOR  dbmon.DBAREP_ROADMAP;

 Prerequisities:
				Table dbarep_roadmap has been created and populated with one row for each database of interest 
 
                
 Date            Who             Description

  3rd Feb 2016   Aidan Lawrence  Added NVL(r.priority) to avoid issues when accessing withing cgi/html
 23rd Feb 2017   Aidan Lawrence  For Oracle 12c need to either deal with VPD crackdown or create views in rmancat schema and just have grants/synonyms from dbmon for dbarep_roadmap etc. 
 15th Jun 1017   Aidan Lawrence  Validated for git   
*/

CREATE OR REPLACE VIEW rmancat_recent_summary AS 
SELECT
  NVL(r.priority,99) as priority
, s.db_unique_name                    as db_unique_name
, s.database_role                     as database_role
, NVL(r.host_name,'outstanding')      as host_name
, NVL(r.usage,'outstanding')          as usage
, NVL(r.oracle_release,'outstanding') as release
, MAX(bs.completion_time)             as max_completion_time
, MIN(bs.completion_time)             as min_completion_time
, NVL(r.description,'outstanding')    as description
FROM
dbarep_roadmap r
LEFT JOIN rc_database  db
ON (db.name = r.db_name)
LEFT JOIN rc_backup_set bs
ON (bs.db_id = db.dbid
AND bs.status = 'A'
)
inner join rc_site s
ON (bs.site_key = s.site_key
AND r.db_unique_name = s.db_unique_name)
GROUP BY
  priority 
, r.db_name
, s.db_unique_name
, s.database_role
, NVL(r.host_name,'outstanding')
, NVL(r.usage,'outstanding')
, NVL(r.oracle_release,'outstanding')
, NVL(r.backup_method,'outstanding')
, NVL(r.description,'outstanding')
ORDER BY
 priority asc
, r.db_name
;

CREATE OR REPLACE VIEW rmancat_recent_problems AS 
select
  bjd.db_name as name
, NVL(r.priority,99) as priority  
, bjd.status
, bjd.input_type
, bjd.start_time
, bjd.end_time
, input_bytes_display
, time_taken_display
from
rc_rman_backup_job_details bjd
left join dbarep_roadmap r
ON (bjd.db_name = r.db_name
)
where bjd.start_time >= sysdate - 3
and status <> 'COMPLETED'
and status <> 'RUNNING'
order by
  priority
, bjd.db_name
, bjd.start_time desc;

CREATE OR REPLACE VIEW rmancat_recent_jobs AS 
SELECT
  s.db_unique_name
, NVL(r.priority,99) as priority  
--, bjd.db_name as name
, bjd.status
, bjd.input_type
, bjd.start_time
, bjd.end_time
, input_bytes_display
, output_bytes_display
, time_taken_display
, s.database_role
from
rc_rman_backup_job_details bjd
left join rc_rman_status rs
ON (bjd.session_key = rs.session_key
AND rs.row_level = 0)
left join rc_site s
ON (rs.site_key = s.site_key)
left join dbarep_roadmap r
ON (bjd.db_name = r.db_name
AND s.db_unique_name = r.db_unique_name
)
where bjd.start_time >= sysdate - 7
order by
  priority
, s.db_unique_name
, bjd.start_time desc;

CREATE OR REPLACE VIEW rmancat_controlfile_summary AS 
SELECT
  bcs.db_name
, NVL(r.priority,99) as priority
, num_files_backed
, num_distinct_files_backed
, min_checkpoint_time
, max_checkpoint_time
, input_bytes_display
, output_bytes_display
FROM rc_backup_controlfile_summary bcs
left join dbarep_roadmap r
ON (bcs.db_name = r.db_rman_unique_name)
order by priority, bcs.db_name;

CREATE OR REPLACE VIEW rmancat_spfile_summary AS 
SELECT
  bss.db_name
, NVL(r.priority,99) as priority
, num_files_backed
, num_distinct_files_backed
, min_modification_time
, max_modification_time
, input_bytes_display
FROM rc_backup_spfile_summary bss
left join dbarep_roadmap r
ON (bss.db_name = r.db_rman_unique_name)
order by priority, bss.db_name;

CREATE OR REPLACE VIEW rmancat_datafile_summary AS 
SELECT
  bds.db_name
, NVL(r.priority,99) as priority
, num_files_backed
, num_distinct_files_backed
, num_distinct_ts_backed
, min_checkpoint_time
, max_checkpoint_time
, input_bytes_display
, output_bytes_display
, round(compression_ratio,1) as compression_ratio
FROM rc_backup_datafile_summary bds
left join dbarep_roadmap r
ON (bds.db_name = r.db_rman_unique_name)
order by priority, bds.db_name;

CREATE OR REPLACE VIEW rmancat_archivelog_summary AS 
SELECT
  bas.db_name
, NVL(r.priority,99) as priority
, num_files_backed
, num_distinct_files_backed
, min_first_time
, max_next_time
, input_bytes_display
, output_bytes_display
, round(compression_ratio,1) as compression_ratio
FROM rc_backup_archivelog_summary bas
left join dbarep_roadmap r
ON (bas.db_name = r.db_rman_unique_name)
order by priority, bas.db_name;



CREATE OR REPLACE VIEW rmancat_controlfile AS 
SELECT
  bc.db_name
, NVL(r.priority,99) as priority  
, bc.completion_time
--, bc.checkpoint_time
, bc.status 
, bp.handle as backup_file_name
FROM rc_backup_controlfile bc
JOIN rc_backup_piece bp
ON (bc.bs_key = bp.bs_key)
LEFT JOIN dbarep_roadmap r
ON (bc.db_name = r.db_rman_unique_name)
ORDER BY priority, bc.db_name, bc.completion_time desc;

CREATE OR REPLACE VIEW rmancat_spfile AS 
SELECT
  bs.db_unique_name
, NVL(r.priority,99) as priority  
, bs.completion_time
--, bc.checkpoint_time
, bs.status 
, bp.handle as backup_file_name
FROM rc_backup_spfile bs
JOIN rc_backup_piece bp
ON (bs.bs_key = bp.bs_key)
LEFT JOIN dbarep_roadmap r
ON (bs.db_unique_name = r.db_rman_unique_name)
ORDER BY priority, bs.db_unique_name, bs.completion_time desc;

CREATE OR REPLACE VIEW rmancat_datafile AS 
SELECT
  bd.db_name
, NVL(r.priority,99) as priority
, bd.completion_time
, bd.backup_type
, CASE 
  WHEN bd.incremental_level IS NULL THEN 'N/A'
  ELSE to_char(bd.incremental_level)
  END as incremental_level
, bd.status 
, bd.datafile_blocks as file_blocks
, bd.blocks as backup_blocks
, bp.handle as backup_file_name
FROM rc_backup_datafile bd
JOIN rc_backup_piece bp
ON (bd.bs_key = bp.bs_key)
LEFT JOIN dbarep_roadmap r
ON (bd.db_name = r.db_rman_unique_name)
ORDER BY priority, bd.db_name, bd.completion_time desc;

CREATE OR REPLACE VIEW rmancat_archivelog AS 
SELECT
  s.db_unique_name
, NVL(r.priority,99) as priority  
, s.database_role  
, al.completion_time
, al.status 
, al.name
FROM rc_archived_log al
LEFT JOIN dbarep_roadmap r
ON (al.db_name = r.db_rman_unique_name)
left join rc_site s
ON (s.site_key = al.site_key)
ORDER BY priority
, s.db_unique_name
, al.completion_time desc;


/* 

Under development

CREATE OR REPLACE VIEW recent_backup_sizes AS 
select 
  r.db_unique_name
, bjd.input_type    
, round(sum(output_bytes/1048976),1) as sum_mbytes
from 
npa_dba_roadmap r
left join rc_rman_backup_job_details bjd
ON (r.db_name = bjd.db_name
)
where trunc(bjd.start_time) >= trunc(sysdate) - 7
and trunc(bjd.start_time) <= trunc(sysdate)
GROUP BY r.db_unique_name
, bjd.input_type
order by 
NVL(r.priority,99)
, r.db_unique_name
 
*/