CREATE OR REPLACE PACKAGE BODY pkg_rman_rep AS
/*

 Name:          cr_pkg_rman_rep_spec.pks

 Purpose:       PL/SQL Package pkg_rman_rep
 
 Usage:         General DBA reporting package
 
 
  Date           Who             Description

 23rd Feb 2017   Aidan Lawrence  RMAN reporting split of from general DBA to allow to run directly within RMAN Catalog schema
 15th Jun 1017   Aidan Lawrence  Validated for git   
 
*/

PROCEDURE rman_rep_rman_report IS

      v_sender     dbarep_parameters.param_value%TYPE;
      v_recipients dbarep_parameters.param_value%TYPE;
      v_subject    dbarep_parameters.param_value%TYPE;
      v_db         dbarep_parameters.param_value%TYPE;
      v_schema     dbarep_parameters.param_value%TYPE;
      v_job_name   dbarep_parameters.param_value%TYPE;

      c_proc_name        CONSTANT dbarep_parameters.param_value%TYPE := 'dba_rep_rman_report';
      c_sender_param     CONSTANT dbarep_parameters.param_value%TYPE := 'RMAN_REPORT_SENDER';
      c_recipients_param CONSTANT dbarep_parameters.param_value%TYPE := 'RMAN_REPORT_RECIPIENTS';
      c_subject_param    CONSTANT dbarep_parameters.param_value%TYPE := 'RMAN_REPORT_SUBJECT';
      c_db_param         CONSTANT dbarep_parameters.param_value%TYPE := 'DB_NAME';
      c_schema_param     CONSTANT dbarep_parameters.param_value%TYPE := 'SCHEMA';
      c_job_name_param   CONSTANT dbarep_parameters.param_value%TYPE := 'RMAN_REPORT_JOB_NAME';

      --v_message        VARCHAR2(32767);
      v_message        clob;
      v_message_header VARCHAR2(4000);


      v_log_date           VARCHAR2(150);
      v_actual_start_date  VARCHAR2(150);
      v_run_duration       VARCHAR2(100);
      v_status             VARCHAR2(100);
      v_start_time         DATE;
      v_end_time           DATE;
      v_success_count      NUMBER;
      v_failure_count      NUMBER;


      --
      -- Constants dictate how many days to report for a given check
      --
      c_failure_check_period CONSTANT NUMBER := 3;
      c_summary_check_period CONSTANT NUMBER := 3;
      --c_detail_check_period CONSTANT NUMBER  := 1;


      --
      -- tables are coming from RMAN Catalog schema. To use in this package you will need to
      -- have run direct grants from that schema to this one and created private synonyms
      --

--
-- Most recent backup times by database - no indication of success/failure on this
--

CURSOR rman_recent_summary_cur IS
SELECT
  NVL(r.priority,99) as priority
--, r.db_name                         as name
, s.db_unique_name                    as db_unique_name
, s.database_role                     as database_role
, NVL(r.host_name,'outstanding')      as host_name
, NVL(r.usage,'outstanding')          as usage
, NVL(r.oracle_release,'outstanding') as release
, MAX(bs.completion_time)             as max_completion_time
, MIN(bs.completion_time)             as min_completion_time
, NVL(r.backup_method,'outstanding')  as backup_method
, NVL(r.description,'outstanding')    as description
FROM
dbarep_roadmap r
LEFT JOIN rc_database  db
ON (db.name = r.db_name)
LEFT JOIN rc_backup_set bs
ON (bs.db_id = db.dbid
AND bs.status = 'A'
)
inner join rc_site s
ON (bs.site_key = s.site_key
AND r.db_unique_name = s.db_unique_name)
GROUP BY
  NVL(r.priority,99)
, r.db_name
, s.db_unique_name
, s.database_role
, NVL(r.host_name,'outstanding')
, NVL(r.usage,'outstanding')
, NVL(r.oracle_release,'outstanding')
, NVL(r.backup_method,'outstanding')
, NVL(r.description,'outstanding')
ORDER BY
 NVL(r.priority,99) asc
, r.db_name
;

--
-- OEM failures in last 'c_failure_check_period' days
--

CURSOR rman_problem_jobs_cur IS
select
  bjd.db_name as name
, bjd.status
, bjd.input_type
, bjd.start_time
, bjd.end_time
, input_bytes_display
, time_taken_display
from
rc_rman_backup_job_details bjd
left join dbarep_roadmap r
ON (bjd.db_name = r.db_name
)
where bjd.start_time >= sysdate - c_failure_check_period
and status <> 'COMPLETED'
and status <> 'RUNNING'
order by
r.priority
, bjd.db_name
, bjd.start_time desc;

/*

--
-- Backup jobs in reporting period 
--

*/

CURSOR rman_backup_job_cur IS
select
  s.db_unique_name
