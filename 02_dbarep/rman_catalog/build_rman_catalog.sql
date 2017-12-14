/*

 Name:          build_rman_catalog.sql

 Purpose:       Create RMAN catalog schema and privileges
 
 Usage:			RMAN Catalog 
                
 Date            Who             Description

 11th Aug 2017   Aidan Lawrence  revalidated for git 
 
*/


spool build_rman_catalog.lst 
set echo on

--
-- RMAN Recovery Catalog 
--

CREATE USER rmancat
IDENTIFIED BY dbarep_cat
DEFAULT TABLESPACE rmancat
TEMPORARY TABLESPACE TEMP;

GRANT CONNECT, RESOURCE TO rmancat;
GRANT CREATE ANY DIRECTORY TO rmancat;
GRANT CREATE VIEW TO rmancat;
GRANT CREATE SYNONYM TO rmancat;

--This system priv allows  the grantee to create, alter or drop windows, job classes, and windows groups, as well as manage the cheduler attributes and purge the Scheduler log
GRANT MANAGE SCHEDULER TO rmancat; 

-- This role provides a lot of power for a regular user, allowing the grantee to run any code. If this happens to be a regular user who will launch its own jobs, then it should be granted the CREATE JOB privilege. This allows the grantee to create jobs, schedules, and programs in its own schema.
GRANT SCHEDULER_ADMIN TO rmancat;

GRANT recovery_catalog_owner to rmancat;

PROMPT
prompt TO create the catalog:
prompt
prompt 1) Fire up an rman session as rmancat
prompt 2) Execute rman>CREATE CATALOG TABLESPACE rmancat







