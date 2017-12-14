/*

 Name:          run_pkg_tbsp_stats_target.sql

 Purpose:       Test pop_tbsp_stats_target and pop_file_highwatermark_target

 Comments:

  Date            Who             Description

  16th Jul 2013   Aidan Lawrence  Cloned from similar
   8th Jun 2017   Aidan Lawrence  Validated pre git  

*/

BEGIN
  pkg_tbsp_stats_target.pop_tbsp_stats_target();
END;
/

COMMIT
/

BEGIN
  pkg_tbsp_stats_target.pop_file_highwatermark_target();
END;
/

COMMIT
/

