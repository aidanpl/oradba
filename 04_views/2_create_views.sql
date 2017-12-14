/*

 Name:          0_create_views.sql

 Purpose:       Simple installation script for all scripts in this directory 

 Usage:         Commonly run under the DBMON user 

 Next Steps:

 Date            Who             Description

  8th Jun 2017   Aidan Lawrence  Cleaned up for git 

*/

-- Pre-requisite - create the 'ignore_views' - contains schemas to ignore during checks 
-- 

@ignore_views.sql 

--
-- Common views  

@audit_vw.sql
@dataguard_view_vw.sql
@highsql_views_vw.sql
@instance_ck_vw.sql
@invalid_views_vw.sql
@lob_view_vw.sql
@lock_view_vw.sql
@mview_vw.sql
@obj_view_vw.sql
@phys_view_vw.sql
@redo_ck_vw.sql
@report_tune_header_vw.sql
@scheduler_views_vw.sql
@schema_vw.sql
@security_vw.sql
@seg_view_vw.sql
@sga_pga_vw.sql
@stats_vw.sql
@transaction_view_vw.sql
@undo_ck_vw.sql
@user_account_views_vw.sql

 -- Note dependent on installation of PERFSTAT 
@highio_views_vw.sql
-- Note dependent on DBMON.vw_parameter
@cursor_tune_vw.sql    

