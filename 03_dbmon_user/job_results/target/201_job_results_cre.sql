/*

 Name:          capacity_cre.sql

 Purpose:       Create the job_results and DATAFILE_HIGHWATERMARK tables

                This will use the users default tablespace. Sizing information only therer for systems still using DMT

 Date            Who             Description
 15th Jul 2013	 Aidan Lawrence  Cloned from similar
 10th Oct 2017   Aidan Lawrence  Validated pre git  
 21st Aug 2018   Aidan Lawrence  Changed actual_start_time from DATE to TIMESTAMP to avoid duplicate error issues on insert

*/


-- DROP TABLE job_results;

--
-- Source data from DBA_SCHEDULER_JOB_RUN_DETAILS.
-- While DBA_SCHEDULER captures Times using TIMESTAMP (6) WITH TIME ZONE, For the purposes of reporting these are captured at a DATE level 

CREATE TABLE job_results
( dbname            VARCHAR2(8)   NOT NULL
, owner             VARCHAR2(30)  NOT NULL
, job_name          VARCHAR2(30)  NOT NULL
, actual_start_time TIMESTAMP
, log_time 		    DATE
, run_duration 		INTERVAL DAY (3) TO SECOND (6)
, status 			VARCHAR2(30)  NOT NULL
, error# 			NUMBER
, additional_info 	VARCHAR2(4000)
)
/


--
-- Primary Key
--

ALTER TABLE job_results
ADD CONSTRAINT job_results_pk
PRIMARY KEY
(dbname, owner, job_name, actual_start_time)
/
