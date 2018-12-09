/*

 Name:          schema_security_comparison_ck.sql

 Purpose:       Schema specific version of security ck when comparing schema access to objects to help understand unexpected ORA-00904 type errors 

 Usage:         Note hardcoded schema, role names for comparison. Simply amend these as desired 

 Contents:      
        Roles
        Roles Privileges
        System privileges granted
        Object privileges granted
        Auditing options


 Date            Who             Description

10th Jul 2018    Aidan Lawrence  Cloned and tweaked based on security_ck

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'schema_security_comparison_ck'
--
-- Set the Spool output name as combination of script, database AND time
--

column spool_name new_value spool_name noprint;
       
SELECT '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI') 
       || '.lst' spool_name      
  FROM v$database d;
  
SELECT 'Output report name is ' 
       || '&spool_name'
  FROM dual;  

spool &spool_name

prompt 
prompt Report Details are &spool_name                     
prompt
--
-- Main report begins
--

set heading on
set feedback on

--
-- Define schemas of interest

define schema_include = '(''HR'',''SH'')'
define role_include = '(''DUMMY'')'

prompt
prompt Roles 

SELECT role
, password_required
FROM sec_3_roles 
WHERE role IN &role_include

prompt
prompt Grantees with DBA or RESOURCE role

SELECT 
  grantee
, granted_role
, admin_option
, default_role
FROM sec_4_granted_dba_type_roles
WHERE grantee IN &schema_include
OR grantee IN &role_include
/

prompt
prompt Granted Roles

break on grantee skip 1
SELECT 
  grantee
, granted_role
, admin_option
, default_role
FROM sec_5_granted_roles
WHERE grantee IN &schema_include
OR grantee IN &role_include
/

prompt
prompt Granted system privileges 


break on grantee skip 1
SELECT grantee, privilege
FROM sec_6_granted_sys_privs
WHERE grantee IN &schema_include
OR grantee IN &role_include
/

prompt
prompt Granted object privileges 

break on grantor across object_name skip 1
SELECT 
  grantor 
, object_name 
, privilege
, grantee
FROM sec_7_granted_tab_privs
WHERE grantee IN &schema_include
OR grantee IN &role_include
/

prompt
prompt Granted object column privileges 

break on grantor across object_name skip 1
SELECT 
  grantor 
, object_name 
, column_name
, privilege
, grantee
FROM sec_8_granted_col_privs
WHERE grantee IN &schema_include
OR grantee IN &role_include
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

edit &spool_name
exit
