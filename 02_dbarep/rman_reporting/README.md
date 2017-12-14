<H1>Scripts for Reporting from the RMAN catalog</H1> 

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Introduction</H1>

This section includes a series of views and packages, and jobs to allow periodic reporting from the RMAN catalog.

<H2>Oracle 11g and Oracle 12c differences</H2> 

Up to Oracle 11 it was plausible to install these in the standard dbmon type user with synonyms/grants to/from the repository owner (hereafter referred to as rmancat). Changes in default permissions between Oracle 11g and 12c mean this is no longer feasible without granting permissions at a lower level. As of the latest update to these scripts this has not been investigated - a workaround of installing and accessing the views/packages/jobs directly in the rmancat schema has been applied 

<H1>Pre-requisites</H1> 

<ul>
<li>RMAN catalog has already been installed and populated per Oracle documentation</li> 
<li>UTL_MAIL package is installed and configured if the packages/jobs are to be used</li> 
<li>Tables DBMON.DBA_ROADMAP and DBMON.DBA_PARAMETERS have been created and populated</li> 
</ul>

<H1>Implementation</H1> 

As DBA account (or logon to individual schemas) 
- 101_rmancat_permissions_11g.sql or 102_rmancat_permissions_12c.sql as appropriate

As DBMON (11g and lower) or RMANCAT (12c and higher) schemas 

<ol>
<li>201_rmancat_views_vw.sql - Generate various views</li> 
<li>202_cr_pkg_rman_rep_spec.pks - package pkg_rman_rep specification</li>
<li>203_cr_pkg_rman_rep_body.pkb - package pkg_rman_rep body</li> 
</ol>

To schedule regular report:
<ol>
<li>211_rman_report_schedule.sql - Schedule for rman reporting (Edit schedule to personal preferences)</li>
<li>212_rman_report_job.sql      - Job definition for rman reporting</li> 
<li>213_rman_report_one_off_job.sql  - One off execution of rman reporting job for testing</li>
</ol> 

