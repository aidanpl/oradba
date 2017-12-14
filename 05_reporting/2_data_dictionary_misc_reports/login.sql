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
-- used for security checks 
define ignore_roles = ('DBA','RESOURCE','CONNECT','IMP_FULL_DATABASE','EXP_FULL_DATABASE','DBSNMP','RECOVERY_CATALOG_OWNER','SYS','SYSTEM','SNMPAGENT')
define ignore_privs   = ('CREATE SESSION')

--
-- Common columns

column owner          format a15 Heading Owner
column table_name     format a30 Heading 'Table|Name'
column object_name    format a30 Heading 'Object|Name'
column db_name        format a8  Heading 'Database|Name'
column value          format a30 heading 'Value'
column unit  		  format a30 heading 'unit'
column status         format a30 heading 'Status'

--
-- General Instance 

column instance_name  format a8  Heading 'Instance|Name'
column instance_role  format a20 Heading 'Instance|Role'
column host_name 	  format a35 Heading 'Host Name'
column version        format a10 Heading 'Oracle|Release'
column last_start     format a20 Heading 'Instance|Last Started'
column archiver       format a10 Heading 'Archive|Status'

column sessions_max       format a10  Heading 'Max|Sessions|Allowed'
column sessions_current   format 9999 Heading 'Current|Sessions'
column sessions_highwater  format 9999 Heading 'Sessions|Highwater'
column cpu_count_highwater format 999 Heading 'CPU Count|Highwater'

column parameter_name          format a40 heading 'Parameter|Name'
column parameter_display_value format a40 heading 'Parameter|Value'
column parameter_description   format a50 heading 'Parameter|Description'
column parameter_modified      format a10 heading 'Parameter|Modified'
column parameter_modifiable    format a10 heading 'Parameter|Modifiable'

--
-- Object specific  

column object_type     format a20 Heading 'Object|Type'
column creation_time   format a17 Heading 'Creation|Time'
column ddl_time        format a17 Heading 'Last DDL|Time'
column partition_count format 9999 Heading 'Partition|Count'

--
-- Invalid checks 

column username         heading 'User name'        format a30
column locked_on 		heading 'Locked On'        format a11
column expired_on 		heading 'Expired On'       format a17
column expiring_on 		heading 'Expiring On'      format a17

column object_name      heading 'Object|name'      format a30
column object_type      heading 'Object|Type'      format a30

--
-- Physical file

column file_id          heading 'File ID'           format 9999
column file_name        heading 'File Name'         format a70
column tablespace_name  heading 'Tablespace'        format a25
column mbytes           heading 'Current|Size(M)'   format 99,999
column max_mbytes       heading 'Maximum|Size(M)'   format 99,999
column extendable       heading 'Extendable?'       format a12

--
-- Redo 

column redo_type              heading 'Redo|Type'            format a10
column redo_group             heading 'Redo|Group'           format 999
column redo_member            heading 'Redo Log| File Name'  format a50
column file_status            heading 'File|Status'          format a10
column redo_status            heading 'Redo|Status'          format a10
column redo_sequence          heading 'Redo|Sequence'	     format 999999999 
column redo_destination       heading 'Redo|Destination'     format a40 
column file_type                     heading 'File|Type'     format a15
column number_of_files               heading 'File|Count'    format 9,999 
column date_hour                     heading 'Date:Hour'     format a10
column number_of_switches            heading 'Switch|Count'  format 9,999 
column percent_space_used            heading 'Percent|Space Used'      format 90.99
column percent_space_reclaimable     heading 'Percent|Reclaimable'     format 90.99 
column percent_space_not_reclaimable heading 'Percent|Not Reclaimable' format 90.99 
column archive_log_start_time heading 'Archive|Start Time'   format a20  
column archive_log_end_time   heading 'Archive|End Time'     format a20  
column archive_log_size       heading 'Archive|Log size(Kb)' format 9,999,999.9

--
-- Dataguard 

