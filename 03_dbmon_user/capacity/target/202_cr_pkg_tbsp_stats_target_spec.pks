CREATE OR REPLACE package pkg_tbsp_stats_target 
as
/*

 Name:          cr_pkg_tbsp_stats_target.pks

 Purpose:       PL/SQL Package pkg_tbsp_stats
 
 Usage:			Centralized capacity planning
                
 Date            Who             Description

 15th Jul 2013	 Aidan Lawrence  Cloned from similar
 20th Dec 2014   Aidan Lawrence  Added code for datafile_highwatermark 
 26th Jun 2015   Aidan Lawrence  Added constants for purge procedures
  8th Jun 2017   Aidan Lawrence  Validated pre git  
*/

--
-- Package Constants
-- 

  c_package_name               CONSTANT VARCHAR2(30) := 'pkg_tbsp_stats_target';
  c_tbsp_stats_purge_day       CONSTANT CHAR(3)      := 'Sun';
  c_tbsp_stats_purge_period    CONSTANT NUMBER(3)    := 31;
  c_highwatermark_purge_period CONSTANT NUMBER(3)    := 31;
  
 
--
-- Modules
--

  PROCEDURE  pop_tbsp_stats_target;
  PROCEDURE  pop_file_highwatermark_target;
 
END pkg_tbsp_stats_target;
/

SHOW ERRORS



