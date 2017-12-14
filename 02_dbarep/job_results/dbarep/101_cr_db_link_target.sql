/*

 Name:          cr_db_link_target.sql

 Purpose:       Example database link creation and update of DBA_ROADMAP
 
 Usage:         Manually edit with connection string and database name as required 

 Comments:

  Date            Who             Description

   8th Jun 2017   Aidan Lawrence  Validated pre git  

*/

--
-- Create and test database link for example database apl11 

CREATE DATABASE LINK dbmon_apl11 
CONNECT TO dbmon IDENTIFIED BY <pw>
USING 'apl11';


SELECT name
from v$database@dbmon_apl11;   
   
--
-- Update dba_roadmap 
-- 

UPDATE dbarep_roadmap
SET 
  monitor_capacity_include = 'Y'
, monitor_db_link = 'APL11_DBMON'
WHERE db_name = 'APL11';
   
COMMIT;