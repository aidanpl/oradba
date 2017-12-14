/*

 Name:          ignore_views.sql

 Purpose:       Lists of things to ignore for reporting purposes - e.g. system level schemas.
                Can be configured for individual applications 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 Implementation Typically run under 'dbmon' type user. Initially cloned from seg_all_ck etc. etc. 
 
 Next Steps:

 Date            Who             Description

 4th May 2016    Aidan Lawrence  Cloned from similar
 12th May 2017   Aidan Lawrence  Added in ignore_roles and ignore_privs for security_checks
 28th Jun 2017   Aidan Lawrence  Validated for git 

*/

CREATE OR REPLACE VIEW ignore_1_schemas
--
-- List of schemas to ignore - can be included as subquery in other views 
-- Note use of the Quote syntax Q'#......#' to allow use of single quotes in string 
-- 
-- To use in a calling view make use of REGEXP_LIKE to compare this list with a column 
-- e.g. 
-- AND NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) -- where  owner is the column to be searched
AS 
SELECT 
Q'#
 'SYS'
,'SYSTEM'
,'CTXSYS'
,'DBSNMP'
,'GSMADMIN_INTERNAL'
,'MDSYS'
,'ODM'
,'ODM_MTR'
,'OE'
,'OLAPSYS'
,'ORDSYS'
,'OUTLN'
,'ORDPLUGINS'
,'PUBLIC'
,'QS'
,'QS_ADM'
,'QS_CBADM'
,'QS_CS'
,'QS_ES'
,'QS_OS'
,'QS_WS'
,'SH'
,'SYSMAN'
,'WKSYS'
,'WMSYS'
,'XDB'
,'APPQOSSYS'
,'EXFSYS'
,'ORDDATA'
,'APEX_050000'#' 
as ignore_schemas
FROM dual;

CREATE OR REPLACE VIEW ignore_2_roles
--
-- List of schemas to ignore - can be included as subquery in other views 
-- Note use of the Quote syntax Q'#......#' to allow use of single quotes in string 
-- 
-- To use in a calling view make use of REGEXP_LIKE to compare this list with a column 
-- e.g. 
-- AND NOT REGEXP_LIKE((SELECT ignore_roles FROM ignore_2_roles),role) -- where role is the column to be searched
AS 
SELECT 
Q'#
 'CONNECT'
,'DBA'
,'RESOURCE'
,'DATAPUMP_IMP_FULL_DATABASE'
,'DATAPUMP_EXP_FULL_DATABASE'
,'IMP_FULL_DATABASE'
,'EXP_FULL_DATABASE'
,'OEM_ADVISOR'
,'OEM_MONITOR'
,'RECOVERY_CATALOG_OWNER'
,'SNMPAGENT'
,'ADM_PARALLEL_EXECUTE_TASK'#' 
as ignore_roles
FROM dual;

CREATE OR REPLACE VIEW ignore_3_privs
--
-- List of privilegs to ignore - can be included as subquery in other views 
-- Note use of the Quote syntax Q'#......#' to allow use of single quotes in string 
-- 
-- To use in a calling view make use of REGEXP_LIKE to compare this list with a column 
-- e.g. 
-- AND NOT REGEXP_LIKE((SELECT ignore_privs FROM ignore_3_privs),privilege)  -- where grantee is the column to be searched
AS 
SELECT 
Q'#
 'CREATE SESSION'#' 
as ignore_privs
FROM dual;


