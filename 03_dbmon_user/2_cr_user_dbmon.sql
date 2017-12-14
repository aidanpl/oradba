/*

 Name:          cr_user_dbmon.sql

 Purpose:       DBA type monitoring user creation with typical starting privileges.
				Deliberately NOT give DBA role
 
 Usage:         User name is arbitrary - important to create unique passwords if monitoring multiple databases to reduce risk of connecting to the 'wrong one'

 DATE            Who             Description

 14th Jun 2013   Aidan Lawrence  Cloned from similar
  8th Jun 2017   Aidan Lawrence  Validated pre git 

*/

--
-- Assumption that tablespace dbmon has been precreated 

CREATE USER dbmon
IDENTIFIED BY dbmon_<pw>
DEFAULT TABLESPACE dbmon
TEMPORARY TABLESPACE TEMP;

--
-- Common roles for all schemas - specifically NOT DBA
GRANT CONNECT                    TO dbmon;
GRANT RESOURCE                   TO dbmon;
GRANT UNLIMITED TABLESPACE       TO dbmon;

--
-- Specific roles for DBA monitoring, datapump, DBMS_SCHEDULER etc.

GRANT SELECT_CATALOG_ROLE        TO dbmon;
GRANT EXECUTE_CATALOG_ROLE       TO dbmon;
GRANT DATAPUMP_EXP_FULL_DATABASE TO dbmon;
GRANT DATAPUMP_IMP_FULL_DATABASE TO dbmon;
GRANT GATHER_SYSTEM_STATISTICS   TO dbmon;
GRANT SCHEDULER_ADMIN            TO dbmon;

