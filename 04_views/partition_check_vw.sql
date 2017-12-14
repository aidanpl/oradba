/*

 Name:          sh_partition_check.sql

 Purpose:       View to check how many days ahead the daily SH partitions are. 
 
				Tweak for specific naming standards in a given schema 

 Usage:         A series for views typically called from front end perl/cgi etc. etc.

 Date            Who             Description

 12th May 2015   Aidan Lawrence  Example for git 

*/

CREATE OR REPLACE VIEW sh_partition_ck
AS
SELECT
  table_name
, max_created_date - trunc(sysdate) as days_ahead
from (
SELECT table_name
, MAX(to_date(SUBSTR(partition_name,3,10),'yyyy-mm-dd')) as max_created_date
FROM all_tab_partitions
WHERE table_owner = 'SH'
AND vsize(partition_name) = 12
group by table_name)
order by table_name
/


