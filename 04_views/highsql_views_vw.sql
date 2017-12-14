/*

 Name:          highsql_views_vw.sql

 Purpose:       Dynamic views based on high_resource_sql_ck.sql script

 Usage:         A series for views typically called from front end perl/cgi etc. etc.

--
--  Required direct Grants for view creations

GRANT SELECT ON v_$sqlarea TO dbmon;
 
 Date            Who             Description


 18th Dec 2015   Aidan Lawrence  Continued end of year tidy up
 24th Feb 2017   Aidan Lawrence  Tweak to grant notes during Ora12 sanity checks 
  8th Jun 2017   Aidan Lawrence  Validated pre git publication   
*/



CREATE OR REPLACE VIEW highsql_1_general
--
-- Generic highest resource SQL view. Should call this from other more specific views by cpu, memory etc. etc.
-- Note arbitrary limits in WHERE clause
AS
SELECT
  parsing_schema_name
, sql_id
, sql_text
, sql_fulltext
, rows_processed
, executions
, elapsed_time_per_execution
, elapsed_time_total
, buffer_gets_per_execution
, buffer_gets_total
, disk_reads_per_execution
, disk_reads_total
, cpu_time_seconds
, last_active_time
FROM (SELECT
  parsing_schema_name                               as parsing_schema_name
, sql_id                                            as sql_id
, sql_text                                          as sql_text
, sql_fulltext                                      as sql_fulltext
, rows_processed                                    as rows_processed
, executions                                        as executions
, round((elapsed_time/1000000)/(0.01 + executions),1) as elapsed_time_per_execution
, round(elapsed_time/1000000,1)                     as elapsed_time_total
, round(buffer_gets/(0.01 + executions),0)          as buffer_gets_per_execution
, buffer_gets                                       as buffer_gets_total
, round(disk_reads/(0.01 + executions),0)           as disk_reads_per_execution
, disk_reads                                        as disk_reads_total
, round(cpu_time/1000000,1)                         as cpu_time_seconds
, to_char(last_active_time,'Dy DD-MON HH24:MI:SS')  as last_active_time
FROM V$SQLAREA
)
WHERE
   elapsed_time_per_execution > 10
OR elapsed_time_total         > 100
OR buffer_gets_per_execution > 20000
OR buffer_gets_total         > 200000
OR disk_reads_per_execution  > 2000
OR disk_reads_total          > 20000
/


CREATE OR REPLACE VIEW highsql_2_buffer_gets_per_exec
--
-- Highest resource SQL based on number of buffer gets per execution
-- Note arbitrary limits in WHERE clause
AS
SELECT
  parsing_schema_name                as parsing_schema
, sql_id                             as sql_id 
, sql_text                           as sql_text
, rank_by_buffer_gets_per_exec       as rank
, buffer_gets_per_execution          as buffer_gets_per_execution
, total_executions                   as total_executions
, rows_processed                     as rows_processed
, last_active_time                   as last_active_time
FROM
( SELECT
  parsing_schema_name
, sql_id                                                as sql_id 
, sql_text                                              as sql_text
, rank() over(order by buffer_gets_per_execution desc)  as rank_by_buffer_gets_per_exec
, buffer_gets_per_execution                             as buffer_gets_per_execution
, executions                                            as total_executions
, rows_processed                                        as rows_processed
, last_active_time                                      as last_active_time
FROM highsql_1_general
)
where rank_by_buffer_gets_per_exec <= 10
order by buffer_gets_per_execution desc
/

CREATE OR REPLACE VIEW highsql_3_buffer_gets_total
--
-- Highest resource SQL based on number of buffer gets per execution
-- Note arbitrary limits in WHERE clause
AS
SELECT
  parsing_schema_name                as parsing_schema
, sql_id                             as sql_id 
, sql_text                           as sql_text
, rank_by_buffer_gets_total          as rank
, buffer_gets_total                  as buffer_gets_total
, rows_processed                     as rows_processed
, last_active_time                   as last_active_time
FROM
( SELECT
  parsing_schema_name
, sql_id                                                as sql_id 
, sql_text                                              as sql_text
, rank() over(order by buffer_gets_total desc)          as rank_by_buffer_gets_total
, buffer_gets_total                                     as buffer_gets_total
, rows_processed                                        as rows_processed
, last_active_time                                      as last_active_time
FROM highsql_1_general
)
where rank_by_buffer_gets_total <= 10
order by buffer_gets_total desc
/

