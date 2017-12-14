/*

 Name:          run_pop_job_results_all.sql

 Purpose:       Test pop_job_results_all

 Comments:

  Date            Who             Description

  16th Jul 2013   Aidan Lawrence  Cloned from similar
   8th Jun 2017   Aidan Lawrence  Validated pre git  

*/

BEGIN
  pkg_job_results_dbarep.pop_job_results_all();
END;
/

COMMIT
/
