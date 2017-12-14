CREATE OR REPLACE PACKAGE BODY pkg_audit_stats_target
 as

/*

 Name:          cr_pkg_audit_trail_stats_target.pkb

 Purpose:       PL/SQL Package pkg_audit_trail_stats
 
 Usage:			Centralized Auditing Measurement
 
 				Functional code is in individual packages. This is the core run code
				
Required grants:				
				
GRANT DELETE ON SYS.AUD$ TO DBMON;
GRANT SELECT ON DBA_AUDIT_SESSION TO DBMON;
GRANT SELECT ON DBA_AUDIT_OBJECT TO DBMON;
GRANT SELECT ON DBA_AUDIT_TRAIL TO DBMON;				
                
 Date            Who             Description

 28th Jun 2017   Aidan Lawrence  Validated for git 
  
*/  

PROCEDURE run_daily_audit
IS

  c_module_name     CONSTANT VARCHAR2(30) := 'run_daily_audit';
  v_error_message   VARCHAR2(4000);  

/*

Daily driving procedure to populate then purge 

*/

BEGIN
	
	pop_audit_trail_stats_target;
	purge_db_audit_trail;
	
EXCEPTION
WHEN OTHERS
      THEN
        v_error_message :=  'Unknown Error ' || c_package_name || '.' || c_module_name || ' ' || sqlerrm;
        dbms_output.put_line (v_error_message);
		RAISE_APPLICATION_ERROR(-20001,v_error_message);		 	

END run_daily_audit;

PROCEDURE pop_audit_trail_stats_target
IS

  c_module_name     CONSTANT VARCHAR2(30) := 'pop_audit_trail_stats_target';
  v_error_message   VARCHAR2(4000);  

/*

Simple procedure to copy data from dba_audit_trail (based on SYS.AUD$) for trunc(sysdate) - 1.
Assumption is this will be run daily. 

*/

BEGIN
	
	--
	-- Purge any stats to be copied on this run based on standard filter
	--	
	
	delete from audit_trail_stats dat 
	WHERE TRUNC(dat.audit_date) < trunc(sysdate)
      AND TRUNC(dat.audit_date) >= trunc(sysdate) - pkg_audit_stats_target.c_audit_capture_period;
	
	--
	-- Capture stats to be copied on this run based on standard where clause
	-- 
	
	INSERT INTO audit_trail_stats
	( dbname                  
	, audit_date              
	, username                
	, os_username
	, userhost 
	, daily_connections       
	, total_logical_reads     
	, total_physical_reads    
	, total_logical_writes    
	)
	SELECT 
	d.name
  , TRUNC(dat.timestamp) 
  , dat.username 
  , dat.os_username
  , dat.userhost
  , COUNT(*)
  , SUM(dat.logoff_lread)
  , SUM(dat.logoff_pread)  
  , SUM(dat.logoff_lwrite) 
  FROM dba_audit_trail dat
  CROSS JOIN v$database  d
  WHERE dat.action_name LIKE 'LOGOFF%'
  AND TRUNC(dat.timestamp) < trunc(sysdate)
  AND TRUNC(dat.timestamp) >= trunc(sysdate) - pkg_audit_stats_target.c_audit_capture_period
  GROUP BY d.name
         , TRUNC(dat.timestamp)
         , dat.username
		 , dat.os_username
		 , dat.userhost
		 ;
		 
EXCEPTION
WHEN OTHERS
      THEN
        v_error_message :=  'Unknown Error ' || c_package_name || '.' || c_module_name || ' ' || sqlerrm;
        dbms_output.put_line (v_error_message);
		RAISE_APPLICATION_ERROR(-20001,v_error_message);		 

END pop_audit_trail_stats_target;

PROCEDURE purge_db_audit_trail
IS

  c_module_name     CONSTANT VARCHAR2(30) := 'purge_db_audit_trail';
  v_error_message   VARCHAR2(4000);  

/*

purge sys.aud$ table and dbmon.audit_trail_stats based on package constant retentions 

c_sys_aud_dollar_retention    NUMBER                := 7;  -- Days 'live' audit data to retain 
c_audit_trail_stats_retention NUMBER                := 90; -- Days captured audit_trail_stats to retain 

*/

BEGIN
	
	--
	-- Purge sys.aud$ 
	--	
	
	delete from sys.aud$ 
	where ntimestamp# < sysdate - pkg_audit_stats_target.c_sys_aud_dollar_retention;
	
	--
	-- Purge audit_trail_stats 
	--	

	delete from audit_trail_stats
	where audit_date < sysdate - pkg_audit_stats_target.c_audit_trail_stats_retention;
	
EXCEPTION
WHEN OTHERS
      THEN
        v_error_message :=  'Unknown Error ' || c_package_name || '.' || c_module_name || ' ' || sqlerrm;
        dbms_output.put_line (v_error_message);
		RAISE_APPLICATION_ERROR(-20001,v_error_message);		 	

END purge_db_audit_trail;


END pkg_audit_stats_target;
/