CREATE OR REPLACE VIEW highsql_4_disk_reads_per_exec
--
-- Highest resource SQL based on number of buffer gets per execution
-- Note arbitrary limits in WHERE clause
AS
SELECT
  parsing_schema_name                as parsing_schema
, sql_id                             as sql_id 
, sql_text                           as sql_text
, rank_by_disk_reads_per_exec        as rank
, disk_reads_per_execution           as disk_reads_per_execution
, total_executions                   as total_executions
, rows_processed                     as rows_processed
, last_active_time                   as last_active_time
FROM
( SELECT
  parsing_schema_name
, sql_id                                                as sql_id 
, sql_text                                              as sql_text
, rank() over(order by disk_reads_per_execution desc)   as rank_by_disk_reads_per_exec
, disk_reads_per_execution                              as disk_reads_per_execution
, executions                                            as total_executions
, rows_processed                                        as rows_processed
, last_active_time                                      as last_active_time
FROM highsql_1_general
)
where rank_by_disk_reads_per_exec <= 10
order by disk_reads_per_execution desc
/

CREATE OR REPLACE VIEW highsql_5_disk_reads_total
--
-- Highest resource SQL based on number of buffer gets per execution
-- Note arbitrary limits in WHERE clause
AS
SELECT
  parsing_schema_name       as parsing_schema
, sql_id                    as sql_id 
, sql_text                  as sql_text
, rank_by_disk_reads_total  as rank
, disk_reads_total          as disk_reads_total
, rows_processed            as rows_processed
, last_active_time          as last_active_time
FROM
( SELECT
  parsing_schema_name
, sql_id                                             as sql_id 
, sql_text                                           as sql_text
, rank() over(order by disk_reads_total desc)        as rank_by_disk_reads_total
, disk_reads_total                                   as disk_reads_total
, rows_processed                                     as rows_processed
, last_active_time                                   as last_active_time
FROM highsql_1_general
)
where rank_by_disk_reads_total <= 10
order by disk_reads_total desc
/

CREATE OR REPLACE VIEW highsql_6_elapse_time_per_exec
--
-- Highest resource SQL based on elapsed_time per execution
-- Note arbitrary limits in WHERE clause
AS
SELECT
  parsing_schema_name                as parsing_schema
, sql_id                             as sql_id 
, sql_text                           as sql_text
, rank_by_elapsed_time_per_exec      as rank
, elapsed_time_per_execution         as elapsed_time_per_execution
, total_executions                   as total_executions
, rows_processed                     as rows_processed
, last_active_time                   as last_active_time
FROM
( SELECT
  parsing_schema_name
, sql_id                                                as sql_id 
, sql_text                                              as sql_text
, rank() over(order by elapsed_time_per_execution desc) as rank_by_elapsed_time_per_exec
, elapsed_time_per_execution                            as elapsed_time_per_execution
, executions                                            as total_executions
, rows_processed                                        as rows_processed
, last_active_time                                      as last_active_time
FROM highsql_1_general
)
where rank_by_elapsed_time_per_exec <= 10
order by elapsed_time_per_execution desc
/

CREATE OR REPLACE VIEW highsql_7_elapsed_time_total
--
-- Highest resource SQL based on number of buffer gets per execution
-- Note arbitrary limits in WHERE clause
AS
SELECT
  parsing_schema_name                as parsing_schema
, sql_id                             as sql_id 
, sql_text                           as sql_text
, rank_by_elapsed_time_total         as rank
, elapsed_time_total                 as elapsed_time_total
, rows_processed                     as rows_processed
, last_active_time                   as last_active_time
FROM
( SELECT
  parsing_schema_name
, sql_id                                                as sql_id 
, sql_text                                              as sql_text
, rank() over(order by elapsed_time_total desc)         as rank_by_elapsed_time_total
, elapsed_time_total                                    as elapsed_time_total
, rows_processed                                        as rows_processed
, last_active_time                                      as last_active_time
FROM highsql_1_general
)
where rank_by_elapsed_time_total <= 10
order by elapsed_time_total desc
/
