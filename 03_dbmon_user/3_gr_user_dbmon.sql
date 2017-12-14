/*

 Name:          gr_user_dbmon.sql

 Purpose:       A summary of all data dictionary grants required for view/packaged creation

 Usage:         List of grants gathered from individual scripts TO one location. Not attempt TO attribute TO individual scripts - too many duplicates. Having in one place allows grants TO be given at dbmon creation. In the event of problems with individual views etc see the individual script

 DATE            Who             Description

 27th Jun 2017   Aidan Lawrence  Cloned from similar

*/

GRANT SELECT ON dba_audit_session             TO dbmon;
GRANT SELECT ON dba_audit_trail               TO dbmon;
GRANT SELECT ON dba_col_privs                 TO dbmon;
GRANT SELECT ON dba_data_files                TO dbmon;
GRANT SELECT ON dba_ind_partitions            TO dbmon;
GRANT SELECT ON dba_ind_subpartitions         TO dbmon;
GRANT SELECT ON dba_indexes                   TO dbmon;
GRANT SELECT ON dba_objects                   TO dbmon;
GRANT SELECT ON dba_profiles                  TO dbmon;
GRANT SELECT ON dba_priv_audit_opts           TO dbmon;
GRANT SELECT ON dba_roles                     TO dbmon;
GRANT SELECT ON dba_role_privs                TO dbmon;
GRANT SELECT ON dba_scheduler_jobs            TO dbmon;
GRANT SELECT ON dba_scheduler_schedules       TO dbmon;
GRANT SELECT ON dba_scheduler_job_run_details TO dbmon;
GRANT SELECT ON dba_segments                  TO dbmon;
GRANT SELECT ON dba_stmt_audit_opts           TO dbmon;
GRANT SELECT ON dba_sys_privs                 TO dbmon;
GRANT SELECT ON dba_tables                    TO dbmon;
GRANT SELECT ON dba_tab_partitions            TO dbmon;
GRANT SELECT ON dba_tab_subpartitions         TO dbmon;
GRANT SELECT ON dba_tab_privs                 TO dbmon;
GRANT SELECT ON dba_tablespaces               TO dbmon;
GRANT SELECT ON dba_temp_files                TO dbmon;
GRANT SELECT ON dba_undo_extents              TO dbmon;
GRANT SELECT ON dba_users                     TO dbmon;



GRANT SELECT ON v_$archive_dest          TO dbmon;
GRANT SELECT ON v_$archive_dest_status   TO dbmon;
GRANT SELECT ON v_$archived_log          TO dbmon;
GRANT SELECT ON v_$archive_gap           TO dbmon;
GRANT SELECT ON v_$controlfile           TO dbmon;
GRANT SELECT ON v_$database              TO dbmon;

GRANT SELECT ON v_$dataguard_config      TO dbmon;
GRANT SELECT ON v_$dataguard_stats       TO dbmon;
GRANT SELECT ON v_$dataguard_status      TO dbmon;
GRANT SELECT ON v_$filemetric            TO dbmon;
GRANT SELECT ON v_$filemetric_history    TO dbmon;
GRANT SELECT ON v_$instance              TO dbmon;
GRANT SELECT ON v_$license               TO dbmon;
GRANT SELECT ON v_$locked_object         TO dbmon;
GRANT SELECT ON v_$logfile               TO dbmon;
GRANT SELECT ON v_$log                   TO dbmon;
GRANT SELECT ON v_$log_history           TO dbmon;
GRANT SELECT ON v_$managed_standby       TO dbmon;
GRANT SELECT ON v_$open_cursor           TO dbmon;
GRANT SELECT ON v_$osstat                TO dbmon;
GRANT SELECT ON v_$parameter             TO dbmon;
GRANT SELECT ON v_$process               TO dbmon;
GRANT SELECT ON v_$recovery_area_usage   TO dbmon;
GRANT SELECT ON v_$rollstat              TO dbmon;
GRANT SELECT ON v_$segment_statistics    TO dbmon;
GRANT SELECT ON v_$session               TO dbmon;
GRANT SELECT ON v_$session_longops       TO dbmon;
GRANT SELECT ON v_$sesstat               TO dbmon;
GRANT SELECT ON v_$sqlarea               TO dbmon;
GRANT SELECT ON v_$sqltext_with_newlines TO dbmon;
GRANT SELECT ON v_$standby_log           TO dbmon;
GRANT SELECT ON v_$statname              TO dbmon;
GRANT SELECT ON v_$transaction           TO dbmon;
GRANT SELECT ON v_$undostat              TO dbmon;
GRANT SELECT ON v_$waitstat              TO dbmon;

