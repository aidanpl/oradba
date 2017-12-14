/*

 Name:          08_security_vw.sql

 Purpose:       Security views 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 Required direct Grants for view creations
 
 GRANT SELECT ON dba_users TO dbmon;
 GRANT SELECT ON dba_profiles TO dbmon;
 GRANT SELECT ON dba_roles TO dbmon;
 GRANT SELECT ON dba_role_privs TO dbmon;
 GRANT SELECT ON dba_sys_privs TO dbmon;
 GRANT SELECT ON dba_tab_privs TO dbmon;
 GRANT SELECT ON dba_col_privs TO dbmon;
  
 Date            Who             Description

 12th Apr 2017   Aidan Lawrence  Cloned from similar
 27th Jun 2017   Aidan Lawrence  Validated pre git publication        

*/

CREATE OR REPLACE  VIEW sec_1_users AS 
--
-- Basic user info
--
SELECT 
  username
, to_char(created,'DD-MON-YYYY')  AS created
, account_status
, to_char(expiry_date,'DD-MON-YYYY') AS expiry_date
, to_char(lock_date,'DD-MON-YYYY') AS lock_date
, profile
, default_tablespace
, temporary_tablespace
from dba_users
order by username
/

CREATE OR REPLACE  VIEW sec_2_profiles AS 
--
-- Basic profile info
--
SELECT 
  profile
, resource_name
, limit
from dba_profiles
WHERE profile <> 'DEFAULT'
AND   limit   <> 'UNLIMITED'
order by profile
, resource_name
/

CREATE OR REPLACE  VIEW sec_3_roles AS 
--
-- Basic role info
--
SELECT role
, password_required 
from dba_roles
WHERE NOT REGEXP_LIKE((SELECT ignore_roles FROM ignore_2_roles),role) 
order by role
/


CREATE OR REPLACE  VIEW sec_4_granted_dba_type_roles AS 
--
-- Granted DBA roles - hardcoded list for now 
--
SELECT 
  grantee
, granted_role
, admin_option
, default_role
FROM dba_role_privs
WHERE granted_role in ('DBA','RESOURCE')
ORDER BY grantee,granted_role
/

CREATE OR REPLACE  VIEW  sec_5_granted_roles  AS
--
-- Granted roles 
--
SELECT 
  grantee
, granted_role
, admin_option
, default_role
FROM dba_role_privs
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),grantee) 
AND NOT REGEXP_LIKE((SELECT ignore_roles FROM ignore_2_roles),grantee) 
AND NOT REGEXP_LIKE((SELECT ignore_roles FROM ignore_2_roles),granted_role) 
ORDER BY grantee,granted_role
/


CREATE OR REPLACE  VIEW  sec_6_granted_sys_privs AS 
--
-- Granted system privileges 
--
SELECT 
  grantee
, privilege
FROM dba_sys_privs
WHERE  NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),grantee) 
AND NOT REGEXP_LIKE((SELECT ignore_roles FROM ignore_2_roles),grantee) 
AND NOT REGEXP_LIKE((SELECT ignore_privs FROM ignore_3_privs),privilege) 
ORDER BY grantee
, privilege
/

CREATE OR REPLACE  VIEW  sec_7_granted_tab_privs AS 
--
-- Granted table privileges 
--
SELECT 
  owner as grantor 
, table_name as object_name 
, privilege
, grantee
FROM dba_tab_privs
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) 
AND NOT REGEXP_LIKE((SELECT ignore_roles FROM ignore_2_roles),owner) 
AND NOT REGEXP_LIKE((SELECT ignore_roles FROM ignore_2_roles),grantee) 
ORDER BY owner
, table_name
, privilege
/

CREATE OR REPLACE  VIEW  sec_8_granted_col_privs AS 
--
-- Granted table privileges 
--
SELECT 
  owner as grantor 
, table_name as object_name 
, column_name
, privilege
, grantee
FROM dba_col_privs
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),owner) 
AND NOT REGEXP_LIKE((SELECT ignore_roles FROM ignore_2_roles),owner) 
AND NOT REGEXP_LIKE((SELECT ignore_roles FROM ignore_2_roles),grantee) 
ORDER BY owner
, table_name
, column_name
, privilege
/

