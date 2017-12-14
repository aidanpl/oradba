/*

 Name:          1_dbmon_view_grants.sql

 Purpose:       Grants across all views consolidated TO single script for user creation

                Search individual view scripts as desired TO see where views are used

 Usage:         Change dbmon TO your preferred monitoring name

 Next Steps:

 Date            Who             Description

  8th Jun 2017   Aidan Lawrence  Cleaned up for git

*/

--audit_vw.sql
GRANT SELECT ON dba_stmt_audit_opts TO dbmon;
GRANT SELECT ON dba_priv_audit_opts TO dbmon;
GRANT SELECT ON dba_audit_object    TO dbmon;
GRANT SELECT ON dba_audit_session   TO dbmon;
GRANT SELECT ON dba_audit_trail     TO dbmon;
GRANT SELECT ON v_$license          TO dbmon;

--
--instance_ck_vw.sql
GRANT SELECT ON v_$instance     TO dbmon;
GRANT SELECT ON v_$database     TO dbmon;
GRANT SELECT ON v_$license      TO dbmon;
GRANT SELECT ON v_$rowcache     TO dbmon;
GRANT SELECT ON v_$latch        TO dbmon;
GRANT SELECT ON v_$librarycache TO dbmon;
GRANT SELECT ON v_$session      TO dbmon;
GRANT SELECT ON v_$sysstat      TO dbmon;
GRANT SELECT ON v_$sesstat      TO dbmon;
GRANT SELECT ON v_$statname     TO dbmon;
GRANT SELECT ON v_$sort_segment TO dbmon;

--
-- dataguard_view_vw.sql
GRANT SELECT ON v_$dataguard_config    TO dbmon;
GRANT SELECT ON v_$dataguard_stats     TO dbmon;
GRANT SELECT ON v_$dataguard_status    TO dbmon;
GRANT SELECT ON v_$database            TO dbmon;
GRANT SELECT ON v_$managed_standby     TO dbmon;
GRANT SELECT ON v_$archive_dest        TO dbmon;
GRANT SELECT ON v_$archive_dest_status TO dbmon;
GRANT SELECT ON v_$archived_log        TO dbmon;
GRANT SELECT ON v_$archive_gap         TO dbmon;
GRANT SELECT ON v_$logfile             TO dbmon;
GRANT SELECT ON v_$log                 TO dbmon;
GRANT SELECT ON v_$log_history         TO dbmon;
GRANT SELECT ON v_$standby_log         TO dbmon;

--
-- highsql_views_vw.sql
GRANT SELECT ON v_$sqlarea TO dbmon;

-- highio_views_vw.sql -- Note dependent on installation of PERFSTAT

GRANT SELECT ON v_$segment_statistics              TO dbmon;
GRANT SELECT ON v_$filemetric                      TO dbmon;
GRANT SELECT ON v_$filemetric_history              TO dbmon;
GRANT SELECT ON v_$osstat                          TO dbmon;
GRANT SELECT ON perfstat.stats$statspack_parameter TO dbmon;

--
-- scheduler_views_vw.sql
GRANT SELECT ON dba_scheduler_jobs            TO dbmon;
GRANT SELECT ON dba_scheduler_schedules       TO dbmon;
GRANT SELECT ON dba_scheduler_job_run_details TO dbmon;

-- undo_ck_vw.sql
GRANT SELECT ON v_$parameter TO dbmon;
GRANT SELECT ON v_$undostat TO dbmon;
GRANT SELECT ON v_$rollstat TO dbmon;
GRANT SELECT ON v_$waitstat TO dbmon;
GRANT SELECT ON dba_undo_extents TO dbmon;
GRANT SELECT ON dba_tablespaces TO dbmon;
GRANT SELECT ON dba_data_files TO dbmon;

--phys_view_vw.sql
GRANT SELECT ON dba_data_files TO dbmon;
GRANT SELECT ON dba_temp_files TO dbmon;
GRANT SELECT ON v_$controlfile TO dbmon;
GRANT SELECT ON v_$logfile TO dbmon;
GRANT SELECT ON v_$parameter TO dbmon;

