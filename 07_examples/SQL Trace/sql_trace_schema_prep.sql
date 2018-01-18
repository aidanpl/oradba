/*

 Name:           sql_trace_schema_prep.sql

 Contents:       Template for setting up sql trace 

 Usage:			 Note user requires plustrace role, needs generating by DBA from $ORACLE_HOME/sqlplus/admin/plustrce.sql then 
				 
				 GRANT plustrace TO dime;
				 GRANT execute ON DBMS_SESSION to dime;
				 GRANT ALTER SESSION to dime;
			

 Date            Who             Description

 16th Jan 2018   Aidan Lawrence  Cleaned up notes for git 

*/

/*

Preparation - once per schema 

*/

--
-- 1) As a DBA create the plustrace role - script provided under $ORACLE_HOME/sqlplus/admin 

-- sqlplus '/ as sysdba' 
connect / as sysdba 
@$ORACLE_HOME/sqlplus/admin/plustrce.sql

-- 2) Per schema - example HR

GRANT plustrace TO hr;
GRANT EXECUTE ON DBMS_SESSION TO hr;
GRANT ALTER SESSION TO hr;

