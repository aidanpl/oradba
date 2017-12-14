/*

 Name:          run_pop_tbsp_stats_all.sql

 Purpose:       Test pop_tbsp_stats_all

 Comments:

  Date            Who             Description

  16th Jul 2013   Aidan Lawrence  Cloned from similar
   8th Jun 2017   Aidan Lawrence  Validated pre git  

*/

BEGIN
  pkg_tbsp_stats_dbarep.pop_tbsp_stats_all();
END;
/

COMMIT
/