--, bjd.db_name as name
, bjd.status
, bjd.input_type
, bjd.start_time
, bjd.end_time
, input_bytes_display
, output_bytes_display
, time_taken_display
, s.database_role
from
rc_rman_backup_job_details bjd
left join rc_rman_status rs
ON (bjd.session_key = rs.session_key
AND rs.row_level = 0)
left join rc_site s
ON (rs.site_key = s.site_key)
left join dbarep_roadmap r
ON (bjd.db_name = r.db_name
AND s.db_unique_name = r.db_unique_name
)
where bjd.start_time >= sysdate - c_summary_check_period
order by
  r.priority asc
, s.db_unique_name
, bjd.start_time desc;

BEGIN

  --
  -- Setup core email
  --

    SELECT param_value
    INTO   v_sender
    FROM   dbarep_parameters
    WHERE  param_name = c_sender_param
    AND    valid = 'Y';

    SELECT param_value
    INTO   v_recipients
    FROM   dbarep_parameters
    WHERE  param_name = c_recipients_param
    AND    valid = 'Y';

    SELECT param_value
    INTO   v_subject
    FROM   dbarep_parameters
    WHERE  param_name = c_subject_param
    AND    valid = 'Y';

    SELECT param_value
    INTO   v_job_name
    FROM   dbarep_parameters
    WHERE  param_name = c_job_name_param
    AND    valid = 'Y';

    SELECT param_value
    INTO   v_db
    FROM   dbarep_parameters
    WHERE  param_name = c_db_param
    AND    valid = 'Y';

    SELECT param_value
    INTO   v_schema
    FROM   dbarep_parameters
    WHERE  param_name = c_schema_param
    AND    valid = 'Y';


    v_message := null;
    v_subject := v_subject
                || ' on ' || TO_CHAR(sysdate,'Dd FMMonth YYYY');

    v_message_header := '<head>
                          <STYLE TYPE="text/css">
                          <!--
                          TH{font-family: Verdada; font-size: 10pt; font-weight: bold}
                          TD{font-family: Verdada; font-size: 10pt;}
                          --->
                          </STYLE>
                          </head>';

    v_message_header := v_message_header||'<body><font face="Verdana" size="2">';


--
-- Start table of individual report
--

v_message := v_message    || '<br><hr>RMAN Recent Backup summary<br>';

v_message := v_message||'<table border="1" width="99%" font face="Verdana" size ="2">';

v_message := v_message||'<tr><th width="5%">Report Priority</th>'
                      --||'<th width="10%">Database Name</th>'
                      ||'<th width="10">Database Unique Name</th>'
                      ||'<th width="15%">Newest Completion Time</th>'
                      ||'<th width="15%">Oldest Completion Time</th>'
                      ||'<th width="15%">Description </th>'
                      ||'<th width="15%">Host Name </th>'
                      ||'<th width="10%">Usage </th>'
                      ||'<th width="5%">Release </th>'
                      ||'<th width="10%">Database Role</th>'
                      --||'<th width="10%">Backup Method </th>'
                      ;


FOR rman_recent_summary_rec IN rman_recent_summary_cur
LOOP

v_message := v_message
            || '<tr>'
            || '<td>' || rman_recent_summary_rec.priority             ||'</td>'
            --|| '<td>' || rman_recent_summary_rec.name                 ||'</td>'
            || '<td>' || rman_recent_summary_rec.db_unique_name       ||'</td>'
            || '<td>' || NVL(TO_CHAR(rman_recent_summary_rec.max_completion_time,'Dy DD-MON-YYYY HH24:MI:SS'),'Not Catalogued') ||'</td>'			
			|| '<td>' || NVL(TO_CHAR(rman_recent_summary_rec.min_completion_time,'Dy DD-MON-YYYY HH24:MI:SS'),'Not Catalogued') ||'</td>'			
            || '<td>' || rman_recent_summary_rec.description          ||'</td>'
            || '<td>' || rman_recent_summary_rec.host_name            ||'</td>'
            || '<td>' || rman_recent_summary_rec.usage                ||'</td>'
            || '<td>' || rman_recent_summary_rec.release              ||'</td>'
			|| '<td>' || rman_recent_summary_rec.database_role        ||'</td>'
            --|| '<td>' || rman_recent_summary_rec.backup_method        ||'</td>'
            ||'</tr>'
            ;
END LOOP;

v_message := v_message ||'</table><br> ';

--
-- End of individual report
--

--
-- Start table of individual report
--
v_message := v_message    || '<br><hr>RMAN Problem Backup Jobs - last '
                          || c_failure_check_period
                          || ' days<br>';

v_message := v_message||'<table border="1" width="90%" font face="Verdana" size ="2">';

v_message := v_message||'<tr><th width="10%">Database Name</th>'
                      ||'<th width="15%">Status </th>'
                      ||'<th width="15%">Input Type </th>'
                      ||'<th width="20%">Start Time </th>'
                      ||'<th width="20%">End Time </th>'
                      ||'<th width="10%">Input Bytes </th>'
                      ||'<th width="10%">Time Taken </th>'
                      ;

