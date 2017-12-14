CREATE OR REPLACE PACKAGE BODY pkg_job_results_dbarep as

/*

 Name:          cr_pkg_job_results_dbarep.pkb

 Purpose:       PL/SQL Package tbsp_stats

 Usage:         Centralized job results monitoring

 Comments:

  Date            Who             Description

 15th Jul 2013	 Aidan Lawrence  Cloned from similar
  5th Jul 2017   Aidan Lawrence  Cleaned up from similar 

*/


PROCEDURE pop_job_results_db  (
								db_name_in         IN dbarep_roadmap.db_name%TYPE
							  , monitor_db_link_in IN dbarep_roadmap.monitor_db_link%TYPE
							 )

IS

      v_job_results_sql              varchar2(4000);
      v_message                      varchar2(4000);
      c_sql_quote                    char(1)        := '''';
      c_sql_at                       char(1)        := '@';

      
      v_job_results_delete_core  varchar2(4000) := 'DELETE FROM job_results WHERE dbname = ';

      v_job_results_insert_line_1 varchar2(4000) := 'INSERT INTO job_results (dbname, owner, job_name, actual_start_time, log_time,run_duration, status,error#,additional_info) ';
      v_job_results_insert_line_2 varchar2(4000) := 'SELECT dbname, owner, job_name, actual_start_time, log_time,run_duration, status,error#,additional_info FROM job_results';
      

BEGIN

		--
		-- Delete any entries on job_results for this database
		--
		-- Build the statement to execute 
		
		v_job_results_sql          := v_job_results_delete_core 
								  || c_sql_quote
								  || db_name_in
								  || c_sql_quote
								  ;
								  
        dbms_output.put_line('Delete SQL is ' || v_job_results_sql);
        
        --
		-- Execute it:
										
		EXECUTE IMMEDIATE v_job_results_sql;        

		-- Populate job_results with most recent runs of a given job 
		--
		-- Build the statement to execute 
		--
		v_job_results_sql          := v_job_results_insert_line_1 
								  || v_job_results_insert_line_2 
								  || c_sql_at
								  || monitor_db_link_in
	                              ;
	                              
        dbms_output.put_line('Insert SQL is ' || v_job_results_sql);	                              
								
		--
		-- Execute it:
										
		EXECUTE IMMEDIATE v_job_results_sql;
		
EXCEPTION


  WHEN OTHERS
      THEN

        v_message :=  'Unknown Error ' || sqlerrm;
        
        dbms_output.put_line (v_message);


end pop_job_results_db;

PROCEDURE pop_job_results_all
IS

--
-- Driving procedure to get job_results based on cursor


v_message                      varchar2(4000);

CURSOR job_results_include_cur
IS
   
   SELECT db_name
   , monitor_db_link
   FROM dbarep_roadmap
   WHERE monitor_job_stats_include = 'Y';
   
BEGIN 

FOR job_results_include_rec IN job_results_include_cur
LOOP

--
-- Call pop_job_results_db
--
		pkg_job_results_dbarep.pop_job_results_db
		    (
			  db_name_in         => job_results_include_rec.db_name
			, monitor_db_link_in => job_results_include_rec.monitor_db_link
		    );


END LOOP;

		COMMIT;

EXCEPTION


  WHEN OTHERS
      THEN

        v_message :=  'Unknown Error ' || sqlerrm;


END pop_job_results_all;

END pkg_job_results_dbarep;
/

SHOW ERRORS

