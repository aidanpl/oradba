/*

 Name:          cr_view_alerts.sql

 Purpose:       Define various views on external table to display recent alert entries
 
 Usage:         Some hardcoding of alert history 
 
 Date           Who             Description

 1st Aug 2017   Aidan Lawrence  Documented for git 
 
*/

CREATE OR REPLACE FORCE VIEW alerts_all (
    alert_time,
    message
) AS 
--
-- ALERTS_ALL will show all lines of interest in the alert log 
    SELECT DISTINCT
        alert_time,
        CASE alert_class
            WHEN 0 THEN pkg_alert_log_monitor.font_class_0
            WHEN 1 THEN pkg_alert_log_monitor.font_class_1
            WHEN 2 THEN pkg_alert_log_monitor.font_class_2
            WHEN 3 THEN pkg_alert_log_monitor.font_class_3
            ELSE null
        END 
        || alert_message
        || pkg_alert_log_monitor.font_class_end
        AS message
    FROM
        TABLE ( pkg_alert_log_monitor.alert_log_filter(
            clear_logs    => 'No',
            recent_logs   => 'No'
        ) )	
    ORDER BY alert_time desc;
	
CREATE OR REPLACE FORCE VIEW alerts_h24 (
    alert_time,
    message
) AS 
--
-- ALERTS_h24 will show all lines of interest in the alert log from the last 24 hours
    SELECT DISTINCT
        alert_time,
        CASE alert_class
            WHEN 0 THEN pkg_alert_log_monitor.font_class_0
            WHEN 1 THEN pkg_alert_log_monitor.font_class_1
            WHEN 2 THEN pkg_alert_log_monitor.font_class_2
            WHEN 3 THEN pkg_alert_log_monitor.font_class_3
            ELSE null
        END 
        || alert_message
        || pkg_alert_log_monitor.font_class_end
        AS message
    FROM
        TABLE ( pkg_alert_log_monitor.alert_log_filter(
            clear_logs    => 'No',
            recent_logs   => 'No'
        ) )	
    WHERE alert_time > sysdate - 1
    ORDER BY alert_time desc;	
	
CREATE OR REPLACE FORCE VIEW alerts_recent_and_clear (
    alert_time,
    message
) AS 
--
-- alerts_recent_and_clear will show all lines of interest in the alert log since the last clear. It will write a 'clear' marker entry to the underlying alert log. Subsequent views will only show new log entries. 
    SELECT DISTINCT
        alert_time,
        CASE alert_class
            WHEN 0 THEN pkg_alert_log_monitor.font_class_0
            WHEN 1 THEN pkg_alert_log_monitor.font_class_1
            WHEN 2 THEN pkg_alert_log_monitor.font_class_2
            WHEN 3 THEN pkg_alert_log_monitor.font_class_3
            ELSE null
        END 
        || alert_message
        || pkg_alert_log_monitor.font_class_end
        AS message
    FROM
        TABLE ( pkg_alert_log_monitor.alert_log_filter(
            clear_logs    => 'Yes',
            recent_logs   => 'Yes'
        ) )	
    ORDER BY alert_time desc;	
	
CREATE OR REPLACE FORCE VIEW alerts_recent_and_noclear (
    alert_time,
    message
) AS 
--
-- alerts_recent_and_noclear will show all lines of interest in the alert log since the last clear. It will NOT write a marker entry to the underlying alert log. Subsequent access to this view will continue to show alerts since the last clear. 
    SELECT DISTINCT
        alert_time,
        CASE alert_class
            WHEN 0 THEN pkg_alert_log_monitor.font_class_0
            WHEN 1 THEN pkg_alert_log_monitor.font_class_1
            WHEN 2 THEN pkg_alert_log_monitor.font_class_2
            WHEN 3 THEN pkg_alert_log_monitor.font_class_3
            ELSE null
        END 
        || alert_message
        || pkg_alert_log_monitor.font_class_end
        AS message
    FROM
        TABLE ( pkg_alert_log_monitor.alert_log_filter(
            clear_logs    => 'No',
            recent_logs   => 'Yes'
        ) )	
    ORDER BY alert_time desc;	
	
	