--seg_view_vw.sql
GRANT SELECT ON dba_tables            TO dbmon;
GRANT SELECT ON dba_indexes           TO dbmon;
GRANT SELECT ON dba_tab_partitions    TO dbmon;
GRANT SELECT ON dba_tab_subpartitions TO dbmon;
GRANT SELECT ON dba_ind_partitions    TO dbmon;
GRANT SELECT ON dba_ind_subpartitions TO dbmon;
GRANT SELECT ON dba_segments          TO dbmon;
GRANT SELECT ON dba_lobs              TO dbmon;
GRANT SELECT ON dba_lob_partitions    TO dbmon;
GRANT SELECT ON dba_tablespaces       TO dbmon;

--invalid_views_vw.sql
GRANT SELECT ON dba_objects    TO dbmon;
GRANT SELECT ON dba_data_files TO dbmon;
GRANT SELECT ON v_$datafile    TO dbmon;
GRANT SELECT ON v_$logfile     TO dbmon;

--lock_view_vw.sql
GRANT SELECT ON dba_objects      TO dbmon;
GRANT SELECT ON v_$locked_object TO dbmon;
GRANT SELECT ON v_$session       TO dbmon;
GRANT SELECT ON v_$transaction   TO dbmon;

--mview_vw.sql
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

--obj_view_vw.sql
GRANT SELECT ON dba_objects TO dbmon;
GRANT SELECT ON dba_tables TO dbmon;
GRANT SELECT ON dba_views TO dbmon;
GRANT SELECT ON dba_sequences TO dbmon;
GRANT SELECT ON dba_dependencies TO dbmon;

--redo_ck_vw.sql
GRANT SELECT ON v_$log TO dbmon;
GRANT SELECT ON v_$log_history TO dbmon;
GRANT SELECT ON v_$archive_dest TO dbmon;
GRANT SELECT ON v_$archived_log TO dbmon;
GRANT SELECT ON v_$recovery_area_usage TO dbmon;

--report_tune_header_vw.sql
GRANT SELECT ON v_$database    TO dbmon;

--security_vw.sql
GRANT SELECT ON dba_users TO dbmon;
GRANT SELECT ON dba_profiles TO dbmon;
GRANT SELECT ON dba_roles TO dbmon;
GRANT SELECT ON dba_role_privs TO dbmon;
GRANT SELECT ON dba_sys_privs TO dbmon;
GRANT SELECT ON dba_tab_privs TO dbmon;
GRANT SELECT ON dba_col_privs TO dbmon;

--stats_vw.sql
GRANT SELECT ON dba_tables             TO dbmon;
GRANT SELECT ON dba_optstat_operations TO dbmon;
GRANT SELECT ON dba_tab_stats_history  TO dbmon;


--transaction_view_vw.sql
GRANT SELECT ON v_$session         TO dbmon;
GRANT SELECT ON v_$session_longops TO dbmon;
GRANT SELECT ON v_$process         TO dbmon;
GRANT SELECT ON v_$transaction     TO dbmon;

--user_account_views_vw.sql
GRANT SELECT ON dba_users TO dbmon;

--cursor_tune_vw.sql  -- Note dependent on dbmon.vw_parameter
GRANT SELECT ON v_$statname              TO dbmon;
GRANT SELECT ON v_$sesstat               TO dbmon;
GRANT SELECT ON v_$parameter             TO dbmon;
GRANT SELECT ON v_$open_cursor           TO dbmon;
GRANT SELECT ON v_$sqltext_with_newlines TO dbmon;

--sga_pga_vw.sql
GRANT SELECT ON v_$sgainfo                TO dbmon;
GRANT SELECT ON v_$sga_dynamic_components TO dbmon;
GRANT SELECT ON v_$sga_resize_ops         TO dbmon;
GRANT SELECT ON v_$sga_target_advice      TO dbmon;
GRANT SELECT ON v_$pgastat                TO dbmon;
GRANT SELECT ON v_$pga_target_advice      TO dbmon;
