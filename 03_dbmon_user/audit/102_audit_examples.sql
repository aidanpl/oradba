/*

 Name:          audit_examples.sql

 Purpose:       Some example audit statements to allow audit trail to be generated 
 
 Usage:			
 


 Date            Who             Description

 16th Jul 2017   Aidan Lawrence  validated pre-git
*/


-- For testing purposes to generate some audit records 

alter system set audit_trail='DB' scope=spfile;

-- Bounce database to activate 
-- Then add some audit statements 

AUDIT CREATE SESSION BY ACCESS;
AUDIT CREATE USER BY ACCESS;
AUDIT DROP USER BY ACCESS;
AUDIT ALTER DATABASE BY ACCESS;
AUDIT ALTER SYSTEM BY ACCESS;
AUDIT ALTER ANY PROCEDURE BY ACCESS;
AUDIT CREATE ANY PROCEDURE BY ACCESS;
AUDIT CREATE ANY TABLE BY ACCESS;
AUDIT DROP ANY PROCEDURE BY ACCESS;
AUDIT ALTER ANY TABLE BY ACCESS;
AUDIT DROP ANY TABLE BY ACCESS;
AUDIT ALTER USER BY ACCESS;
AUDIT AUDIT SYSTEM BY ACCESS;
AUDIT CREATE PUBLIC DATABASE LINK BY ACCESS;
AUDIT GRANT ANY OBJECT PRIVILEGE BY ACCESS;
AUDIT GRANT ANY PRIVILEGE BY ACCESS;
AUDIT GRANT ANY ROLE BY ACCESS;

--
-- Once audit trail in place core query to capture 

SELECT 
username
, trunc(timestamp)   as audit_date
, count(*)           as daily_connections
, sum(logoff_lread)  as total_logical_reads
, sum(logoff_pread)  as total_physical_reads
, sum(logoff_lwrite) as total_logical_writes
FROM dba_audit_trail
WHERE action_name LIKE 'LOGOFF%'
AND trunc(timestamp) = trunc(sysdate) - 1
GROUP BY username
, trunc(timestamp)
ORDER BY total_logical_reads DESC;

