CREATE OR REPLACE package pkg_audit_stats_target 
AS
/*

 Name:          cr_pkg_audit_stats_target.pks

 Purpose:       PL/SQL Package pkg_audit_stats
 
 Usage:			Centralized Auditing Measurement
 
 				Functional code is in individual packages. This is the core run code
				
                
 Date            Who             Description

 28th Jun 2017   Aidan Lawrence  Validated for git 
 
*/

--
-- Package Constants
-- 

  c_package_name                CONSTANT varchar2(30) := 'pkg_audit_stats_target';
  c_audit_capture_period        NUMBER                := 1;  -- No. of days before sysdate to capture 
  c_sys_aud_dollar_retention    NUMBER                := 7;   -- Days 'live' audit data to retain 
  c_audit_trail_stats_retention NUMBER                := 90;  -- Days captured audit_trail_stats to retain 

 
--
-- Modules
--

  PROCEDURE  pop_audit_trail_stats_target;
  PROCEDURE  purge_db_audit_trail;
  PROCEDURE  run_daily_audit;
  
 
END pkg_audit_stats_target;
/

SHOW ERRORS



