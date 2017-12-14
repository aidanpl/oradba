/*

 Name:          cr_tbs_dbmon.sql
 
 Purpose:       Define tablespaces for dbmon user
 
 Usage:			Tablespace creation. Adjust depending on database/file location as required
                
 Date            Who             Description

 4th Mar 2013	 Aidan Lawrence  Cloned from similar
 8th Jun 2017    Aidan Lawrence  Validate pre git 
 
*/

CREATE TABLESPACE dbmon DATAFILE 
  '/data/oradata/dbarep/dbmon_01.dbf' SIZE 1G AUTOEXTEND ON NEXT 100M MAXSIZE 8G
;

/*
--
-- Windows equivalent
CREATE TABLESPACE dbmon DATAFILE 
  'c:\oracle\oradata\test\dbmon_01.dbf' SIZE 200M AUTOEXTEND ON NEXT 100M MAXSIZE 8G
;

*/

