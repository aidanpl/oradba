/*

 Name:          rmancat_permissions_11g.sql

 Purpose:       Required synonyms/permissions from rmancat TO dbmon - oracle 11g or lower implementation 

 Usage:       	If running Oracle 11 or lower these views maybe created in DBMON with suitable grants/synonyms created 
				If running Oracle 12 or higher these grants/synonyms are not required as functionality is installed directly under the RMANCAT schema 
					Please see script rmancat_permissions_12c.sql for information on other required permissions 

 Date            Who             Description

 15th Jun 1017   Aidan Lawrence  Validated for git

*/

GRANT SELECT ON rmancat.rc_archived_log                TO dbmon;
GRANT SELECT ON rmancat.rc_database                    TO dbmon;
GRANT SELECT ON rmancat.rc_backup_archivelog_details   TO dbmon;
GRANT SELECT ON rmancat.rc_backup_archivelog_summary   TO dbmon;
GRANT SELECT ON rmancat.rc_backup_controlfile_summary  TO dbmon;
GRANT SELECT ON rmancat.rc_backup_controlfile          TO dbmon;
GRANT SELECT ON rmancat.rc_backup_controlfile_details  TO dbmon;
GRANT SELECT ON rmancat.rc_backup_datafile_summary     TO dbmon;
GRANT SELECT ON rmancat.rc_backup_datafile             TO dbmon;
GRANT SELECT ON rmancat.rc_backup_datafile_details     TO dbmon;
GRANT SELECT ON rmancat.rc_backup_spfile_summary       TO dbmon;
GRANT SELECT ON rmancat.rc_backup_spfile               TO dbmon;
GRANT SELECT ON rmancat.rc_backup_spfile_details       TO dbmon;
GRANT SELECT ON rmancat.rc_backup_set                  TO dbmon;
GRANT SELECT ON rmancat.rc_backup_piece                TO dbmon;
GRANT SELECT ON rmancat.rc_rman_backup_job_details     TO dbmon;
GRANT SELECT ON rmancat.rc_rman_status                 TO dbmon;
GRANT SELECT ON rmancat.rc_site                        TO dbmon;

CREATE SYNONYM dbmon.rc_archived_log                FOR rmancat.rc_archived_log;
CREATE SYNONYM dbmon.rc_database                    FOR rmancat.rc_database;
CREATE SYNONYM dbmon.rc_backup_archivelog_details   FOR rmancat.rc_backup_archivelog_details;
CREATE SYNONYM dbmon.rc_backup_archivelog_summary   FOR rmancat.rc_backup_archivelog_summary;
CREATE SYNONYM dbmon.rc_backup_controlfile_summary  FOR rmancat.rc_backup_controlfile_summary;
CREATE SYNONYM dbmon.rc_backup_controlfile          FOR rmancat.rc_backup_controlfile;
CREATE SYNONYM dbmon.rc_backup_controlfile_details  FOR rmancat.rc_backup_controlfile_details;
CREATE SYNONYM dbmon.rc_backup_datafile_summary     FOR rmancat.rc_backup_datafile_summary;
CREATE SYNONYM dbmon.rc_backup_datafile             FOR rmancat.rc_backup_datafile;
CREATE SYNONYM dbmon.rc_backup_datafile_details     FOR rmancat.rc_backup_datafile_details;
CREATE SYNONYM dbmon.rc_backup_spfile_summary       FOR rmancat.rc_backup_spfile_summary;
CREATE SYNONYM dbmon.rc_backup_spflie               FOR rmancat.rc_backup_spflie;
CREATE SYNONYM dbmon.rc_backup_spflie_details       FOR rmancat.rc_backup_spflie_details;
CREATE SYNONYM dbmon.rc_backup_set                  FOR rmancat.rc_backup_set;
CREATE SYNONYM dbmon.rc_backup_piece                FOR rmancat.rc_backup_piece;
CREATE SYNONYM dbmon.rc_rman_backup_job_details     FOR rmancat.rc_rman_backup_job_details;
CREATE SYNONYM dbmon.rc_rman_status                 FOR rmancat.rc_rman_status;
CREATE SYNONYM dbmon.rc_site                        FOR rmancat.rc_site;
