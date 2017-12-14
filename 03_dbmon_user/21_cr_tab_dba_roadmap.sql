/*

 Name:          cr_dbarep_roadmap.sql

 Purpose:       Define dbarep_roadmap
 
 Usage:			General documentation table to include in reports
                
 Date            Who             Description
 
 8th Jun 2017    Aidan Lawrence  Validated pre git 
 
*/


ALTER TABLE dbarep_roadmap
 DROP PRIMARY KEY CASCADE;

DROP TABLE dbarep_roadmap CASCADE CONSTRAINTS;

--
-- dbarep_roadmap  (Table) 
--
CREATE TABLE dbarep_roadmap
(
  PRIORITY                   NUMBER(2),
  DB_NAME                    VARCHAR2(100 BYTE),
  DB_UNIQUE_NAME             VARCHAR2(100 BYTE),
  DB_RMAN_UNIQUE_NAME        VARCHAR2(100 BYTE),
  HOST_NAME                  VARCHAR2(100 BYTE),
  ORACLE_RELEASE             VARCHAR2(100 BYTE),
  USAGE                      VARCHAR2(100 BYTE),
  DESCRIPTION                VARCHAR2(400 BYTE),
  LAST_UPDATED               DATE,
  BUSINESS_OWNER             VARCHAR2(400 BYTE),
  MONITOR_CAPACITY_INCLUDE   CHAR(1 BYTE),
  MONITOR_JOB_STATS_INCLUDE  CHAR(1 BYTE),
  MONITOR_DB_LINK            VARCHAR2(30 BYTE),
  COMMENTS                   VARCHAR2(4000 BYTE)
)
TABLESPACE DBMON
;

--
-- dbarep_roadmap_pk  (Index) 
--
--  Dependencies: 
--   dbarep_roadmap (Table)
--
CREATE UNIQUE INDEX dbarep_roadmap_pk ON dbarep_roadmap
(DB_NAME, HOST_NAME)
TABLESPACE DBMON;

--
-- dbarep_roadmap_BUIU  (Trigger) 
--

CREATE OR REPLACE TRIGGER dbarep_roadmap_BUIU
 BEFORE INSERT OR UPDATE ON dbarep_roadmap REFERENCING NEW AS NEW OLD AS OLD                                                                                                       
 FOR EACH ROW
DECLARE
 
 BEGIN
 :new.last_updated := sysdate;
END;
/


-- 
-- Non Foreign Key Constraints for Table dbarep_roadmap 
-- 
ALTER TABLE dbarep_roadmap ADD (
  CONSTRAINT USAGE_CK
  CHECK (usage in ('Prod','Train','Dev','Redundant','Test'))
  ENABLE VALIDATE,
  CONSTRAINT dbarep_roadmap_PK
  PRIMARY KEY
  (DB_NAME, HOST_NAME)
  USING INDEX dbarep_roadmap_PK
  ENABLE VALIDATE);

--
--Example entry 
--

INSERT INTO dbarep_roadmap
(
  priority                   
, db_name                  
, db_unique_name           
, db_rman_unique_name      
, host_name                
, oracle_release             
, usage                      
, description                
, monitor_capacity_include   
, monitor_job_stats_include  
)
VALUES
(
  1 -- priority                   
, 'dbarep' -- db_name                  
, 'dbarep' -- db_unique_name           
, 'dbarep' -- db_rman_unique_name      
, 'db01'  -- host_name                
, '12.2.0' -- oracle_release             
, 'Test' -- usage                      
, 'Test Database' -- description                
, 'N' -- monitor_capacity_include   
, 'N' --  monitor_job_stats_include  
);

COMMIT;