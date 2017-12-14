/*

 Name:          phys_view_vw.sql

 Purpose:       'Physical' Check  level views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 Implementation Typically run under 'dbmon' type user. Initially cloned from seg_all_ck etc. etc. 
 
 Required direct Grants for view creations
 
 
 
GRANT SELECT ON dba_data_files to DBMON;
GRANT SELECT ON dba_temp_files to DBMON;
GRANT SELECT ON v_$controlfile to DBMON;
GRANT SELECT ON v_$logfile to DBMON;
GRANT SELECT ON v_$parameter to DBMON;
 
 Next Steps:

 Date            Who             Description

 31st May 2016   Aidan Lawrence  Cloned from similar
 15th Jun 2017   Aidan Lawrence  Validated pre git publication    

*/

CREATE OR REPLACE VIEW phys_1_data_files
--
-- DBA data files 
-- 
AS SELECT 
  file_id
, file_name
, tablespace_name
, status as file_status 
, round((bytes/1048976)) AS mbytes
-- When maxbytes is 0 use bytes to show max size 
, CASE round((maxbytes/1048976))
	WHEN 0 THEN round((bytes/1048976))
	ELSE round((maxbytes/1048976))
  END AS max_mbytes
, autoextensible as extendable
from dba_data_files
order by 
  tablespace_name
, file_name
/

CREATE OR REPLACE VIEW phys_2_temp_files
--
-- DBA temp files 
-- 
AS SELECT 
  file_id
, file_name
, tablespace_name
, status as file_status 
, round((bytes/1048976)) as mbytes
-- When maxbytes is 0 use bytes to show max size 
, CASE round((maxbytes/1048976))
	WHEN 0 THEN round((bytes/1048976))
	ELSE round((maxbytes/1048976))
  END AS max_mbytes
, autoextensible as extendable
FROM dba_temp_files
ORDER BY 
  tablespace_name
, file_name
/

CREATE OR REPLACE VIEW phys_3_redo_files
--
-- Redo/Standby log files 
-- 
AS SELECT 
  type   as redo_type
, group# as redo_group
, member as redo_member 
, status as file_status 
FROM v$logfile
ORDER BY 
  redo_type
, redo_group
, redo_member
/

CREATE OR REPLACE VIEW phys_4_control_files
--
-- Control files 
-- 
AS SELECT 
  name    as file_name
, status  as file_status
FROM v$controlfile
ORDER BY 
  file_name
/

CREATE OR REPLACE VIEW phys_5_destinations
--
-- Destinations of interest 
-- 
AS SELECT 
  value   as parameter_value
, name    as parameter_name
FROM v$parameter
WHERE name <> 'control_files'
-- Search for directories with slashes following Linux or Windows standards
AND regexp_like(value,'[\/]')
ORDER BY 
  parameter_value
, parameter_name  
/


