CREATE OR REPLACE PACKAGE pkg_job_results_dbarep as
/*

 Name:          cr_pkg_job_results_dbarep_spec.pks

 Purpose:       PL/SQL Package pkg_job_results_dbarep
 
 Usage:			Centralized job results monitoring
                 
 Date            Who             Description

 15th Jul 2013	 Aidan Lawrence  Cloned from similar
  8th Jul 2017   Aidan Lawrence  Cleaned up from similar 
 
*/

--
-- Package Constants
-- 

  c_package_name   varchar2(30) := 'pkg_job_results_dbarep';
  --c_job_results_purge_day       CONSTANT CHAR(3)      := 'Sun';
  --c_job_results_purge_period    CONSTANT NUMBER(3)    := 31;
  
--
-- Pull target dbms_schedule data into local table
--

PROCEDURE pop_job_results_db  (
								db_name_in         IN dbarep_roadmap.db_name%TYPE
							  , monitor_db_link_in IN dbarep_roadmap.monitor_db_link%TYPE
							 );
							 							 
PROCEDURE  pop_job_results_all;   
							 
 
END pkg_job_results_dbarep;
/

