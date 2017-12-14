/*

 Name:          cursor_tune_vw.sql

 Purpose:       Views for investigaing cursor tuning issues 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 Implementation Typically run under 'dbmon' type user. Initially cloned from tune_ck etc. etc. 
 
GRANT SELECT ON v_$statname              to DBMON;
GRANT SELECT ON v_$sesstat               to DBMON;
GRANT SELECT ON v_$parameter             to DBMON;
GRANT SELECT ON v_$open_cursor           to DBMON;
GRANT SELECT ON v_$sqltext_with_newlines to DBMON;


 Note specific requirement for availability of table VW_PARAMETERS in DBMON - see commments in view definitions. 
 
 Next Steps:

 Date            Who             Description

  9th May 2017   Aidan Lawrence  Cloned from similar
  4th Jul 2017   Aidan Lawrence  Validated pre git publication 
*/



/*

prompt
prompt SQL with open cursor count above a threshold 

Identify sids with open cursors above a threshold.
Note as this is a view the threshold cannot easily be passed as a parameter.
The alternative is to store this in an arbitrary 'constants' table 
See reference to SELECT open_cursor_threshold FROM vw_parameters

If not present then create it with something like 

CREATE TABLE vw_parameters
(open_cursor_threshold number
);

INSERT INTO vw_parameters
(open_cursor_threshold)
VALUES
(100);

COMMIT;
                               
*/
 
CREATE OR REPLACE VIEW cur_1_open_threshold_count_sql
AS
SELECT 
  o.sid
, o.user_name
, t.piece
, t.sql_text
, COUNT(*) as cursor_count 
FROM v$open_cursor o
JOIN v$sqltext_with_newlines t
ON o.sql_id = t.sql_id
WHERE (o.sid,o.sql_id) IN 
(
SELECT 
sid, 
sql_id
FROM v$open_cursor
group by sid, sql_id
HAVING COUNT(*) > (SELECT open_cursor_threshold FROM vw_parameters)
)
group by o.sid, o.user_name, t.hash_value, t.piece, t.sql_text
order by o.sid, o.user_name, t.hash_value, t.piece;
/

--
--Show the highest number of open current cursors in a given session
--
CREATE OR REPLACE VIEW cur_2_highest_open_current
AS
SELECT
  MAX(b.value) AS highest_open_cur 
, p.value      AS max_open_cur
FROM v$statname a 
JOIN v$sesstat b 
ON a.statistic# = b.statistic#
CROSS JOIN  v$parameter p
WHERE a.name         = 'opened cursors current'
AND p.name         = 'open_cursors'
GROUP BY p.value;
