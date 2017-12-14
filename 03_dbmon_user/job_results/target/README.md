<H1>Scripts for Job Results Reporting information</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Introduction</H1>

<p>
This section includes a series of tables, views, packages and jobs to storage growth to be captured and used for monitoring DBMS_SCHEDULE Results

</p>

The packages to populate both of these tables include purge processing to manage the data volumes over time. 

<H1>Pre-requisites</H1>

Tables DBMON.DBA_ROADMAP and DBMON.DBA_PARAMETERS have been created and populated 

<H1>Implementation</H1>  

As DBA account 

<ol>
  <li>101_job_results_permissions.sql</li>
</ol>

As the DBMON user 

<ol>
  <li>201_job_results_cre.sql - Create the JOB_RESULTS table</li>
  <li>202_job_results_monitored_schemas.sql  - a list of schemas to include in JOB_RESULTS monitoring. Edit for personal preferences</li>
  <li>203_cr_pkg_job_results_target_spec.pks - package pkg_job_results_target specification</li>
  <li>204_cr_pkg_job_results_target_body.pkb - package pkg_job_results_target body </li>
  <li>205_run_pkg_job_results_target.sql     - One off execution of pop_job_results_target</li>
    
</ol>

To schedule regular population of JOB_RESULTS:

<ol>
  <li>211_job_results_target_schedule.sql - Schedule for population of JOB_RESULTS (Edit schedule to personal preferences)</li>
  <li>212_job_results_target_job.sql      - Job definition for population of JOB_RESULTS</li>
  <li>213_job_results_target_one_off_job.sql  - One off execution of for population of JOB_RESULTS for testing </li>
</ol>

