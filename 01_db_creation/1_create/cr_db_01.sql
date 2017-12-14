/* 

 Name:          cr_db_01.sql

 Purpose:       Example DB creation script 
 
 Usage: To check an existing characterset try the following against a source database
 
SQL> col parameter format a20
SQL> col value format a20
SQL> l
  1  select parameter, value
  2  from v$nls_parameters
  3* where parameter = 'NLS_CHARACTERSET'
SQL> /

PARAMETER	     VALUE
-------------------- --------------------
NLS_CHARACTERSET     AL32UTF8

 Date            Who             Description

 1st Nov 2004	 Aidan Lawrence  Updated for Oracle 10G
 20th Jan 2012   Aidan Lawrence  Updated for Oracle 11G
  8th Jun 2017   Aidan Lawrence  Validated pre git 

*/

spool cr_db_01.lst

--
-- Passwords are included for the purpose of creation - it is expected these will be amended post database creation

CREATE DATABASE   dbarep
    USER sys 	IDENTIFIED BY dbarep_sys
    USER system IDENTIFIED BY dbarep_system
    MAXDATAFILES  1024
    MAXINSTANCES  1
    MAXLOGFILES   16 
    MAXLOGMEMBERS 2
    MAXLOGHISTORY 100
    CHARACTER SET AL32UTF8 -- See comments above on characterset
    DATAFILE
                 '/data/oradata/dbarep/system_01.dbf'  size 1G
                 AUTOEXTEND ON NEXT 50M MAXSIZE 8G
    SYSAUX DATAFILE
                 '/data/oradata/dbarep/sysaux_01.dbf'  size 500M
                 AUTOEXTEND ON NEXT 50M MAXSIZE 8G
    UNDO TABLESPACE undo1 
         DATAFILE '/data/oradata/dbarep/undo1_01.dbf'  size 500M
                 AUTOEXTEND ON NEXT 50M MAXSIZE 8G
    DEFAULT TEMPORARY TABLESPACE temp
         TEMPFILE '/data/oradata/dbarep/temp_01.dbf'  size 500M
                 AUTOEXTEND ON NEXT 50M MAXSIZE 8G
    LOGFILE
        GROUP 1 ( '/data/oradata/dbarep/log1a.dbf' 
		        , '/data/oradata/dbarep/log1b.dbf' ) size 100M ,
        GROUP 2 ( '/data/oradata/dbarep/log2a.dbf' 
		        , '/data/oradata/dbarep/log2b.dbf' ) size 100M ,
        GROUP 3 ( '/data/oradata/dbarep/log3a.dbf' 
		        , '/data/oradata/dbarep/log3b.dbf' ) size 100M 				
/

spool off
