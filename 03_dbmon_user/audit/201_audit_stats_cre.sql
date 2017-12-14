/*

 Name:          audit_stats_cre.sql

 Purpose:       Create the audit_stats table

 Date            Who             Description

 28th Jun 2017   Aidan Lawrence  Validated for git 
*/


DROP TABLE audit_trail_stats;

CREATE TABLE audit_trail_stats 
( dbname                  VARCHAR2(8)  NOT NULL
, audit_date              DATE         NOT NULL
, username                VARCHAR2(30)
, os_username             VARCHAR2(255)
, userhost                VARCHAR2(128)
, daily_connections       NUMBER 
, total_logical_reads     NUMBER 
, total_physical_reads    NUMBER 
, total_logical_writes    NUMBER 
)
/

--
-- PK
--

ALTER TABLE audit_trail_stats
ADD CONSTRAINT audit_trail_stats_pk
PRIMARY KEY
(dbname, audit_date, username, os_username, userhost)
/

