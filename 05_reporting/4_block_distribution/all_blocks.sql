/*

 Name:          all_blocks.sql

 Purpose:       Show block distribution across extents for a given table 

 Usage:         @all_blocks.sql <table_owner> <table_name>

 Example:       sqlplus -s user/pw@sid @all_blocks.sql SH CUSTOMERS 

 Sample Output 
 
                                                      File  Extent   Start    Block
Owner                          Segment                Id.     Id.   Block    Count
------------------------------ -------------------- ----- ------- ------- --------
SH                             CUSTOMERS                9       0    1800        8
SH                                                      9       1    1808        8
SH                                                      9       2    1816        8
SH                                                      9       3    1824        8
..
..
  
 Date            Who             Description

 22nd Sep 2015   Aidan Lawrence  Enhanced from DBA Training course script 
 14th Jun 2017   Aidan Lawrence  Validated pre git publication 

*/
			
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'all_blocks'
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
prompt

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
prompt #  Oracle All blocks Report                    #
prompt #                                              #
prompt ################################################
prompt


BREAK ON segment_name
COMPUTE SUM OF blocks ON segment_name

SELECT  owner
      , segment_name
      , file_id	  
      , extent_id
      , block_id Start_block
      , blocks
FROM dba_extents
WHERE owner = UPPER('&table_owner')
AND segment_name = UPPER('&table_name')
ORDER BY file_id
        ,extent_id;
CLEAR COMPUTES

prompt end of report

spool off
-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
