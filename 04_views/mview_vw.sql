/*

 Name:          mview_vw.sql

 Purpose:       Materialized Views vw 

 Usage:         A series for views typically called from front end perl/cgi etc. etc.
 
 Required GRANTS from SYS to dbmon: 
 
GRANT SELECT ON dba_mviews                  TO dbmon;
GRANT SELECT ON dba_mview_logs              TO dbmon;
GRANT SELECT ON dba_mview_log_filter_cols   TO dbmon;
GRANT SELECT ON dba_mview_refresh_times     TO dbmon;
GRANT SELECT ON dba_registered_mviews       TO dbmon;
GRANT SELECT ON dba_registered_mview_groups TO dbmon;
GRANT SELECT ON dba_rgroup                  TO dbmon;
GRANT SELECT ON dba_refresh_children        TO dbmon;
GRANT SELECT ON dba_repcat                  TO dbmon;
GRANT SELECT ON sys.mlog$                   TO dbmon;
GRANT SELECT ON dba_segments                TO dbmon;

 
 Date            Who             Description

 28th Sep 2017   Aidan Lawrence  Validated for git 

*/

CREATE OR REPLACE  VIEW mview_1_refresh_times
--
-- Materialised Views Refresh Time by Owner
--
AS 
SELECT 
  dmrt.owner
, dmrt.name         AS local_view
, dmrt.master_owner 
, dmrt.master       AS master_table
, dmv.compile_state
, to_char(dmv.last_refresh_date,'DD-MON HH24:MI:SS') AS local_refresh_time
, to_char(dmrt.last_refresh,'DD-MON HH24:MI:SS')     AS master_refresh_time
FROM dba_mview_refresh_times dmrt
JOIN dba_mviews dmv 
ON  (dmrt.owner = dmv.owner
AND  dmrt.name = dmv.mview_name
)
ORDER BY 
dmrt.owner
, master_refresh_time desc 
/


CREATE OR REPLACE  VIEW mview_2_reg_child_views
--
-- Registered Child Materialised Views by Owner
--
AS 
SELECT
  name  AS child_view
, owner AS child_schema
, mview_site AS child_db
, updatable
FROM dba_registered_mviews
ORDER BY 
child_view
, child_schema
/


CREATE OR REPLACE  VIEW mview_3_local_groups
--
-- Registered Local Materialised View groups 
--
AS 
SELECT
  name       AS local_name 
, mview_site AS child_site
FROM 
dba_registered_mview_groups
ORDER BY name
/

prompt
prompt 

CREATE OR REPLACE  VIEW mview_4_local_refresh_groups
--
-- Local Refresh Group Information
--
AS 
SELECT
  owner
, name
, job
FROM dba_rgroup
/

CREATE OR REPLACE  VIEW mview_5_local_refresh_info
--
-- Local Refresh Information by owner by name 
--
AS 
SELECT
owner
, name
, rowner as master_owner
, rname  as master_name
, job
, to_char(next_date,'DD-MON HH24:MI:SS') AS next_date
, interval
, CASE broken
	WHEN 'N' THEN 'No'
	WHEN 'Y' THEN 'Yes'
	ELSE broken
  END AS broken
FROM dba_refresh_children
ORDER BY 
rowner
, rname
/


CREATE OR REPLACE  VIEW mview_6_repcat
--
-- Repcat Information
--
AS 
SELECT
  sname
, master AS is_master
, status
FROM dba_repcat
/

CREATE OR REPLACE  VIEW mview_7_mlog_summary
--
-- Materialised View Logs summary
--
AS 
SELECT 
  dml.log_owner
, dml.master 	AS master_table
, dml.log_table
, TO_CHAR(sml.oldest,'DD-MON-YYYY HH24:MI:SS')   AS oldest
, TO_CHAR(sml.youngest,'DD-MON-YYYY HH24:MI:SS') AS youngest
FROM dba_mview_logs dml
JOIN sys.mlog$ sml
ON (dml.log_owner=sml.mowner
AND   dml.master=sml.master
)
ORDER BY 
  log_owner
, master_table asc
/

CREATE OR REPLACE  VIEW mview_8_mlog_old_entries
--
-- Materialised Logs with entries older than 24 hours 
--
AS 
SELECT 
  sml.mowner AS master_owner
, sml.master AS master_table
, TO_CHAR(sml.oldest,'DD-MON-YYYY HH24:MI:SS')   AS oldest
, TO_CHAR(sml.youngest,'DD-MON-YYYY HH24:MI:SS') AS youngest
FROM SYS.MLOG$ sml
WHERE sml.oldest < SYSDATE - 1 -- Only show entries for Logs not cleared in last 24 hours
ORDER BY oldest ASC
/


CREATE OR REPLACE  VIEW mview_9_mlog_diff_entries
--
-- Materialized logs with different youngest and oldest entries
--
AS 
SELECT * FROM 
(SELECT
  dml.log_owner
, dml.master 	AS master_table
, dml.log_table
, TO_CHAR(sml.oldest,'DD-MON-YYYY HH24:MI:SS')   AS oldest
, TO_CHAR(sml.youngest,'DD-MON-YYYY HH24:MI:SS') AS youngest
, round(ds.bytes/1048976,1) 					 AS size_mlog_mbytes
FROM dba_mview_logs dml
JOIN sys.mlog$ sml
ON (dml.log_owner=sml.mowner
AND   dml.master=sml.master)
JOIN dba_segments ds
ON ds.segment_name=dml.log_table
AND ds.owner=dml.log_owner
) a
WHERE oldest <> youngest
ORDER BY
  log_owner
, master_table asc
/

CREATE OR REPLACE  VIEW mview_10_filter_cols
--
-- Materialised View Filter columns by Owner by master date
--
AS 
SELECT 
  owner AS master_owner
, name  AS master_table
, column_name
FROM dba_mview_log_filter_cols
ORDER BY 
  owner
, master_table
/


