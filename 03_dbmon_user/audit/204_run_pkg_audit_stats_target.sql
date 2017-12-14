/*

 Name:          run_pkg_audit_stats_target.sql

 Purpose:       Test pop_audit_stats_target or run_daily_audit

 Comments:

  Date            Who             Description

  16th Jul 2013   Aidan Lawrence  Cloned from similar
  28th Jun 2017   Aidan Lawrence  Validated for git 

*/

BEGIN
  pkg_audit_stats_target.run_daily_audit();
END;
/

COMMIT
/

