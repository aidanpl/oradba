/*

 Name:          Run gen_shrink_table_non_partitioned.sql

 Purpose:       Generate table shrink command for a non-partitioned individual table 

 Usage:         gen_shrink_table_non_partitioned.sql <schema> <table_name>
			
				Simple shrink of tables - commonly to reclaim space/reset a highwatermark after data purges. See Oracle DBA Administraters guide - 'Reclaiming Wasted Space' for further information.
 
				Sample output :
 
				spool gen_shrink_table_HR_COUNTRIES.log
				Set time on
				Set timing on
				Set echo on
				ALTER TABLE SALES ENABLE ROW MOVEMENT;
				ALTER TABLE HR.COUNTRIES SHRINK SPACE;
				Set echo off
				Spool off
				exit				
				
				
				Note mention of the option 'COMPACT' in the documentation if working with a heavily fragmented table on a busy system. Good practice to perform the shrink in two phases:

				1) ALTER TABLE HR.COUNTRIES SHRINK SPACE COMPACT;

				From the Oracle documenation:
				
				The COMPACT clause lets you divide the shrink segment operation into two phases. When you specify COMPACT, Oracle Database defragments the segment space and compacts the table rows but postpones the resetting of the high water mark and the deallocation of the space until a future time. This option is useful if you have longrunning queries that might span the operation and attempt to read from blocks that have been reclaimed.The defragmentation and compaction results are saved to disk, so the data movement does not have to be redone during the second phase. You can reissue the SHRINK SPACE clause without the COMPACT clause during offpeak hours to complete the second phase.
			
				2) ALTER TABLE HR.COUNTRIES SHRINK SPACE;
				
 
 Example:       sqlplus -s user/pw@sid @gen_shrink_table.sql DEPT 
 
				
 
 Limitations:   See other scripts for tables with partitions, LOBS or IOTs

 Sanity checks: Before running this, check for any invalid indexes using invalid_index_ck.sql 
				
 Sample output :

 Date            Who             Description

 29th Apr 2008  Aidan Lawrence   Initial build 
 24th Oct 2017  Aidan Lawrence   Validated pre git publication 

*/

set lines 132
set pages 0
set feedback off
set verify off
set echo off

define schema  = '&1'
define table_name  = '&2'

spool gen_shrink_table_&schema._&table_name

SELECT 'spool gen_shrink_table_&schema._&table_name..log'
from dual
/

SELECT 'Set time on' from dual;
SELECT 'Set timing on' from dual;
SELECT 'Set echo on' from dual;

--
-- Enable row movement 

SELECT 'ALTER TABLE ' 
|| t.table_name || ' ENABLE ROW MOVEMENT'
|| ';'
FROM dba_tables t
WHERE t.owner = '&schema'
AND t.table_name = '&table_name'
/


--
-- Consider a first run with  COMPACT if performing this against a heavily fragmented table - see Oracle docs as mentioned above 

SELECT 'ALTER TABLE ' 
|| t.owner || '.'
|| t.table_name || ' SHRINK SPACE'
-- || ' COMPACT'
|| ';'
FROM 
  dba_tables t
WHERE t.owner = '&schema'
AND t.table_name = '&table_name'

/

SELECT 'Set echo off' from dual;
SELECT 'Spool off' from dual;
SELECT 'exit' from dual;

spool off
exit
