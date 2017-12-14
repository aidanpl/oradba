/*

 Name:          run_pkg_job_results_target.sql

 Purpose:       Test pop_job_results_target and pop_file_highwatermark_target

 Comments:

  Date            Who             Description

  16th Jul 2013   Aidan Lawrence  Cloned from similar
   8th Jun 2017   Aidan Lawrence  Validated pre git  

*/

BEGIN
  pkg_job_results_target.pop_job_results_target();
END;
/

COMMIT
/

