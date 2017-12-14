/*

 Name:          security_ck.sql

 Purpose:       General Security information

 Contents:      Users
        Non-standard profiles
        Roles
        Roles Privileges
        System privileges granted
        Object privileges granted
        Auditing options


 Date            Who             Description

2nd Apr 2008    Aidan Lawrence  Sanity check AND general tidy up
14th Sep 2009   Aidan Lawrence  Validated for Oracle 9.2 AND 10.2 for publication 
30th Dec 2015   Aidan Lawrence  Added in Column level privileges
13th Apr 2017   Aidan Lawrence  Changed to access FROM views AND col definitions to login.sql  

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'security_ck'
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

prompt
prompt User details

SELECT username
, created
, account_status
, expiry_date
, lock_date
, profile
, default_tablespace
, temporary_tablespace
FROM sec_1_users
/


prompt
prompt Non-default profiles 

break on profile skip 1
SELECT 
  profile
, resource_name
, limit
FROM sec_2_profiles
/

prompt
prompt Roles 

SELECT role
, password_required
FROM sec_3_roles 

prompt
prompt Grantees with DBA or RESOURCE role

SELECT 
  grantee
, granted_role
, admin_option
, default_role
FROM sec_4_granted_dba_type_roles
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
/

prompt
prompt Granted system privileges 


break on grantee skip 1
SELECT grantee, privilege
FROM sec_6_granted_sys_privs
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
/

prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running FROM batch

edit &spool_name
exit
