/*

 Name:          schema_usage_ck.sql

 Purpose:       Segment usage at various granularitys. For larger databases consider commenting out lower level detail. 

 Contents:

 Date            Who             Description

 2nd Apr 2008   Aidan Lawrence  Merger from various scripts plus sanity check and general tidy up
14th Sep 2009   Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication
18th Mar 2015   Aidan Lawrence  Based on original schema_ck.sql
11th Jan 2016   Aidan Lawrence  Changed to access from col definitions to login.sql 
31st Aug 2017   Aidan Lawrence  Validated for git 

*/


-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'schema_usage_ck'


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

set heading on

-- See login.sql for col definitions 

prompt
prompt ###################################################################
prompt #                                                                 #
prompt #  Overall Schema Usage by schema (Ignoring System level schemas) #
prompt #                                                                 #
prompt ###################################################################
prompt

--
-- Specific break/compute left in this script rather than login.sql 
--
break on report
compute sum label 'Database Totals' of seg_mbytes on report
compute sum label 'Database Totals' of seg_count on report

SELECT 
owner
, seg_mbytes
, seg_count
FROM schema_1_overview
/

SELECT 
owner
, tablespace_name 
, seg_mbytes
, seg_count
FROM schema_2_by_tbsp
/

SELECT 
owner
, tablespace_name 
, seg_type
, seg_mbytes
, seg_count
FROM schema_3_by_tbsp_by_type
/


prompt end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
