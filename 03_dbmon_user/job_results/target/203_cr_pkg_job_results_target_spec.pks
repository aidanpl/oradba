CREATE OR REPLACE PACKAGE pkg_job_results_target 
AS
/*

 Name:          cr_pkg_job_results_target_spec.pks

 Purpose:       PL/SQL Package pkg_job_results
 
 Usage:			Centralized DBMS_SCHEDULE monitoring
                
 Date            Who             Description

 15th Jul 2013	 Aidan Lawrence  Cloned from similar
 10th Oct 2017   Aidan Lawrence  Validated pre git  
*/

--
-- Package Constants
-- 

  c_package_name               CONSTANT VARCHAR2(30) := 'pkg_job_results_target';
  c_job_results_gather_period  CONSTANT NUMBER(3)    := 3; -- How many days worth of data to regather
  c_job_results_purge_period   CONSTANT NUMBER(3)    := 31; -- How many days worth of data to keep
  
 
--
-- Modules
--

  PROCEDURE  pop_job_results_target;
 
END pkg_job_results_target;
/

