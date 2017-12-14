/*

 Name:          login.sql

 Purpose:       Specify sql*plus environment and column definitions for a given directory for consistency across reports.

 Usage:         Edit column definitions to suit an individual environment

 Implementation: For Oracle 12.1 or before login.sql will be executed as part of the sql*plus execution
                 For Oracle 12.2 or later this is no longer the case. Instead Oracle searchs directories specified in the ORACLE_PATH environment variable - which by default is unset.

                 To continue using login.sql functionality in Oracle 12.2 then set ORACLE_PATH=. before executing SQL*PLUS

 Date            Who             Description

  4th Sep 2017   Aidan Lawrence  Comments on changed behaviour in Oracle 12.2

*/
prompt
prompt ###############################################################
prompt #                                                             #
prompt #  Login.sql present in this directory                        #
prompt #                                                             #
prompt ###############################################################
prompt

--
-- Basic formatting
--
set pages 99
set linesize 172
set verify off
set trimspool on
set feedback off
set heading off
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

set heading on
set termout on
set feedback on

--
-- NB - Careful adding any more to this - max string size is 240 characters :-o
define ignore_schemas = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')


--
-- Block reporting

column owner          format A30       heading Owner 
column segment_name   format A30       heading Segment 
column partition_name format A20       heading Partition 
column file_id        format 9999      heading 'File|Id.'  
column extent_id      format 999999    heading 'Extent|Id.'  
column blocks         format 999,999   heading 'Block|Count'
column start_block    format 999999    heading 'Start|Block' 
column hwm_mbytes     format 9,999,999 heading 'HWM (Mb)'
column block_no 	  format 999,999   heading 'Block|No.'
column num_Rows       format 9999      heading 'Num|Rows' 

