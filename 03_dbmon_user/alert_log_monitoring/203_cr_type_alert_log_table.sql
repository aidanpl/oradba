/*

 Name:          cr_types_alert_log.sql

 Purpose:       Define type to support alert log processing
 
 Usage:         
 
 Date           Who             Description

 1st Aug 2017   Aidan Lawrence  Cloned from similar
 
*/

CREATE OR REPLACE TYPE ALERT_LOG_TABLE AS
    TABLE OF alert_log_row;