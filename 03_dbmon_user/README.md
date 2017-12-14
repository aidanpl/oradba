<H1>DBA monitoring user creation</H1> 

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Introduction</H1>

Instructions for creating a standard user DBMON for basic monitoring of an Oracle database. Using DBMON instead of the default SYS or SYSTEM users allows the DBA flexibility to generate their own views on the system and to create table to store capacity and simialr information. 

To create the DBMON user study the scripts in this directory, adjusting names, passwords to your own preference and execute in the following order 

<ol>
<li>1_cr_tbs_dbmon - create a monitoring tablespace</li> 
<li>2_cr_user_dbmon - create the monitoring user</li> 
<li>3_gr_user_dbmon - Run standard specific grants</li> 
</ol>

Optional supporting items include 

<ol>
<li>21_cr_tab_dba_roadmap.sql - create table DBA_ROADMAP referenced in various monitoring facilities</li>
<li>22_cr_tab_dba_parameters.sql - create table DBA_PARAMETERS referenced in various monitoring facilities</li>
<li>23_cr_tab_vw_parameters.sql - create table VW_PARAMETERS referenced in various monitoring views</li>
<li>24_cr_tab_job_results.sql - create table JOB_RESULTS referenced in various monitoring facilities</li>
</ol>

<H1>Related items</H1> 

</ul>
<li>remote alert log monitoring</li> 
<li>capacity</li> 
<li>audit</li>
</ul>