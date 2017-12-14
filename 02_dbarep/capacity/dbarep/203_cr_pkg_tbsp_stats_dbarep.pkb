CREATE OR REPLACE PACKAGE BODY pkg_tbsp_stats_dbarep AS

/*

 Name:          cr_pkg_tbsp_stats_dbarep.pkb

 Purpose:       PL/SQL Package tbsp_stats

 Usage:         To centralise remote tbsp_stats capacity planning
 
 Comments:

  Date            Who             Description

  4th Mar 2013   Aidan Lawrence  Cloned from similar
 26th Mar 2013   Aidan Lawrence  Added in exception processing to cleanly process ORA-06502 value_error - typically when volume of detail is too much.
  5th Apr 2016   Aidan Lawrence  Renamed and cleaned up dbarep version 
 28th Jun 2017   Aidan Lawrence  Validated pre git  
 
*/



PROCEDURE pop_tbsp_stats_db  (
								db_name_in         IN dbarep_roadmap.db_name%TYPE
							  , monitor_db_link_in IN dbarep_roadmap.monitor_db_link%TYPE
							  , run_date_in        IN tbsp_stats.generated_date%TYPE
							 )

IS

      v_tbsp_stats_sql               varchar2(4000);
      v_message                      varchar2(4000);
      c_tbsp_stats_sql_at            char(1)        := '@';

--
--    Components for removing existing tbsp_stats for dbname/run_date
--

      v_tbsp_stats_delete_core      varchar2(4000) := 'DELETE FROM tbsp_stats';
	  v_tbsp_stats_delete_dbname_in varchar2(4000) := ' WHERE dbname = ';
	  v_tbsp_stats_delete_date      varchar2(4000) := ' AND TRUNC(generated_date) = TRUNC(sysdate)'; 
            
          
--
--    Components for inserting new data to tbsp_stats
--

      v_tbsp_stats_insert_core_ins varchar2(4000) := 'INSERT INTO tbsp_stats(  dbname, generated_date, tablespace_name, Bytes_used, Bytes_max, Bytes_free, extra_extents, Bytes_max_no_extend, Bytes_free_no_extend, extra_extents_no_extend, largest_next_extent) ';
      v_tbsp_stats_insert_core_sel varchar2(4000) :=                  'SELECT  dbname, generated_date, tablespace_name, Bytes_used, Bytes_max, Bytes_free, extra_extents, Bytes_max_no_extend, Bytes_free_no_extend, extra_extents_no_extend, largest_next_extent FROM tbsp_stats';
      v_tbsp_stats_insert_where    varchar2(4000) := ' WHERE TRUNC(generated_date) = TRUNC(sysdate)'; -- ** APL ** think about the limitation of this 



BEGIN

		--
		-- Delete any entries on local tbsp_stats for this database/run date
		--
		-- Build the statement to execute 
		
		v_tbsp_stats_sql          := v_tbsp_stats_delete_core 
								  || v_tbsp_stats_delete_dbname_in
								  || ''''
								  || db_name_in
								  || ''''
								  --|| v_tbsp_stats_delete_date
								  ;
								  
        --
		-- Execute it:
		
		dbms_output.put_line ('sql is: ' || v_tbsp_stats_sql);
										
		EXECUTE IMMEDIATE v_tbsp_stats_sql;								  

		-- Populate local tbsp_stats from remote database 
		--
		-- Build the statement to execute 
		--
		v_tbsp_stats_sql          := v_tbsp_stats_insert_core_ins 
								  || v_tbsp_stats_insert_core_sel
								  || c_tbsp_stats_sql_at
								  || monitor_db_link_in
								  --|| v_tbsp_stats_insert_where -- expand later
	;
								
		--
		-- Execute it:
		
		dbms_output.put_line ('sql is: ' || v_tbsp_stats_sql);
										
		EXECUTE IMMEDIATE v_tbsp_stats_sql;
		
EXCEPTION


  WHEN OTHERS
      THEN

        v_message :=  'Unknown Error ' || sqlerrm;


end pop_tbsp_stats_db;

PROCEDURE pop_tbsp_stats_all
IS

--
-- Driving procedure to get tbsp_stats based on cursor


v_message                      varchar2(4000);

CURSOR capacity_include_cur
IS
   SELECT db_name
   , monitor_db_link
   FROM dbarep_roadmap
   WHERE monitor_capacity_include = 'Y';
   

BEGIN 

FOR capacity_include_rec IN capacity_include_cur
LOOP

--
-- Call pop_tbsp_stats_db
--
		pkg_tbsp_stats_dbarep.pop_tbsp_stats_db
		    (
			  db_name_in         => capacity_include_rec.db_name
			, monitor_db_link_in => capacity_include_rec.monitor_db_link
		    , run_date_in        => trunc(sysdate)
		    );


END LOOP;

		--
		-- And commit:
		
		COMMIT;

EXCEPTION


  WHEN OTHERS
      THEN

        v_message :=  'Unknown Error ' || sqlerrm;


end pop_tbsp_stats_all;


END pkg_tbsp_stats_dbarep;