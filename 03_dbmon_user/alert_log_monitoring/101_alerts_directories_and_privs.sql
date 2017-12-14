/*

 Name:          alerts_directories_and_privs.sql

 Purpose:       To locate the text version of the alert log
 
 Usage:         Note the hardcoded location of the alert log - change each time for the specific database of interest.

				Execute this as SYSDBA
  
 Date            Who             Description

 1st Aug 2017   Aidan Lawrence   Validated pre git publication 

*/

--
-- Point to text version of the alert log 
--
CREATE OR REPLACE DIRECTORY alerts AS 
'/opt/oracle/diag/rdbms/dbarep/dbarep/trace';

GRANT READ, WRITE ON DIRECTORY alerts TO dbmon;

--
-- Specific grant to DBMS_SYSTEM to allow this to be referenced in PL/SQL

GRANT EXECUTE ON sys.dbms_system TO dbmon;
