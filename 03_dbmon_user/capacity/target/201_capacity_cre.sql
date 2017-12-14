/*

 Name:          capacity_cre.sql

 Purpose:       Create the TBSP_STATS and DATAFILE_HIGHWATERMARK tables

                This will use the users default tablespace. Sizing information only therer for systems still using DMT

 Date            Who             Description

  1st May 2001   Aidan Lawrence  General Review/Tidy up for WCC
  2nd Apr 2008   Aidan Lawrence  Sanity check and general tidy up
 14th Sep 2009   Aidan Lawrence  Validated for Oracle 9.2 and 10.2 for publication
  8th Jul 2013   Aidan Lawrence  Added dbname for centralised monitoring
 22nd Dec 2014   Aidan Lawrence  Added in highwatermark collection
  3rd Feb 2015   Aidan Lawrence  Added in virtual column datafile_highwatermark for easier reporting
  2nd Jun 2015   Aidan Lawrence  Added in pct and max DATE virtual columns and to tbsp_stats for easier reporting  
  8th Jun 2017   Aidan Lawrence  Validated pre git 
*/


--drop table tbsp_stats;

CREATE TABLE tbsp_stats
( dbname                  VARCHAR2(8)  NOT NULL
, generated_date          DATE          NOT NULL
, tablespace_name         VARCHAR2(30)  NOT NULL
, Bytes_used              NUMBER
, Bytes_max               NUMBER
, Bytes_free              NUMBER
, extra_extents           NUMBER
, Bytes_max_no_extend     NUMBER
, Bytes_free_no_extend    NUMBER
, extra_extents_no_extend NUMBER
, largest_next_extent     NUMBER
)
/

--
-- Common virtual columns for reporting
--

ALTER TABLE tbsp_stats
ADD pct_free_no_extend as
(round(100*(1-((bytes_max_no_extend - bytes_free_no_extend)/bytes_max_no_extend)),2));

ALTER TABLE tbsp_stats
ADD pct_free_with_extend as
(round(100*(1-((bytes_max - bytes_free)/bytes_max)),2));


--
-- PK
--

ALTER TABLE tbsp_stats
ADD CONSTRAINT tbsp_stats_pk
PRIMARY KEY
(dbname, generated_date, tablespace_name)
/


--drop table datafile_highwatermark;

CREATE TABLE datafile_highwatermark
( dbname                  VARCHAR2(8)    NOT NULL
, generated_date          DATE           NOT NULL
, tablespace_name         VARCHAR2(30)   NOT NULL
, file_name               VARCHAR2(4000) NOT NULL
, bytes_highwatermark     NUMBER
, bytes_current           NUMBER
)
/

-- Add in virtual column for simpler reporting 

ALTER TABLE datafile_highwatermark
ADD mbytes_reclaimabile as (round(((bytes_current - bytes_highwatermark)/1048976),1))
/

ALTER TABLE datafile_highwatermark
ADD CONSTRAINT datafile_highwatermark_pk
PRIMARY KEY
(dbname, generated_date, tablespace_name, file_name)
/
