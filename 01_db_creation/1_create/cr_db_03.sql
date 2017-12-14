/* 

 Name:          cr_db_03.sql

 Purpose:       Common post db creation options
 
 Usage:			Part of database creation. Common scripts

 Date            Who             Description

 15th Nov 2013   Aidan Lawrence  Cloned from similar
  8th Jun 2017   Aidan Lawrence  Validated pre git  

*/

spool cr_db_03.lst
set echo on
--
-- Change default profile to stop pw expiring
--
alter profile default limit
password_life_time unlimited;

--
-- And now reset common passwords
alter user sys    identified by dbarep_sys;
alter user system identified by dbarep_system;
alter user dbsnmp identified by dbarep_dbsnmp;

--
-- Run the pupbld for system to stop warning messages whenever running sql*plus as anything other than system or sysdba

connect system/dbarep_system
@$ORACLE_HOME/sqlplus/admin/pupbld.sql

spool off