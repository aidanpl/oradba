/*

 Name:         stats_last_analyzed.sql

 Purpose:      List table then index info in order of recent analysis - excludes stats for empty tables


 Date            Who             Description

 8th May 2009    Aidan Lawrence  Specific rewrite focusing solely on recent analysis dates to help understand 'stale' issues and volatile tables in an application
 26th Sep 2017   Aidan Lawrence  Changed to access from views and col definitions to login.sql   

*/


-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'stats_last_analyzed'
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

set heading off
set feedback off 

SELECT 'Database Name: ' || value FROM v$parameter where name='db_name'
/

SELECT 'Generated On ' ||  to_char(sysdate,'dd Month YYYY  HH24:MI') today from dual
/

set heading on
set feedback on 

prompt
prompt Table Stats Listing - both partitioned and non-partitioned tables ordered by last_analyzed excluding tables with no stats 
prompt

SELECT 
to_char(last_analyzed,'DD-MON-YYYY HH24:MI:SS') AS last_analyzed_time
, table_owner
, table_name
, partition_name -- required for the UNION below
, num_rows
, blocks
FROM stats_1_tab_last_analyzed
/

prompt
prompt Index Stats Listing - both partitioned and non-partitioned indexes ordered by last_analyzed excluding indexes with no stats 
prompt

SELECT 
to_char(last_analyzed,'DD-MON-YYYY HH24:MI:SS') AS last_analyzed_time
, index_owner
, index_name
, partition_name -- required for the UNION below
, num_rows
, blevel
, leaf_blocks
FROM stats_2_ind_last_analyzed
/

prompt
prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit

