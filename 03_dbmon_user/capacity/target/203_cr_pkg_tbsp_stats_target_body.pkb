CREATE OR REPLACE PACKAGE BODY pkg_tbsp_stats_target
 as

/*

 Name:          cr_pkg_tbsp_stats.pkb

 Purpose:       PL/SQL Package tbsp_stats

 Usage:         To centralise remote tbsp_stats capacity planning
 
 Required Grants: 
 
 GRANT SELECT ON dba_free_space to dbmon;
 GRANT SELECT ON dba_segments to dbmon;
 GRANT SELECT ON dba_data_files to dbmon;
 GRANT SELECT ON dba_extents to dbmon;
 GRANT SELECT ON dba_tablespaces to dbmon;
 GRANT SELECT ON v_$database to dbmon;
 
 Comments:

  Date            Who             Description

  16th Jul 2013   Aidan Lawrence  Cloned from similar
  20th Dec 2014   Aidan Lawrence  Added code for datafile_highwatermark
  26th Jun 2015   Aidan Lawrence  Added Purge procedures
   8th Jun 2017   Aidan Lawrence  Validated pre git  

*/  
PROCEDURE pop_tbsp_stats_target
IS

--
-- Driving procedure to get tbsp_stats based on cursor

v_dbname    	           tbsp_stats.dbname%TYPE;    
v_tablespace_name    	   tbsp_stats.tablespace_name%TYPE;
v_bytes_used 	     	   tbsp_stats.bytes_used%TYPE;
v_bytes_max 	     	   tbsp_stats.bytes_max%TYPE;
v_bytes_free 	     	   tbsp_stats.bytes_free%TYPE;
v_extra_extents  	       tbsp_stats.extra_extents%TYPE;
v_bytes_max_no_extend 	   tbsp_stats.bytes_max_no_extend%TYPE;
v_bytes_free_no_extend     tbsp_stats.bytes_free_no_extend%TYPE;
v_extra_extents_no_extend  tbsp_stats.extra_extents_no_extend%TYPE;
v_largest_next_extent      tbsp_stats.largest_next_extent%TYPE;
v_sum_free_space 	       dba_free_space.bytes%TYPE;

CURSOR space_used_cur IS
	SELECT
	  tab.tablespace_name
	  , sum(seg.bytes) bytes_used
	  , max(seg.next_extent) largest_next_extent
	FROM  dba_segments seg
	,     dba_tablespaces tab
	WHERE tab.tablespace_name = seg.tablespace_name (+)
	AND   tab.tablespace_name not like 'TEMP%'
	group by tab.tablespace_name;

/*
 Cursor to try and determine how much free space
 there in chunks equal to or more than the current
 largest next extent
*/

CURSOR space_max_free_cur IS
	SELECT
	  sum(bytes) sum_free_space
	FROM  dba_free_space
	where tablespace_name = v_tablespace_name
	and bytes > v_largest_next_extent;

CURSOR space_no_extend_datafile_cur IS
	SELECT
	  dat.bytes
	FROM  dba_data_files dat
	where tablespace_name = v_tablespace_name
	and autoextensible = 'NO';

CURSOR space_auto_extend_datafile_cur IS
	SELECT
	  dat.maxbytes
	, dat.bytes
	FROM  dba_data_files dat
	where tablespace_name = v_tablespace_name
	and autoextensible = 'YES';

/* Begin the Processing */

BEGIN

	--
	-- Obtain the database name
	--
	
	SELECT name
	INTO v_dbname
	FROM v$database;
	
	--
	-- Purge any stats for today for this database;
	--	
	
	delete from tbsp_stats
	where dbname = v_dbname
	and trunc(generated_date) = trunc(sysdate);
	
--
-- Loop through storage data dictionary obtaining various stats snf populating tbsp_stats as appropriate
--	
	

