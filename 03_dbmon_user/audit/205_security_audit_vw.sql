/*

 Name:          08_audit_stats_vw.sql

 Purpose:       Specific view onto audit_trail_stats

 Usage:         A series for views typically called from front end perl/cgi etc. etc.
 
 Date            Who             Description

 28th Jun 2017   Aidan Lawrence  Validated for git 

*/

CREATE OR REPLACE VIEW aud_6_historical_audit_summary AS   
---
-- Relies on capture of data in dbmon.audit_trail_stats
SELECT
  username
, os_username
, userhost 
, to_char(audit_date,'YYYY-MM-DD') as audit_date
, daily_connections
, total_logical_reads
, total_physical_reads
, total_logical_writes 
from audit_trail_stats
ORDER BY 
  username 
, os_username
, userhost 
, audit_date desc 
/  
  
