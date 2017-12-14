/*

 Name:          files_needing_backup_ck.sql

 Purpose:       Check for files not recently backedup
 
 Usage:         files_needing_backup_ck.sql <time_limit> where time_limit represents a number of days since last good backup

 Date            Who             Description

 12th Sep 2017   Aidan Lawrence  Validated for git

*/

-- Set up environment
      

set heading off
set verify off 
set feedback off
set trimspool on
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

define script_name = 'files_needing_backup_ck'
define time_limit = &1

--
-- As this is directly called for monitoring keep spool simple 
--
spool &script_name

set termout on
set feedback on
set heading on 
set pages 99
set linesize 172

col missing_fname_backup   format a70 heading 'Missing Backup'
col most_recent_backup_day format a16 heading 'Most Recent|Backup'
  
SELECT 
  fname                               AS missing_fname_backup 
, TO_CHAR(bkup_time,'Dy DD-MON-YYYY') AS most_recent_backup_day
FROM
  (SELECT ddf.file_name                                       AS fname 
  , MAX(vbd.completion_time) OVER(PARTITION BY ddf.file_name) AS bkup_time
  FROM dba_data_files ddf
  JOIN v$backup_datafile vbd
  ON ddf.file_id=vbd.file#
  )
WHERE bkup_time < sysdate - &time_limit 
ORDER BY 
  bkup_time ASC 
, fname ASC;

spool off 
exit

