/*

 Name:          job_results_views_vw.sql

 Purpose:       job_results views 

 Usage:         A series for views typically called FROM front end perl/cgi etc. etc.

 Implementation Typically run under 'dbmon' type user. Initially cloned FROM job_results 

 Next Steps:

 Date            Who             Description

 20th May 2016   Aidan Lawrence  cloned FROM similar
 17th Oct 2017   Aidan Lawrence  Validated for git 

*/

CREATE OR REPLACE VIEW job_results_1_most_recent_runs
--
-- Most recent run by dbname/schema/job 
-- 
AS
SELECT      dbname
          , owner
          , job_name
          , to_char(actual_start_time,'DD-MON-YYYY HH24:MI:SS') as start_time
          , to_char(run_duration,'HH24:MI:SS')             as duration
          , to_char(log_time,'DD-MON HH24:MI:SS')          as end_time
          , CASE status
                WHEN 'SUCCEEDED' THEN 'Success'
                WHEN 'FAILED' THEN 'Failed  - Please check Schedule logs for details'
            END as job_status
		  , error#
		  , additional_info
FROM
    (
      SELECT
          j.dbname
        , j.owner
        , j.job_name
        , j.status
        , j.actual_start_time
        , j.run_duration
        , j.log_time
		, j.error#
		, j.additional_info
        , max(j.log_time) OVER(partition by j.dbname,j.owner,j.job_name) as max_log_time
      FROM job_results j
	  WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),j.owner)
    )
where log_time = max_log_time
ORDER BY 
  dbname
, owner
, job_name
/

CREATE OR REPLACE VIEW job_results_2_failures
AS
SELECT      dbname
          , owner
          , job_name
          , to_char(actual_start_time,'DD-MON-YYYY HH24:MI:SS') as start_time
          , to_char(run_duration,'HH24:MI:SS')             as duration
          , to_char(log_time,'DD-MON HH24:MI:SS')          as end_time
          , CASE status
                WHEN 'SUCCEEDED' THEN 'Success'
                WHEN 'FAILED' THEN 'Failed  - Please check Schedule logs for details'
            END as job_status
		  , error#
		  , additional_info
FROM
    (
      SELECT
          j.dbname
        , j.owner
        , j.job_name
        , j.status
        , j.actual_start_time
        , j.run_duration
        , j.log_time
		, j.error#
		, j.additional_info
      FROM job_results j
	  WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),j.owner)
	  AND j.error# <> 0
    )
ORDER BY 
  dbname
, owner
, job_name
/


