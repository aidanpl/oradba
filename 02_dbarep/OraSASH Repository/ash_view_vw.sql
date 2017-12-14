/*

 Name:          ash_view_vw.sql

 Purpose:       Active Session History views 

 Usage:         A series for views typically called from front end 
				Requires Diagnostic Pack or OraSASH implementation 
				Not Aidan add on OraSASH links to v$session_target - see 0_switch_db.sql for further information 

 Implementation Typically run under 'sash' type user assuming OraSASH
 
 Next Steps:

 Date            Who             Description

  5th Jan 2016   Aidan Lawrence  cloned from similar
  9th Mar 2016   Aidan Lawrence  Further development with link to v$session_target
  9th Aug 2017   Aidan Lawrence  Revalidated for git  

*/

CREATE OR REPLACE VIEW ash_1_wait_last_5
--
-- Sessions by WAIT last 5 minutes 
-- 
AS
select 
  instance_name
, session_count
, event 
, sql_text 
, session_id
, NVL(username,'(None)') as username
, program
, osuser
, machine
from
(
select 
  i.instance_name
, ash.session_id
, ash.session_type 
, ash.event
, sq.sql_id 
, sq.sql_text 
, s.osuser
, s.username
, s.program
, s.machine
, count(*) as session_count
from v$active_session_history ash
join v$sql sq
ON sq.sql_id = ash.sql_id
left join v$session_target s 
on (ash.session_id = s.sid
and ash.session_serial# = s.serial#
   )
cross join v$instance i   
where ash.session_state='WAITING'  and
 ash.sample_time >  sysdate - interval '5' minute
group by 
  i.instance_name
, ash.session_id
, ash.session_type
, ash.event 
, sq.sql_id 
, sq.sql_text 
, s.osuser
, s.username
, s.program
, s.machine
order by count(*) desc
)
where rownum <= 10;
/

CREATE OR REPLACE VIEW ash_2_cpu_last_5
--
-- Sessions by CPU ast 5 minutes 
-- 
AS
select 
  instance_name
, session_count
, session_id
, pctload
, NVL(username,'(None)') as username
, program
, osuser
, machine
, sql_text 
from
(
select 
  i.instance_name
, ash.session_id
, sq.sql_id 
, s.osuser
, s.username
, s.program
, s.machine
, sq.sql_text 
, round(count(*)/sum(count(*)) over (), 2) as pctload
, count(*) as session_count
from v$active_session_history ash
join v$sql sq
ON sq.sql_id = ash.sql_id
left join v$session_target s 
on (ash.session_id = s.sid
and ash.session_serial# = s.serial#
   )
cross join v$instance i   
where ash.session_state='ON CPU'  and
 ash.sample_time >  sysdate - interval '5' minute
group by 
  i.instance_name
, ash.session_id
, sq.sql_id 
, sq.sql_text 
, s.osuser
, s.username
, s.program
, s.machine
order by count(*) desc
)
where rownum <= 10
/


CREATE OR REPLACE VIEW ash_3_active_sql_last_5
--
-- Active SQL in last 5 minutes 
-- 
AS
select 
  instance_name
, sql_count
, pctload  
, sql_text 
from
(
select 
  i.instance_name
, count(*) as sql_count 
, round(count(*)/sum(count(*)) over (), 2) as pctload
, sq.sql_text 
from v$active_session_history ash
join v$sql sq
ON sq.sql_id = ash.sql_id
cross join v$instance i   
where ash.session_type <> 'BACKGROUND' 
and ash.sample_time >  sysdate - interval '5' minute
group by 
  i.instance_name
, sq.sql_text 
order by count(*) desc
)
/

CREATE OR REPLACE VIEW ash_4_cursor_waits_last_60
--
-- Cursor Wait counts in last Hour
-- 
AS
SELECT 
  instance_name as "Instance"
, sample_point as "Sample Time"
, event    as "Event"
, count(*) as "Event Wait Count"
FROM 
(select d.instance_name
, to_char(ash.sample_time,'HH24:MI') as sample_point
, ash.event
from v$active_session_history ash
JOIN v$database d
ON ash.dbid = d.dbid
where ash.event IN ('cursor: mutex S', 'cursor: pin S')
and ash.session_state='WAITING'  
and ash.sample_time >  sysdate - interval '1' HOUR
)
group by instance_name
, sample_point
, event
order by instance_name
, sample_point desc
, event asc
/



CREATE OR REPLACE VIEW ash_5_sessions_last_60
--
-- Session counts in last Hour
-- 
AS
SELECT 
   d.instance_name        as "Instance"
, a1.sample_point         as "Sample"
, a1.session_count        as "All Session Count"
, NVL(a2.session_count,0) as "All Session Wait Count" 
, NVL(a3.session_count,0) as "All Session Cursor Wait Count"
FROM 
v$database d
CROSS JOIN
-- a1 view is all sessions 
(SELECT 
sample_point
, count(*) as session_count
FROM 
(select to_char(ash.sample_time,'HH24:MI') as sample_point
from v$active_session_history ash
where ash.sample_time >  sysdate - interval '1' HOUR
)
group by sample_point
) a1
LEFT JOIN
-- a2 view is all sessions in waiting state
(SELECT 
sample_point
, count(*) as session_count
FROM 
(select to_char(ash.sample_time,'HH24:MI') as sample_point
from v$active_session_history ash
where ash.session_state='WAITING'  
and ash.sample_time >  sysdate - interval '1' HOUR
)
group by sample_point
) a2
ON a1.sample_point = a2.sample_point
LEFT JOIN
-- a3 view is all sessions in waiting state for cursors
(SELECT 
sample_point
, count(*) as session_count
FROM 
(select to_char(ash.sample_time,'HH24:MI') as sample_point
from v$active_session_history ash
where ash.event IN ('cursor: mutex S', 'cursor: pin S')
and ash.session_state='WAITING'  
and ash.sample_time >  sysdate - interval '1' HOUR
)
group by sample_point
) a3
ON a1.sample_point = a3.sample_point
order by a1.sample_point desc
/


/*

-- Non view SQL - cannot have parameterized views without a lot of messing around with packages in Oracle

--
-- Most Active SQL in last 5 minutes 
-- 
SELECT 
  DISTINCT 
  ash.sql_id
, sq.sql_text
, ash.session_serial#
FROM v$active_session_history ash
join v$sql sq
on ash.sql_id = sq.sql_id
WHERE sample_time > sysdate - interval '5' minute
AND session_id    =  &sid
/

*/

