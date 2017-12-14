/*

 Name:          report_tune_header_vw.sql

 Purpose:       Trivial head for general tuning reports 

--
--  Required direct Grants for view creations

GRANT SELECT ON v_$database    TO dbmon;
 
 Next Steps:

 Date            Who             Description

 3rd Feb 2016    Aidan Lawrence  Ongoing improvements
 27th Jun 2017   Aidan Lawrence  Validated pre git publication        

*/

CREATE OR REPLACE VIEW report_tune_header
AS 
SELECT 
' Report for '
|| d.db_unique_name 
|| ' on server '
|| i.host_name 
|| ' generated at ' 
|| to_char(sysdate,'HH24:MI:SS')
|| ' on '
|| to_char(sysdate,'Dy DD-Mon-YYYY')
as report_header
FROM v$database d
CROSS JOIN v$instance i
/

