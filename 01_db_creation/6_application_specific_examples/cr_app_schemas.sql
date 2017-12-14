/*

 Name:          cr_app_schemas.sql

 Purpose:       Define required schemas for the application
 
 Usage:			Schema creation. For each schemas ensure that the default tablespace is set to a pre-created tablespace
                
 Date            Who             Description

 12th Dec 2013   Aidan Lawrence  Cloned from similar
 31st Aug 2017   Aidan Lawrence  Validated for git 
 
*/

spool cr_app_schemas.lst
set echo on

--
-- dbmon example
--

CREATE USER dbmon
IDENTIFIED BY dbmonrep
DEFAULT TABLESPACE dbmon
TEMPORARY TABLESPACE TEMP;

GRANT CONNECT, RESOURCE TO dbmon;
GRANT CREATE ANY DIRECTORY TO dbmon;
GRANT CREATE VIEW TO dbmon;
GRANT CREATE SYNONYM TO dbmon;

-- This role provides a lot of power for a regular user, allowing the grantee to run any code. If this happens to be a regular user who will launch its own jobs, then it should be granted the CREATE JOB privilege. This allows the grantee to create jobs, schedules, and programs in its own schema.
GRANT SCHEDULER_ADMIN TO dbmon;

--
-- apex example
--

CREATE USER apex_schema
IDENTIFIED BY apex_dbarep
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE TEMP;

GRANT CONNECT, RESOURCE TO apex_schema;
GRANT CREATE ANY DIRECTORY TO apex_schema;
GRANT CREATE VIEW TO apex_schema;
GRANT CREATE SYNONYM TO apex_schema;

-- This role provides a lot of power for a regular user, allowing the grantee to run any code. If this happens to be a regular user who will launch its own jobs, then it should be granted the CREATE JOB privilege. This allows the grantee to create jobs, schedules, and programs in its own schema.
GRANT SCHEDULER_ADMIN TO apex_schema;

spool off 