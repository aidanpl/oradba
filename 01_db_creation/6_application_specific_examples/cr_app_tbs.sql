/* 

 Name:          cr_tbs_02.sql

 Purpose:       Common/Example extra tablespaces.
 
 Date            Who             Description

 15th Nov 2013   Aidan Lawrence  Cloned from similar
  8th Jun 2017   Aidan Lawrence  Validated pre git  

*/


spool cr_tbs_01.lst
set echo on
set time on
set timing on

--
-- RMAN Catalog 
	
CREATE TABLESPACE rmancat DATAFILE 
    '/data/oradata/dbarep/rmancat_01.dbf' SIZE 500M AUTOEXTEND ON NEXT 500M MAXSIZE 16G
    ;
	
--
-- General dbmon_rep 
	
CREATE TABLESPACE DBMON_REP DATAFILE 
    '/data/oradata/dbarep/dbmon_rep_01.dbf' SIZE 500M AUTOEXTEND ON NEXT 500M MAXSIZE 16G
    ;	

-- SASH Repository 

CREATE TABLESPACE SASH_REP DATAFILE 
    '/data/oradata/dbarep/sash_rep_01.dbf' SIZE 500M AUTOEXTEND ON NEXT 500M MAXSIZE 16G
    ;		
	
spool off
exit
