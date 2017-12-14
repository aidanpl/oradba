/*

 Name:          purge_dba_recyclebin_proc.sql

 Purpose:       Execute existing job 
 
 Usage:         Just run it :-)
 
 Date            Who             Description

 31st Aug 2017   Aidan Lawrence  Validated for git 
*/

CREATE OR REPLACE PROCEDURE purge_dba_recyclebin AS
BEGIN 
  EXECUTE IMMEDIATE 'PURGE DBA_RECYCLEBIN'; 
END;
/