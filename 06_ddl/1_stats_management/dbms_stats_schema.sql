/*

 Name:          dbms_stats_schema.sql

 Purpose:       Refresh/rebuild stats at schema level 
  
 Usage:			Key parameter to set each time is 'options' 
 
GATHER: Gathers statistics on all objects in the schema.

GATHER AUTO: Gathers all necessary statistics automatically. Oracle implicitly determines which objects need new statistics and determines how to gather those statistics. When GATHER AUTO is specified, the only additional valid parameters are ownname, stattab, statid, objlist and statown; all other parameter settings are ignored. Returns a list of processed objects.

GATHER STALE: Gathers statistics on stale objects as determined by looking at the *_tab_modifications views. Also, return a list of objects found to be stale.

GATHER EMPTY: Gathers statistics on objects which currently have no statistics. also, return a list of objects found to have no statistics.

LIST AUTO: Returns a list of objects to be processed with GATHER AUTO.
LIST STALE: Returns list of stale objects as determined by looking at the *_tab_modifications views.
LIST EMPTY: Returns list of objects which currently have no statistics.

 Example:       sqlplus -s user/pw@sid @dbms_stats_schema <schema_name>
 
 Limitations:   Potential for locked stats 

Another issue to consider is whether stats are locked at a table or even schema level. By default locked stats will be ignored. See procedures 
		DBMS_STATS.UNLOCK_SCHEMA_STATS(ownname) 
   or   DBMS_STATS.UNLOCK_TABLE_STATS(ownname,tabname) 

   script dbms_stats_unlock_schema.sql will unlock at a schema level  

DBMS_STATS.GATHER_SCHEMA_STATS (
ownname VARCHAR2,
estimate_percent NUMBER DEFAULT to_estimate_percent_type
(get_param('ESTIMATE_PERCENT')),
block_sample BOOLEAN DEFAULT FALSE,
method_opt VARCHAR2 DEFAULT get_param('METHOD_OPT'),
degree NUMBER DEFAULT to_degree_type(get_param('DEGREE')),
granularity VARCHAR2 DEFAULT GET_PARAM('GRANULARITY'),
cascade BOOLEAN DEFAULT to_cascade_type(get_param('CASCADE')),
stattab VARCHAR2 DEFAULT NULL,
statid VARCHAR2 DEFAULT NULL,
options VARCHAR2 DEFAULT 'GATHER',
objlist OUT ObjectTab,
statown VARCHAR2 DEFAULT NULL,
no_invalidate BOOLEAN DEFAULT to_no_invalidate_type (
get_param('NO_INVALIDATE')),
force BOOLEAN DEFAULT FALSE,
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

define script_name = 'dbms_stats_schema'
set verify on
define schema_name  = '&1'
set verify off

--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || lower('&schema_name')	   
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
v_schema_name  varchar2(30);

BEGIN

v_schema_name := '&schema_name';

   dbms_stats.gather_schema_stats(
         ownname          => v_schema_name   -- Schema to generate stats for 
       , estimate_percent => NULL            -- DEFAULT to_estimate_percent_type 
       , block_sample     => FALSE           -- use random sample of rows rather than blocks
       , cascade          => TRUE            -- Ensures stats are created for indexes
       , objlist          => v_obj_list
       , options          => 'GATHER'  
       --, options          => 'GATHER AUTO'  
       --, options          => 'GATHER STALE' 
       --, options          => 'GATHER EMPTY'
	   --, options          => 'LIST AUTO' 
       --, options          => 'LIST STALE' 
	   --, options          => 'LIST EMPTY' 
	   --force              => FALSE 
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
