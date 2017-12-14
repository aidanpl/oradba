/*

 Name:          dbms_stats_rebuild_opt_history.sql

 Purpose:       CTAS, TRUNCATE, REINSERT to resize WRI$_OPTSTAT_HISTGRM_HISTORY if MMON auto purge has been failing and SYSAUX increasing. See Oracle doc 1055547.1 for further information on this bug
 
 Usage:         In practice for sanity run these steps individually on production systems.
				Can also use the awrinfo.sql script to document SYSAUX usage 
 
 Date            Who             Description

29th Sep 2015    Aidan Lawrence  Cloned from similar

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

define script_name = 'dbms_stats_rebuild_opt_history'

--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower(d.name)
       || '.lst' spool_name
  from v$database d;
  
select 'Output report name is ' 
       || '&spool_name'
  from dual;  

spool &spool_name

set feedback on
set termout on 
set time on

set pages 99
set heading on


-- Note volume of historical stats before hand with:
col stats_date format a5 heading 'Stats|Date'
col row_count format 999,999 heading 'Row|Count'

SELECT TO_CHAR(savtime,'MM-DD') as stats_date
, COUNT(*) as row_count
from WRI$_OPTSTAT_HISTGRM_HISTORY
GROUP BY TO_CHAR(savtime,'MM-DD')
ORDER BY TO_CHAR(savtime,'MM-DD') desc
/

--
-- Step 1 CTAS data to retain 

CREATE TABLE aidan_optstat_histgrm_tmp
TABLESPACE TOOLS
AS SELECT * FROM wri$_optstat_histgrm_history
WHERE savtime > sysdate - 12;

TRUNCATE TABLE SYS.wri$_optstat_histgrm_history DROP STORAGE;

-- If quiet system Set indexes unusable to speed up inserts 
--ALTER INDEX I_WRI$_OPTSTAT_H_OBJ#_ICOL#_ST UNUSABLE;
-- ALTER INDEX I_WRI$_OPTSTAT_H_ST UNUSABLE;

-- Alternately Rebuild the indexes before insert to clean out 
ALTER INDEX I_WRI$_OPTSTAT_H_OBJ#_ICOL#_ST REBUILD ONLINE TABLESPACE SYSAUX;
ALTER INDEX I_WRI$_OPTSTAT_H_ST REBUILD ONLINE TABLESPACE SYSAUX;

-- Reinsert the data 
INSERT INTO SYS.wri$_optstat_histgrm_history
SELECT * FROM aidan_optstat_histgrm_tmp;

-- Rebuild the indexes as needed
--ALTER INDEX I_WRI$_OPTSTAT_H_OBJ#_ICOL#_ST REBUILD ONLINE TABLESPACE SYSAUX;
--ALTER INDEX I_WRI$_OPTSTAT_H_ST REBUILD ONLINE TABLESPACE SYSAUX;

-- Drop the temp table 
DROP TABLE aidan_optstat_histgrm_tmp PURGE;

-- Note volume of historical stats after hand with:
col stats_date format a5 heading 'Stats|Date'
col row_count format 999,999 heading 'Row|Count'

select TO_CHAR(savtime,'MM-DD') as stats_date
, count(*) as row_count
from WRI$_OPTSTAT_HISTGRM_HISTORY
GROUP BY TO_CHAR(savtime,'MM-DD')
ORDER BY TO_CHAR(savtime,'MM-DD') desc
/

spool off

-- Cleanup environment
set termout on
set feedback on
set echo off
set time off
set timing off
set pages 40
set lines 132


-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

--edit &spool_name
--exit