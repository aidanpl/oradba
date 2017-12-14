/*

 Name:          dbms_stats_dictionary.sql

 Purpose:       Refresh dictionary stats 
 
				DBMS_STATS.GATHER_DICTIONARY_STATS will gather stats for SYS, SYSTEM and other Oracle supplied schemas. The parameters are similar to GATHER_SCHEMA_STATS with comp_id replacing ownname in terms of specific schemas 
 
 
 Usage:			sqlplus -s sys/pw@sid as sysdba @dbms_stats_dictionary
 

 DBMS_STATS.GATHER_DICTIONARY_STATS (
comp_id VARCHAR2 DEFAULT NULL,
estimate_percent NUMBER DEFAULT to_estimate_percent_type
(get_param('ESTIMATE_PERCENT')),
block_sample BOOLEAN DEFAULT FALSE,
method_opt VARCHAR2 DEFAULT get_param('METHOD_OPT'),
degree NUMBER DEFAULT to_degree_type(get_param('DEGREE')),
granularity VARCHAR2 DEFAULT GET_PARAM('GRANULARITY'),
cascade BOOLEAN DEFAULT to_cascade_type(get_param('CASCADE')),
stattab VARCHAR2 DEFAULT NULL,
statid VARCHAR2 DEFAULT NULL,
options VARCHAR2 DEFAULT 'GATHER AUTO',
objlist OUT ObjectTab,
statown VARCHAR2 DEFAULT NULL,
no_invalidate BOOLEAN DEFAULT to_no_invalidate_type (
get_param('NO_INVALIDATE')),
obj_filter_list ObjectTab DEFAULT NULL);
 
				
 Date            Who             Description

 20th Jun 2005   Aidan Lawrence  Cloned from similar
 13th Jul 2017   Aidan Lawrence  Refreshed/revalidated pre git publication 								 
 
*/

set heading off
set verify off
set pages 99
set feedback off
set trimspool on
set linesize 132
set termout off

column connection new_value cname
SELECT lower(user) || '@' || instance_name connection
FROM v$instance;
set sqlprompt '&cname> '

define script_name = 'dbms_stats_dictionary'

--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI')
       || '.lst' spool_name
  from v$database d;

select 'Output report name is '
       || '&spool_name'
  from dual;

-- Adjust environment for specific scripts
--

set verify on
set feedback on
set termout on
set heading on
set echo on 
set time on
set serveroutput on


spool &spool_name

DECLARE

v_obj_list     DBMS_STATS.objecttab;

BEGIN

   dbms_stats.gather_dictionary_stats(
         comp_id          => NULL  -- Can optionally specify a specific schema
       , estimate_percent => NULL  -- default analyze 20 percent of rows
       , block_sample     => FALSE -- use random sample of rows rather than blocks
       , cascade          => TRUE       -- Ensures stats are created for indexes
       , objlist          => v_obj_list
       , options          => 'GATHER AUTO'  
       --, options          => 'GATHER'  
       --, options          => 'GATHER STALE' 
	   --, options          => 'LIST AUTO' 
       --, options          => 'LIST STALE' 
	   --, options          => 'LIST EMPTY' 
       --method_opt         => 
       --degree             => 
       --granularity        => 
     );
     
IF (v_obj_list.COUNT = 0)
THEN
   DBMS_OUTPUT.put_line ('No objects to generate stats for.');
ELSE
   FOR i IN 1 .. v_obj_list.COUNT
   LOOP
      DBMS_OUTPUT.put_line (   v_obj_list (i).objtype
                            || ' '
                            || v_obj_list (i).ownname
                            || '.'
                            || v_obj_list (i).objname
                            --|| ', partition:'
                            --|| v_obj_list (i).partname
                            --|| ', sub part.:'
                            --|| v_obj_list (i).subpartname
                           );
   END LOOP;
END IF;     
     
END;
/

spool off
exit