column metric_name     				format a30 heading 'Metric|Name'
column time_computed   				format a30 heading 'Time|Computed'
column db_unique_name     			format a10 heading 'DB Unique|Name'
column database_role      			format a20 heading 'Database|Role'
column sequence# 				    format 99999999 heading 'Log|Sequence'
column log_sequence# 				format 99999999 heading 'Log|Sequence'
column fail_sequence                format 99999999 heading 'Failed|Sequence#'
column low_sequence#                format 99999999 Heading 'Low seq'
column high_sequence#               format 99999999 Heading 'High seq'

column current_scn        			format 99,999,999,999,999 heading 'Current|SCN'
column archive_change#    			format 99,999,999,999,999 heading 'Archive|SCN'
column switchover_status  			format a15 heading 'Switchover|Status'
column dataguard_broker   			format a10 heading 'Dataguard|Broker'
column protection_level   			format a20 heading 'Protection|Level'
column fs_failover_status 			format a22 heading 'Failover|Status'
column fs_failover_current_target   format a8 heading 'Failover Current|Target'
column fs_failover_threshold 		format 999,999 heading 'Failover|Threshold(s)'
column fs_failover_observer_present format a8 heading 'Failover|Observer'
column facility 					format a24  heading 'Facility'
column severity 					format a17  heading 'Severity'
column message_time 				format a20 heading 'Message|Time'
column error_code 					format 99999 heading 'Error'
column message 						format a80 heading 'Message - first 80 characters'

column dest_id                      format 999 heading 'Log Archive|Dest id'
column dest_name                    format a20 heading 'Log Archive|Dest Name'
column status        				format a12 heading 'Process|State'
column archive_status               format a12 heading 'Log|Status'
column target        				format a7 heading 'Target'
column destination   				format a35 heading 'Destination'

column fail_time 				    format a20 heading 'Failure|Time'
column failure_count                format 999 heading 'Failure|Count'
column max_failure                  format 999 heading 'Max|Failure'
column process   	  				format a9 heading 'Process|Name'
column error     	  				format a20 heading 'Error'
column transmit_mode                format a20 heading 'Transmit|Mode'
column valid_type                   format a20 heading 'Valid|Type' 
column valid_role                   format a20 heading 'Valid|Role' 

column pid                          format 99999 heading 'Process|id'
column client_process               format a8 heading 'Process|Client|Name'
column client_pid                   format a5 heading 'Process|Client id'

column blocks                       format 9999999 heading 'Blocks'

column log_start_time               format a25 heading 'Log Start Time'

column standby_dest    format a8  heading 'Standby?'
column archived        format a9  heading 'Archived?'
column registrar       format a8  heading 'Source|Process'
column applied         format a9 heading 'Applied?'

column type    format a8 heading 'Type'
column group#  format 999999 heading 'Group'
column member  format a40 heading 'File|Name'
column bytes   format 9,999,999,999 Heading 'Bytes'
column sequence# format 99999999 Heading 'Arch|No.'
column first_time format a20 heading 'First|Time'
column next_time format a20 heading 'Next|Time'
column last_time format a20 heading 'Last|Time'

--
-- Destinations 

column parameter_name  heading 'Name'                format a30
column parameter_value heading 'Value'               format a90
--
-- Security and audit related
--
column username          format a30 Heading 'DB Username'
column os_username       format a20 Heading 'OS Username'
column created          format a13 Heading 'Created'
column profile          format a15 Heading 'Profile'
column account_status   format a10 Heading 'Status'
column expiry_date      format a13 Heading 'Expiry|Date'
column lock_date        format a13 Heading 'Lock|Date'
column default_tablespace   format a25 Heading 'Default|Tablespace'
column temporary_tablespace format a10 Heading 'Temporary|Tablespace'
column resource_name        format a30 Heading 'Resource|Name'
column limit                format a20     Heading 'Limit'
column role              format a30 Heading 'Role'
column password_required format a10 Heading 'Password|Required?'
column grantee           format a30 Heading 'Grantee'
column privilege         format a30 Heading 'Privilege'
column granted_role 	 format a30 Heading 'Granted|Role'
column admin_option 	 format a7 Heading 'Admin|Option?'
column default_role 	 format a7 Heading 'Default|Role?'
column column_name       format a30 Heading 'Column|Name'
column Audit_option      format a30 Heading 'Audit Option'
column actionname        format a30 Heading 'Action Name'
column action_name       format a30 Heading 'Action Name'
column privilege         format a30 Heading Privilege
column success           format a10 Heading Success
column failure           format a10 Heading Failure
column userhost          format a35 Heading Hostname
column logintime         format a25 Heading 'Login Time'
column audit_date        format a11 Heading 'Audit Date'
column audittime         format a25 Heading 'Audit Time'
column connect_message   format a30 Heading Message
column Error_Message     format a75 Heading 'Error|Message'
column obj_name          format a30 Heading Object
column returncode           format 99999       heading 'Return|Code'
column daily_connections    format 99999       heading 'Daily|Connections'
column total_logical_reads  format 999,999,999 heading 'Logical|Reads'
column total_logical_writes format 9,999,999   heading 'Logical|Writes'
column total_physical_reads format 999,999,999 heading 'Physical|Reads'

