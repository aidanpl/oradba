<H1>Scripts for collating job results information</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Introduction</H1>

When monitoring multiple databases this code allows job results data captured in individual databases to be collated onto dbarep. This is purely for the purpose of a single repository for reporting purposes. Please see documentation under job results/dbarep for detail on the job results modules. 

<H1>Pre-requisites</H1> 

Job results planning under dbmon_user/job results/dbarep is pre-implemented 

- Tables DBMON.DBA_ROADMAP have been created and populated 
- For each target database a suitable database link to its dbmon schema has been created 

<H1>Implementation</H1>

As the DBMON@DBAREP user 

For each target database 

<ul>
	<li>101_cr_db_link_target.sql           - Create db_link and update dba_roadmap for a target database</li>
</ul> 

Once only 
<ol>
  <li>202_cr_pkg_job_results_dbarep_spec.pks - package pkg_job_results_dbarep specification</li>
  <li>203_cr_pkg_job_results_dbarep_body.pkb - package pkg_job_results_dbarep body</li> 
  <li>204_run_pop_job_results_all.sql        - one off run of pop_job_results_all</li> 
</ol> 

<ol>
  To schedule regular population of JOB_RESULTS:
<li>211_job_results_dbarep_schedule.sql - Schedule for population of JOB_RESULTS (Edit schedule to personal preferences)</li>
<li>212_job_results_dbarep_job.sql</li>     - Job definition for population of JOB_RESULTS</li>
<li>213_job_results_dbarep_one_off_job.sql  - One off execution of for population of JOB_RESULTS for testing</li> 
</ol> 

<p>
Additionally the data is collated in a fairly crude level - just delete/copy all the data for a given target each time rather than on a date driven basis. This could be fine tuned to reduce the amount of unnecessary delete/copy but the volumes are normally quite small, particularly if purging of the data is in place. 
</p>