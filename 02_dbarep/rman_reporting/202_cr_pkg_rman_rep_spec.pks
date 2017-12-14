CREATE OR REPLACE PACKAGE pkg_rman_rep AS
/*

 Name:          cr_pkg_rman_rep_spec.pks

 Purpose:       PL/SQL Package pkg_rman_rep
 
 Usage:         General DBA reporting package
 
 Requirements:  Executing schema must have ACL access to mail:
 
 GRANT execute on UTL_MAIL to rmancat;
 
 
  Date           Who             Description

 23rd Feb 2017   Aidan Lawrence  RMAN reporting split of from general DBA to allow to run directly within RMAN Catalog schema
 15th Jun 1017   Aidan Lawrence  Validated for git   
 
*/

--
-- Package Constants
-- 

  c_package_name   			 CONSTANT VARCHAR2(30) := 'pkg_rman_rep';
 
--
-- Modules
--  
  PROCEDURE rman_rep_rman_report; 
  
END pkg_rman_rep;