FOR rman_problem_jobs_rec IN rman_problem_jobs_cur
LOOP

v_message := v_message
            || '<tr>'
            || '<td>' || rman_problem_jobs_rec.name                     ||'</td>'
            || '<td>' || rman_problem_jobs_rec.status                    ||'</td>'
            || '<td>' || rman_problem_jobs_rec.input_type                ||'</td>'
            || '<td>' || TO_CHAR(rman_problem_jobs_rec.start_time,'Dy DD-MON-YYYY HH24:MI:SS') ||'</td>'
            || '<td>' || TO_CHAR(rman_problem_jobs_rec.end_time,'Dy DD-MON-YYYY HH24:MI:SS') ||'</td>'
            || '<td>' || rman_problem_jobs_rec.input_bytes_display        ||'</td>'
            || '<td>' || rman_problem_jobs_rec.time_taken_display        ||'</td>'
            ||'</tr>'
            ;

END LOOP;

v_message := v_message ||'</table><br> ';

--
-- End of individual report
--

--
-- Start table of individual report
--
v_message := v_message    || '<br><hr>RMAN Backup Jobs - last '
                          || c_summary_check_period
                          || ' days<br>';

v_message := v_message||'<table border="1" width="90%" font face="Verdana" size ="2">';

v_message := v_message||'<tr><th width="10%">Database Name</th>'
                      ||'<th width="10%">Database Role</th>'
                      ||'<th width="15%">Status </th>'
                      ||'<th width="15%">Input Type </th>'
                      ||'<th width="15%">Start Time </th>'
                      ||'<th width="15%">End Time </th>'
                      ||'<th width="5%">Input Bytes </th>'
                      ||'<th width="5%">Output Bytes </th>'
                      ||'<th width="10%">Time Taken </th>'
                      ;

FOR rman_backup_job_rec IN rman_backup_job_cur
LOOP

v_message := v_message
            || '<tr>'
            || '<td>' || rman_backup_job_rec.db_unique_name            ||'</td>'
            || '<td>' || rman_backup_job_rec.database_role             ||'</td>'
            || '<td>' || rman_backup_job_rec.status                    ||'</td>'
            || '<td>' || rman_backup_job_rec.input_type                ||'</td>'
            || '<td>' || TO_CHAR(rman_backup_job_rec.start_time,'Dy DD-MON-YYYY HH24:MI:SS') ||'</td>'
            || '<td>' || TO_CHAR(rman_backup_job_rec.end_time,'Dy DD-MON-YYYY HH24:MI:SS') ||'</td>'
            || '<td>' || rman_backup_job_rec.input_bytes_display       ||'</td>'
            || '<td>' || rman_backup_job_rec.output_bytes_display      ||'</td>'
            || '<td>' || rman_backup_job_rec.time_taken_display        ||'</td>'
            ||'</tr>'
            ;

END LOOP;

v_message := v_message ||'</table><br> ';

--
-- End of individual report
--

v_message := v_message ||'</table><br><i>Email generated for '
                       || v_schema || '@' || v_db
                       || ' for module '
                       || pkg_rman_rep.c_package_name
                       || '.'
                       || c_proc_name
                       || '</i></body>';


    utl_mail.send        (sender      => v_sender,
                          recipients  => v_recipients,
                          subject     => v_subject,
                          message     => v_message,
                          mime_type => 'text/html; charset=us-ascii'
                          );

  EXCEPTION

  WHEN VALUE_ERROR
      THEN

      -- This will occur if there is simply too much detail coming through
      -- In this scenario just take 'most' of the initial data and try finish off the report cleanly

      v_message := SUBSTR(v_message,1,30000);

      v_message := v_message ||'</table><br> ';

      v_message := v_message ||'</table><br><i>Full report truncated due to volume of data causing ORA-6502 value error. To check manually the SQL statements can be be run manually - check out the package as described below. If this error occurs repeatedly consider adjusting the data going into the report. Email generated for '
                       || v_schema || '@' || v_db
                       || ' for module '
                       || pkg_rman_rep.c_package_name
                       || '.'
                       || c_proc_name
                       || '</i></body>';

        utl_mail.send    (sender      => v_sender,
                          recipients  => v_recipients,
                          subject     => v_subject,
                          message     => v_message,
                          mime_type => 'text/html; charset=us-ascii'
                          );


  WHEN OTHERS
      THEN

        v_message :=  'Unknown Error ' || SQLERRM;

        utl_mail.send    (sender      => v_sender,
                          recipients  => v_recipients,
                          subject     => v_subject,
                          message     => v_message,
                          mime_type => 'text/html; charset=us-ascii'
                          );


end rman_rep_rman_report;

END pkg_rman_rep;
/
