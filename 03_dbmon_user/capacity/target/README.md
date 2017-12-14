<H1>Scripts for capacity management information</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Introduction</H1>

<p>
This section includes a series of tables, views, packages and jobs to storage growth to be captured and used for capacity planning 

TBSP_STATS holds data at a tablespace level, while DATAFILE_HIGHWATERMARK holds data at a datafile level. 
Queries to populate TBSP_STATS are generally benign, typically completing in a few seconds on most databases. For capacity planning this is typically scheduled on a daily basis. 
Queries to populate DATAFILE_HIGHWATERMARK can be more long running depending on the individual database, sometimes having run times in the 40-60 minute range. For capacity planning this is typically scheduled on a weekly basis. 
</p>

The packages to populate both of these tables include purge processing to manage the data volumes over time. 


<H1>Pre-requisites</H1>

Tables DBMON.DBA_ROADMAP and DBMON.DBA_PARAMETERS have been created and populated 

<H1>Implementation</H1>  

As DBA account 

<ol>
  <li>101_tbsp_stats_permissions.sql</li>
</ol>

As the DBMON user 

<ol>
  <li>201_capacity_cre.sql - Create the TBSP_STATS and DATAFILE_HIGHWATERMARK tables</li>
  <li>202_cr_pkg_tbsp_stats_target_spec.pks - package pkg_tbsp_stats_target specification</li>
  <li>203_cr_pkg_tbsp_stats_target_body.pkb - package pkg_tbsp_stats_target body </li>
  <li>204_run_pkg_tbsp_stats_target.sql     - One off execution of both  pop_tbsp_stats_target and pop_file_highwatermark_target for testing </li>
  <li>205_tbsp_stats_view_vw.sql            - a series of views against  TBSP_STATS and DATAFILE_HIGHWATERMARK</li>
</ol>

To schedule regular population of TBSP_STATS:

<ol>
  <li>211_tbsp_stats_target_schedule.sql - Schedule for population of TBSP_STATS (Edit schedule to personal preferences)</li>
  <li>212_tbsp_stats_target_job.sql      - Job definition for population of TBSP_STATS</li>
  <li>213_tbsp_stats_target_one_off_job.sql  - One off execution of for population of TBSP_STATS for testing </li>
</ol>

To schedule regular population of DATAFILE_HIGHWATERMARK:
<ol>
  <li>221_datafile_highwatermark_schedule.sql - Schedule for population of DATAFILE_HIGHWATERMARK (Edit schedule to personal preferences)</li>
  <li>222_datafile_highwatermark_job.sql      - Job definition for population of DATAFILE_HIGHWATERMARK</li>
  <li>223_datafile_highwatermark_one_off_job.sql  - One off execution of for population of DATAFILE_HIGHWATERMARK for testing </li>
</ol>