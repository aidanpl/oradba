/*

 Name:          all_blocks_single_file.sql

 Purpose:       Show block distribution across extents for a given file

 Usage:         @all_blocks_single_file <file_name>
 
 Example:       sqlplus -s user/pw@sid @all_blocks_single_file.sql /data/oradata/dbarep/sample_schemas_01.dbf
 
 Sample output:
                                                                                              File  Extent      Start      Block
Owner                          Segment                        Partition                        Id.     Id.      Block      Count   HWM (Mb)
------------------------------ ------------------------------ ------------------------------ ----- ------- ---------- ---------- ----------
HR                             COUNTRY_C_ID_PK                                                   9       0        128          8          1
HR                             REGIONS                                                                   0        136          8          1
HR                             REG_ID_PK                                                                 0        144          8          1
HR                             LOCATIONS                                                                 0        152          8          1
HR                             LOC_ID_PK                                                                 0        160          8          1
HR                             DEPARTMENTS                                                               0        168          8          1
..
..
HR                             LOC_COUNTRY_IX                                                            0        320          8          3
OE                             ACTION_TABLE                                                              0        328          8          3
OE                             LINEITEM_TABLE                                                            0        360          8          3
OE                             SYS_LOB0000109398C00005$$                                                 0        368          8          3
..

 Date            Who             Description

 22nd Sep 2015   Aidan Lawrence  Developed from 'all_blocks'
 14th Jun 2017   Aidan Lawrence  Validated pre git publication 


*/

-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'all_blocks_single_file'
define file_name  = '&1'

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

--
-- Get file_id from file_name 
column file_ident new_value file_ident noprint;

SELECT file_id as file_ident 
from dba_data_files
where file_name = '&file_name';

--column sub_file_name new_value sub_file_name noprint;
column sub_file_name new_value sub_file_name;

select substr(
file_name
, final_slash + 1 
, full_stop - final_slash - 1
) as sub_file_name
from 
( select file_name 
, instr(file_name,'/',-1) as final_slash
, instr(file_name,'.',-1) as full_stop 
from dba_data_files
where file_name = '&file_name'
);

--
-- Set the Spool output name as combination of script, database, file_name and time
--

column spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || '&sub_file_name'
       || '_'	   
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI')
       || '.lst' spool_name
  from v$database d;

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
prompt #  Oracle File Extents location Report         #
prompt #                                              #
prompt ################################################
prompt

BREAK ON file_id
COMPUTE SUM OF blocks ON file_id

SELECT  e.owner
      , e.segment_name
      , e.partition_name
      , e.file_id	  
      , e.extent_id
      , e.block_id Start_block
      , e.blocks
	  , round((e.block_id + blocks) * (t.block_size/1048976),1) as hwm_mbytes
FROM dba_extents e
JOIN dba_tablespaces t
ON (e.tablespace_name = t.tablespace_name)
WHERE file_id = &file_ident
ORDER BY start_block;

CLEAR COMPUTES

prompt end of report

spool off
-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit
