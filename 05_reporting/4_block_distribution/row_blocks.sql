/*

 Name:          row_blocks.sql

 Purpose:       Show block distribution across extents for a given table 

 Usage:         @row_blocks.sql <table_owner> <table_name>

 Example:       sqlplus -s user/pw@sid @row_blocks.sql SH SALES 
 
 Sample Output 
 
   File   Block  Num
    No.     No. Rows
------- ------- ----
      9    3602  605
      9    3603  590
      9    3604  615
      9    3605  615

 
 Date            Who             Description

 22nd Sep 2015   Aidan Lawrence  Clean version based around Carl's original LTREE script 
 14th Jun 2017   Aidan Lawrence  Validated pre git publication 

*/

-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'row_blocks'
define table_owner  = '&1'
define table_name  = '&2'

--
-- Set the Spool output name as combination of script, database, parameters and time
--

col spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || '&table_owner'
       || '_'	   	   
       || '&table_name'
       || '_'	   
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI')
       || '.lst' spool_name
  from v$database d;

select 'Output report name is '
       || '&spool_name'
  from dual;

spool &spool_name

prompt
prompt Report Details are &spool_name

set heading off
set feedback off 

SELECT 'Database Name: ' || value FROM v$parameter where name='db_name'
/

SELECT 'Generated On ' ||  to_char(sysdate,'dd Month YYYY  HH24:MI') today from dual
/

set heading on
set feedback on 

prompt
prompt ################################################
prompt #                                              #
prompt #  Oracle row blocks Report                    #
prompt #                                              #
prompt ################################################
prompt


SELECT dbms_rowid.rowid_relative_fno(ROWID)  as file_id
      ,dbms_rowid.rowid_block_number(rowid)  as block_no
      ,COUNT(*) AS Num_rows 
FROM &table_owner..&table_name
GROUP BY dbms_rowid.rowid_relative_fno(ROWID)
        ,dbms_rowid.rowid_block_number(ROWID)
ORDER BY dbms_rowid.rowid_relative_fno(ROWID)
        ,dbms_rowid.rowid_block_number(ROWID);		
		
CLEAR columns

prompt end of report

spool off


-- Can turn the edit on if running script manurowy - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit

