/* 

 Name:          cr_tbs_01.sql

 Purpose:       Standard extra tablespaces
 
 Date            Who             Description

 15th Nov 2013   Aidan Lawrence  Cloned from similar
  8th Jun 2017   Aidan Lawrence  Validated pre git  
*/


spool 05_cr_tbs_01.lst
set echo on
set time on
set timing on

CREATE TABLESPACE TOOLS DATAFILE 
    '/data/oradata/dbarep/tools_01.dbf' SIZE 250M AUTOEXTEND ON NEXT 250M MAXSIZE 16G
    ;	
	
CREATE TABLESPACE USERS DATAFILE 
    '/data/oradata/dbarep/users_01.dbf' SIZE 250M AUTOEXTEND ON NEXT 250M MAXSIZE 16G
    ;		

spool off