FOR space_used_rec IN space_used_cur
LOOP

	v_tablespace_name         := space_used_rec.tablespace_name;
	v_bytes_used	          := space_used_rec.bytes_used;
	v_largest_next_extent     := space_used_rec.largest_next_extent;

	v_bytes_max 	          := 0;
	v_bytes_free	          := 0;
	v_extra_extents           := 0;
	v_bytes_free_no_extend    := 0;
	v_bytes_max_no_extend     := 0;
	v_extra_extents_no_extend := 0;

	/* This script allows for multiple datafiles per tablespace with any combination
	   of autoextensibility on and off.

	   Calculate the maxiumum bytes in the tablespace - with and without datafile extension
	*/

	FOR space_no_extend_datafile_rec IN space_no_extend_datafile_cur
	LOOP
		v_bytes_max 	      := space_no_extend_datafile_rec.bytes + v_bytes_max;
		v_bytes_max_no_extend := space_no_extend_datafile_rec.bytes + v_bytes_max_no_extend;
	END LOOP;

	FOR space_auto_extend_datafile_rec IN space_auto_extend_datafile_cur
	LOOP
		v_bytes_max 	      := space_auto_extend_datafile_rec.maxbytes  + v_bytes_max;
		v_bytes_max_no_extend := space_auto_extend_datafile_rec.bytes     + v_bytes_max_no_extend;
	END LOOP;

	/*
	   Calculate the bytes free in the tablespace - with and without datafile extension
	*/

	v_bytes_free 	       := v_bytes_max 		- v_bytes_used;
	v_bytes_free_no_extend := v_bytes_max_no_extend - v_bytes_used;

	/*
	   Compare the free chunks with the largest next extent to calculate

	   NB In calculating the extra extents, no allowance has been made for a
	   pctincrease of > 0. This script is calculates the NUMBER of extents available
  	   based on the size of the largest free extent  rather than the tablespace as a whole.

	   This may give pessimistic results in partially fragmented tablespaces.

	   If in doubt examine dba_FREE_SPACE in detail.

	*/

	FOR space_max_free_rec IN space_max_free_cur
	LOOP
		v_sum_free_space 	   := space_max_free_rec.sum_free_space;

		v_extra_extents_no_extend  := trunc(nvl(v_sum_free_space,0
 							) /v_largest_next_extent,0);

		v_extra_extents  	   := trunc(nvl(v_sum_free_space
							 + v_bytes_max
						 	 - v_bytes_max_no_extend,0
							) / v_largest_next_extent,0);

	END LOOP;
	
	INSERT INTO tbsp_stats
	(
	  dbname 
	, generated_date
	, tablespace_name
	, bytes_used
	, bytes_max
	, bytes_free
	, extra_extents
	, bytes_max_no_extend
	, bytes_free_no_extend
	, extra_extents_no_extend
	, largest_next_extent
	)
	VALUES
	(
	  v_dbname
	, trunc(sysdate)
	, v_tablespace_name
	, nvl(v_bytes_used,0)
	, v_bytes_max
	, nvl(v_bytes_free,v_bytes_max)
	, v_extra_extents
	, v_bytes_max_no_extend
	, nvl(v_bytes_free_no_extend,v_bytes_max_no_extend)
	, v_extra_extents_no_extend
	, v_largest_next_extent
	);

END LOOP;

--
-- Purge to stop volumes growing too highwatermark

	DELETE FROM tbsp_stats
    WHERE TO_CHAR(generated_date,'Dy') <> pkg_tbsp_stats_target.c_tbsp_stats_purge_day 
    AND generated_date < sysdate - pkg_tbsp_stats_target.c_tbsp_stats_purge_period; 
	
	COMMIT;


END pop_tbsp_stats_target;

PROCEDURE pop_file_highwatermark_target
IS

--
-- Driving procedure to get datafile highwatermark based on cursor

v_dbname    	           datafile_highwatermark.dbname%TYPE;    

--
-- Highwatermark defined as the maximum block id * blocksize + 1 block to allow for extent '0'

CURSOR datafile_highwatermark_cur IS	
SELECT 
  t.tablespace_name
, a.file_name
, a.bytes_current
, NVL((a.max_block_id * t.block_size),0) + t.block_size as bytes_highwatermark
FROM 
(
SELECT 
  f.tablespace_name		  AS tablespace_name
, f.file_name			  AS file_name
, NVL(f.bytes,0)    	  AS bytes_current
, MAX(e.block_id)         AS max_block_id
FROM dba_data_files f
LEFT JOIN dba_extents e
ON f.file_id = e.file_id
GROUP BY 
  f.tablespace_name
, f.file_name
, NVL(f.bytes,0)
) a
JOIN dba_tablespaces t
ON t.tablespace_name = a.tablespace_name
ORDER BY 
  t.tablespace_name
, a.file_name
, a.bytes_current
;

/* Begin the Processing */

BEGIN

	--
	-- Obtain the database name
	--
	
	SELECT name
	INTO v_dbname
	FROM v$database;
	
	--
	-- Purge any stats for today for this database;
	--	
	
	delete from datafile_highwatermark
	where dbname = v_dbname
	and trunc(generated_date) = trunc(sysdate);
	
--
-- Simple loop through cursor storing data
--	
	
FOR datafile_highwatermark_rec IN datafile_highwatermark_cur
LOOP

	INSERT INTO datafile_highwatermark
	(
	  dbname 
	, generated_date
	, tablespace_name
	, file_name
	, bytes_highwatermark
	, bytes_current
	)
	VALUES
	(
	  v_dbname
	, trunc(sysdate)
	, datafile_highwatermark_rec.tablespace_name
	, datafile_highwatermark_rec.file_name
	, datafile_highwatermark_rec.bytes_highwatermark
	, datafile_highwatermark_rec.bytes_current	
	);

END LOOP;

--
-- Purge to stop volumes growing too highwatermark

	DELETE FROM datafile_highwatermark
    WHERE generated_date < sysdate - pkg_tbsp_stats_target.c_highwatermark_purge_period;
	
	COMMIT;

END pop_file_highwatermark_target;

END pkg_tbsp_stats_target;
/


