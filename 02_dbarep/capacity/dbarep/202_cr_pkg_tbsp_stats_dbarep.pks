CREATE OR REPLACE PACKAGE pkg_tbsp_stats_dbarep as
/*

 Name:          cr_pkg_tbsp_stats_dbarep.pks

 Purpose:       PL/SQL Package pkg_tbsp_stats_dbarep
 
 Usage:			Centralized capacity planning
 
 				Functional code is in individual packages. This is the core run code

                
 Date            Who             Description

 15th Jul 2013	 Aidan Lawrence  Cloned from similar
  5th Apr 2016   Aidan Lawrence  Cleaned up dbarep version 
 28th Jun 2017   Aidan Lawrence  Validated pre git  
 
*/

--
-- Package Constants
-- 

  c_package_name               VARCHAR2(30) := 'pkg_tbsp_stats_dbarep';
  c_tbsp_stats_purge_day       CONSTANT CHAR(3)      := 'Sun';
  c_tbsp_stats_purge_period    CONSTANT NUMBER(3)    := 31;
  
 
--
-- Modules
--

  PROCEDURE  pop_tbsp_stats_db  (
								db_name_in         IN dbarep_roadmap.db_name%TYPE
							  , monitor_db_link_in IN dbarep_roadmap.monitor_db_link%TYPE
							  , run_date_in        IN tbsp_stats.generated_date%TYPE
							 );
							 
  PROCEDURE  pop_tbsp_stats_all; 
  
END pkg_tbsp_stats_dbarep;