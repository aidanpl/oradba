CREATE OR REPLACE PACKAGE pkg_alert_log_monitor 
as
/*

 Name:          cr_pkg_alert_log_monitor.pks

 Purpose:       PL/SQL Package for accessing text version of alert log for easier front end monitoring
 
 Usage:			Alert log monitoring
				
                
 Date            Who             Description

 1st Aug 2017    Aidan Lawrence  Cleaned up from inherited system 
 
*/

--
-- Package Constants
-- 

  c_package_name                CONSTANT VARCHAR2(30) := 'pkg_alert_log_monitor';
  c_logcheck_target             CONSTANT NUMBER(1)    := 2; -- '2' Represents the alert log see this package body for further notes
  c_logcheck_message            CONSTANT CHAR(16)     := '<---LogCheck--->';  -- Default message to insert into alert_log 
  
  c_logcheck_end                CONSTANT VARCHAR2(50) := 'Alert Log Message display complete';
  
  c_font_class_0                CONSTANT VARCHAR2(25) := '<font color=green>';
  c_font_class_1                CONSTANT VARCHAR2(25) := '<font color=red>';
  c_font_class_2                CONSTANT VARCHAR2(25) := '<font color=blue>';
  c_font_class_3                CONSTANT VARCHAR2(25) := '<font color=purple>';
  c_font_class_end              CONSTANT VARCHAR2(10) := '</font>';
  
 
--
-- Modules
--

  FUNCTION alert_log_filter 
		( clear_logs   IN VARCHAR2 DEFAULT 'no'  
		, recent_logs  IN VARCHAR2 DEFAULT 'no' ) 
  RETURN alert_log_table;
	
  PROCEDURE insert_logcheck_message
( message_target IN NUMBER DEFAULT 2
, message        IN VARCHAR2 DEFAULT pkg_alert_log_monitor.c_logcheck_message );

--
-- Additional trivial functions to expose font constants to allow them to be used in the view statements 
--

  FUNCTION font_class_0   RETURN VARCHAR2;
  FUNCTION font_class_1   RETURN VARCHAR2;
  FUNCTION font_class_2   RETURN VARCHAR2;
  FUNCTION font_class_3   RETURN VARCHAR2;
  FUNCTION font_class_end RETURN VARCHAR2;
 
END pkg_alert_log_monitor;
/

SHOW ERRORS
