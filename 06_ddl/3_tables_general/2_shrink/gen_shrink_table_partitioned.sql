/*

 Name:          Run gen_shrink_table_partitioned.sql

 Purpose:       Generate table shrink commands for a partitioned individual table 

 Usage:         gen_shrink_table_partitioned.sql <schema> <table_name>
			
				Simple shrink of tables - commonly to reclaim space/reset a highwatermark after data purges. See Oracle DBA Administraters guide - 'Reclaiming Wasted Space' for further information.

 Limitations:   Not all tables/partitions may be shrunk. See Oracle documentation for limitations
				example http://docs.oracle.com/database/121/ADMIN/schema.htm#ADMIN10161 
				
				The example below uses the SALES table in the SH sample schema. In practice this gives an error as the same schema contains materialized views against this table - which prevents the shrinkage. The other partitioned table in the sample schemas is COSTS - this fails as it is an example of a compressed table - also a limitation. But you get the idea..

				Sample output :
 
				spool gen_shrink_table_partitions_SALES.log
				Set time on
				Set timing on
				Set echo on
				ALTER TABLE SALES ENABLE ROW MOVEMENT;
				ALTER TABLE SALES MODIFY PARTITION SALES_1995 SHRINK SPACE ;
				ALTER TABLE SALES MODIFY PARTITION SALES_1996 SHRINK SPACE ;
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

spool gen_shrink_table_partioned_&schema._&table_name

SELECT 'spool gen_shrink_table_partitioned_&schema._&table_name..log'
from dual
/

SELECT 'Set time on' from dual;
SELECT 'Set timing on' from dual;
SELECT 'Set echo on' from dual;

--
-- Consider a first run with  COMPACT if performing this against a heavily fragmented table - see Oracle docs as mentioned above 

SELECT 'ALTER TABLE ' 
|| t.owner || '.'
|| tp.table_name || ' MODIFY PARTITION '
|| tp.partition_name || ' SHRINK SPACE'
-- || ' COMPACT'
|| ';'
FROM dba_tab_partitions tp 
JOIN dba_tables t
ON t.owner = tp.table_owner
AND t.table_name = tp.table_name
WHERE t.owner = '&schema'
AND t.table_name = '&table_name'
ORDER BY tp.partition_name
/

SELECT 'Set echo off' from dual;
SELECT 'Spool off' from dual;
SELECT 'exit' from dual;

spool off
exit
