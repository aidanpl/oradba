/*

 Name:          scheduler_‪views_vw.sql

 Purpose:       Scheduler report as views

 Usage:         A series for views typically called from front end perl/cgi etc. etc.

 --
 --  Required direct Grants for view creations

 GRANT SELECT ON dba_scheduler_jobs TO dbmon;
 GRANT SELECT ON dba_scheduler_schedules TO dbmon;
 GRANT SELECT ON dba_scheduler_job_run_details TO dbmon;

 Date            Who             Description

 19th May 2017   Aidan Lawrence  Consolidated from various sources 
 15th Jun 2017   Aidan Lawrence  Validated pre git publication   

*/


CREATE OR REPLACE VIEW job_1_most_recent_runs
--
-- Most recent job runss 
-- 
AS
SELECT   owner
          , job_name
          , to_char(actual_start_date,'DD-MON-YYYY HH24:MI:SS') as start_time
          , to_char(run_duration,'HH24:MI:SS')             as duration
          , to_char(log_date,'DD-MON HH24:MI:SS')          as end_time
          , CASE status
                WHEN 'SUCCEEDED' THEN 'Success'
                WHEN 'FAILED' THEN 'Failed  - Please check Schedule logs for details'
            END as job_status
FROM
    (
      SELECT
          jrd.owner
        , jrd.job_name
        , jrd.status
        , jrd.actual_start_date
        , jrd.run_duration
        , jrd.log_date
        , max(jrd.log_date) OVER(partition by jrd.job_name) as max_log_date
      FROM dba_scheduler_job_run_details jrd
	  WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),jrd.owner)
    )
where log_date = max_log_date
ORDER BY 
  owner
, job_name
/

CREATE OR REPLACE VIEW job_2_future_schedule
--
-- Future Schedule
-- 
AS
SELECT  
  j.owner
, j.job_name
, j.enabled
, NVL(to_char(j.next_run_date,'DD-MON-YYYY HH24:MI:SS'),'Not Set') as next_run_date
, NVL(j.schedule_name,'Not Set') as schedule_name
, COALESCE(j.repeat_interval,s.repeat_interval,'Not Set') as repeat_interval
from dba_scheduler_jobs j
left join dba_scheduler_schedules s
on j.owner = s.owner 
and j.schedule_name = s.schedule_name 
WHERE NOT REGEXP_LIKE((SELECT ignore_schemas FROM ignore_1_schemas),j.owner)
ORDER BY 
CASE j.enabled 
  WHEN 'TRUE' THEN 0
  ELSE 1
  END 
, j.owner
, j.next_run_date asc
, j.job_name
/

