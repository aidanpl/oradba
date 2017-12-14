/*

 Name:          sga_resize_ck.sql

 Purpose:       Report SGA resize operations

 Contents:      
 
 Date            Who             Description

 21st Sep 2016   Aidan Lawrence  SGA and PGA measurements split off from instance_ck script 
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

-- Time limit should be specified in hours 

define script_name = 'sga_resize_ck'
define time_limit = &1

--
-- As this is directly called for monitoring keep spool simple
--
spool &script_name  

--
-- Main report begins
--

set termout on
set feedback on
set heading on
set pages 99
set linesize 132

col sga_component_name   format a30    heading 'SGA Component Name'
col oper_type            format a13    heading 'Operation|Type'
col oper_start_time      format a22    heading 'Operation|Time'
col status               format a10    heading 'Operation|Status'
col initial_size_mb      format 99,999 heading 'Initial|Size Mb'
col target_size_mb       format 99,999 heading 'Target|Size Mb'
col final_size_mb        format 99,999 heading 'Final|Size Mb'

SELECT 
component                         as sga_component_name
, round((initial_size/1048976),0) as initial_size_mb
, round((target_size/1048976),0)  as target_size_mb
, round((final_size/1048976),0)   as final_size_mb
, oper_type
, status
, to_char(start_time,'DD-MON-YYYY HH24:MI:SS') as oper_start_time
FROM v$sga_resize_ops
WHERE start_time > sysdate - &time_limit/24
ORDER BY 
  start_time DESC
, sga_component_name
, oper_type
/

spool off
exit
