/* 

 Name:          cr_db_02.sql

 Purpose:       Execute standard post-db creation scripts
 
 Date            Who             Description

  1st Nov 2004	 Aidan Lawrence  Initial build 
  8th Jun 2017   Aidan Lawrence  Validated pre git 

*/

spool cr_db_02.lst
set time on 

--
-- Build the core data dictionary objects
-- All database need catalog and catproc
-- Some may need others. See Oracle documentation 'Reference' Manual for possible others 
--

@$ORACLE_HOME/rdbms/admin/catalog.sql
@$ORACLE_HOME/rdbms/admin/catproc.sql

spool off
