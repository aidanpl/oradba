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
-- Main columns

column dbname                  format a8             heading 'Database|Name'
column generated_date          format a15            heading 'Stats|Generation Date'
column tablespace_name         format a25            heading 'Tablespace|Name'
column file_name               format a50            heading 'File|Name'
column recyclebin_objects      format a25            heading 'Recyclebin|Objects'
column mbytes_used             format 999,990        heading 'MBytes|Used'
column mbytes_free_no_extend   format 999,990        heading 'MBytes Free|No Extend'
column mbytes_max_no_extend    format 999,990        heading 'MBytes Max|No Extend'
column mbytes_free_with_extend format 999,990        heading 'MBytes Free|With Extend'
column mbytes_max_with_extend  format 999,990        heading 'MBytes Max|With Extend'
column mbytes_highwatermark    format 999,990        heading 'MBytes|High Watermark'
column mbytes_current          format 999,990        heading 'MBytes|Current'
column mbytes_reclaimabile     format 999,990        heading 'MBytes|Reclaimable'
column pct_free_no_extend      format 999.90         heading 'Pct Free|No Extend'
column pct_free_with_extend    format 999.90         heading 'Pct Free|With Extend'
column daily_mb_growth         format 999,990        heading 'Daily|MByte Growth'
column growth_period           format 999            heading 'Growth|Period'
column estimate_days_free_no_extend    format 999,990  trunc  heading 'Estimate|Days Free|No Extend'
column estimate_days_free_with_extend  format 999,990  trunc  heading 'Estimate|Days Free|With Extend'

