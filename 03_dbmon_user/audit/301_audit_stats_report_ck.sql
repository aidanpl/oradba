/*

 Name:          audit_stats_report_ck.sql

 Purpose:       Report Audit Stats 

 Contents:  

 Date            Who             Description

  28th Jun 2017   Aidan Lawrence  Validated for git 

*/

-- Set up environment
      

set heading off
set verify off 
set pages 99
set feedback off
set trimspool on
set linesize 172
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

define script_name = 'audit_stats_report_ck'
--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;
       
select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI') 
       || '.lst' spool_name      
  from v$database d;
  
select 'Output report name is ' 
       || '&spool_name'
  from dual;  

spool &spool_name

prompt 
prompt Report Details are &spool_name                     
prompt

--
-- Main report begins
--

column dbname            	   format a8 			 Heading 'Database|Name'
column audit_date              format a15 			 Heading 'Audit|Capture Date'
column username    	           format a30 			 Heading 'Username'
column daily_connections       format 999,990 		 heading 'Daily|Connections'
column total_logical_reads     format 999,999,990 	 heading 'Total|Logical|Reads'
column total_physical_reads    format 999,999,990 	 heading 'Total|Physical|Reads'
column total_logical_writes    format 999,999,990 	 heading 'Total|Logical|Writes'

prompt
prompt ###############################################################
prompt #                                                             #
prompt #  Audit Connection Summary                                   #
prompt #                                                             #
prompt ###############################################################
prompt

select
  a.dbname
, to_char(audit_date,'DD-MON-YYYY') as audit_date
, a.username
, a.os_username
, a.userhost 
, a.daily_connections
, total_logical_reads
, total_physical_reads
, total_logical_writes
 from
audit_trail_stats a 
ORDER BY audit_date desc 
, username  
, os_username
, userhost
;

prompt
prompt end of report

spool off


-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
exit