--
-- For dbms_schedule
column job_name    		 format a30  heading 'Job|Name'   
column job_status  		 format a30  heading 'Job|Status'   
column schedule_name     format a30  heading 'Schedule|Name'       
column enabled     		 format a10  heading 'Enabled'    
column next_run_date     format a20  heading 'Next Run|Date'  
column start_time    	 format a20  heading 'Start|Time'   
column end_time    		 format a20  heading 'End|Time'   
column duration    	     format a15  heading 'Duration'   
column repeat_interval   format a100 heading 'Repeat|Interval'  

--
-- Mview related

column rowner            format a15 heading 'Master|Owner'
column log_owner         format a15 heading 'Log|Owner'
column log_user          format a15 heading 'Log|User'
column master_owner      format a15 heading 'Master|Owner'
column master            format a30 heading 'Master|owner'
column child_schema      format a15 heading 'Child|Schema'
column is_master         format a8 heading 'Master?'

column child_db          format a15 heading 'Child|Database'
column child_site        format a8 heading 'Child Site'
column mview_site        format a8 heading 'Mview Site'

column master_table      format a30 heading 'Master Table'
column master_name       format a30 heading 'Master|Name'
column name              format a30 heading 'Name'
column rname             format a20 heading 'Master Name'
column sname             format a20 heading 'SName'
column local_view        format a30 heading 'Local|View'
column child_view        format a30 heading 'Child|View'
column mview_name        format a30 heading 'View|Name'
column log_table         format a30 heading 'Log|Table'

column updatable         format a15 heading 'Updateable?'
column broken            format a7 heading 'Broken?'
column job               format 999 heading 'Job|No'

column last_refresh_date   format a16 heading 'Last|Refresh Time'
column local_refresh_time  format a16 heading 'Local|Refresh Time'
column master_refresh_time format a16 heading 'Master|Refresh Time'
column last_date           format a16 heading 'Last|Date'
column next_date           format a16 heading 'Next|Refresh Time'

column refgroup          format 9999 heading 'Refgroup'
column interval          format a32 heading 'Interval'
column what              format a60 heading 'What'
column compile_state     format a17 heading 'Compile|State'
column refresh_after_errors format a12 heading 'Refresh|After Errors'
column oldest            format a20 heading 'Oldest Log|entry'
column youngest          format a20 heading 'Youngest Log|entry'

column size_mlog_mbytes   format 9999.9 heading 'Size|MBytes'

-- licence check
-- nb names inherited from underlying scripts provided by Oracle support 

column 'Option/Management Pack' FORMAT A60 Heading 'Option Management Pack' 
column 'Used' 					 FORMAT A5  Heading Used
column 'Feature being Used' 	 FORMAT A50 Heading 'Feature being Used'
column 'Currently Used' 		 FORMAT A14 Heading 'Currently Used'
column 'Last Usage Date' 		 FORMAT A18 Heading 'Last Usage Date'
column 'Last Sample Date' 		 FORMAT A18 Heading 'Last Sample Date'
column 'Host Name' 			 FORMAT A40 Heading 'Host Name'

--
-- Data Dictionary Comments 

column table_type format a15 Heading 'Table|Type'
column comments   format a50 Heading 'Comments'


