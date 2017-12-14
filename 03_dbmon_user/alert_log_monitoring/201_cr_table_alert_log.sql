/*

 Name:          cr_table_alert_log.sql

 Purpose:       Define external table to browse the text alert log 
 
 Usage:         Note the hardcoded name of the alert log - change each time for the specific database of interest 
 
 Date           Who             Description

 1st Aug 2017   Aidan Lawrence  Cloned from similar
 
*/

spool cr_table_alert_log.lst 

  DROP TABLE ALERT_LOG;
 
  CREATE TABLE ALERT_LOG 
   (	LOG_LINE VARCHAR2(255)
   ) 
   ORGANIZATION EXTERNAL 
    ( TYPE ORACLE_LOADER
      DEFAULT DIRECTORY ALERTS
      ACCESS PARAMETERS
      ( 
	   RECORDS DELIMITED BY NEWLINE
       NOBADFILE
       NODISCARDFILE
       NOLOGFILE
       SKIP 0
       FIELDS TERMINATED BY '|'
       MISSING FIELD VALUES ARE NULL
       REJECT ROWS WITH ALL NULL FIELDS
       (
         log_line CHAR
       )
                               )
      LOCATION
       ( ALERTS:'alert_dbarep.log'
       )
    )
   REJECT LIMIT UNLIMITED ;

spool off    
   