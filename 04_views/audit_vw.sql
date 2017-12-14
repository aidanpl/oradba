/*

 Name:          audit_vw.sql

 Purpose:       Audit views 

 Usage:         A series for views typically called from front end perl/cgi etc. etc.
 
 Required GRANTS from SYS to dbmon: 

 GRANT SELECT ON dba_stmt_audit_opts TO dbmon;
 GRANT SELECT ON dba_priv_audit_opts TO dbmon;
 GRANT SELECT ON dba_audit_object TO dbmon;
 GRANT SELECT ON dba_audit_session TO dbmon;
 GRANT SELECT ON dba_audit_trail TO dbmon;
 GRANT SELECT ON v$license TO dbmon;
 
 Outstanding to consider 
 
 select * from all_def_audit_opts
 /

  
 Date            Who             Description

 27rd Jun 2017   Aidan Lawrence  Definition of aud_6_historical_audit_summary relocated to audit trail area 

*/

CREATE OR REPLACE  VIEW aud_1_stmt_options AS 
--
-- Audit statement options 
--
SELECT
  audit_option
, success
, failure
, NVL(user_name,'All Users') as username
FROM dba_stmt_audit_opts
ORDER BY 
  audit_option
, user_name
/
 
CREATE OR REPLACE  VIEW aud_2_priv_options AS 
--
-- Audit privilege options 
--
SELECT
  privilege
, success
, failure
, NVL(user_name,'All Users') as username
FROM dba_priv_audit_opts
ORDER BY 
  privilege
, user_name
/ 
  
CREATE OR REPLACE  VIEW aud_3_connect_failures AS 
--
-- Connection failures last 7 days 
--  
SELECT 
  os_username
, username
, userhost 
, to_char(timestamp,'DY DD-MON-YYYY HH24:MI:SS') as logintime
, CASE returncode 
	WHEN 0     THEN 'Success'
	WHEN 1005  THEN 'Null Password'
	WHEN 1017  THEN 'Wrong Password'
    WHEN 1045  THEN 'User has no connect privilege'
    WHEN 28000 THEN 'Account Locked'
    WHEN 28001 THEN 'Password Expired'
	ELSE CAST(returncode AS VARCHAR(40))
  END as connect_message
 from 
(select 
  os_username
, username
, userhost 
, timestamp
, returncode
from dba_audit_session
where returncode <> 0
and timestamp > (trunc(sysdate) - 7)
ORDER BY timestamp desc 
)
/  
  
CREATE OR REPLACE  VIEW aud_4_non_connect_audits AS   
SELECT
  action_name
, os_username
, username
, userhost 
, to_char(timestamp,'DY DD-MON-YYYY HH24:MI:SS') as audittime
, returncode
from dba_audit_trail
WHERE action_name NOT IN ('LOGON','LOGOFF','LOGOFF BY CLEANUP','SET ROLE')
and timestamp > (trunc(sysdate) - 7)
ORDER BY timestamp desc 
/   

CREATE OR REPLACE  VIEW aud_5_connect_summary_today AS   
SELECT
  username
, os_username
, userhost 
, count(*) as connection_count
from dba_audit_trail
where action_name IN ('LOGOFF','LOGOFF BY CLEANUP')
and trunc(timestamp) = trunc(sysdate)
GROUP BY 
  username
, os_username
, userhost 
ORDER BY 
  username 
, os_username
/  

--
-- aud_6_historical_audit_summary references dbmon table audit_trail_stats
-- If functionality in dbmon_user/audit has not been implemented this view will fail to create
-- Basic definition left in this script for general visibility but please see dbmon_user/audit for latest view
/*
CREATE OR REPLACE  VIEW aud_6_historical_audit_summary
AS
  SELECT
  username
, os_username
, userhost
, to_char(audit_date,'YYYY-MM-DD') as audit_date
, daily_connections
, total_logical_reads
, total_physical_reads
, total_logical_writes
FROM audit_trail_stats
ORDER BY
  username
, os_username
, userhost
, audit_date desc
/

*/
CREATE OR REPLACE  VIEW aud_7_fail_actions_24hrs
--
--List of failed audited actions in last 24 hours
--
AS
SELECT 
  os_username
, username
, to_char(timestamp,'DY DD-MON-YYYY HH24:MI:SS') AS audittime
, obj_name
, action_name
, CASE returncode 
	WHEN 1     THEN 'Unique Constraint Violated'
	WHEN 54    THEN 'Resource Busy and acquire with nowait'
    WHEN 1031  THEN 'Insufficient Priviliges'
	WHEN 1400  THEN 'Cannot insert null'
	WHEN 1732  THEN 'Data Manipulation Operation not legal'
	WHEN 2004  THEN 'Security Violation'
	WHEN 2289  THEN 'Sequence Does not Exist'
	WHEN 10980 THEN 'Prevent sharing of parsed query during Materialized View query generation'
    ELSE CAST(returncode AS VARCHAR(80))
    END as Error_Message
FROM
(	
SELECT 
  os_username
, username
, timestamp
, RTRIM(obj_name,15) obj_name
, action_name
, returncode
FROM dba_audit_object
WHERE returncode <> 0
AND timestamp > (sysdate - 1)
)
/

CREATE OR REPLACE  VIEW aud_8_succ_actions_24hrs
--
--List of successsful audited actions in last 24 hours
--
AS
SELECT 
  os_username
, username
, to_char(timestamp,'DY DD-MON-YYYY HH24:MI:SS') AS audittime
, obj_name
, action_name
, CASE returncode 
    WHEN 0 THEN 'Success'
    ELSE CAST(returncode AS VARCHAR(80))
    END as Error_Message
FROM
(	
SELECT 
  os_username
, username
, timestamp
, RTRIM(obj_name,15) obj_name
, action_name
, returncode
FROM dba_audit_object
WHERE returncode = 0
AND timestamp > (sysdate - 1)
)
/

CREATE OR REPLACE  VIEW session_1_license AS   
SELECT
  sessions_current
, sessions_highwater
, cpu_count_current
, cpu_core_count_current 
, cpu_socket_count_current 
FROM v$license
/   
