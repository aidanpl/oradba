<H1>Data Dictionary Misc Reports</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

A series of scripts reporting against various parts of the data dictionary. The SQL is commonly based on views against the underlying dictionary. This allows the views to be used by any preferred front end. The scripts in this directory are typically used from a sql*plus command prompt. 

<H2>Provided Scripts</H2>

<table style="width:100%">
<tr><th width=30%>Script Name</th><th width=70%>Description</th></tr>
<tr><td>audit_oracle_ck.sql</td><td>Audit report on recent database usage</td></tr>
<tr><td>data_dict_comments.sql</td><td>Extract comments on tables/columns</td></tr>
<tr><td>dataguard_ck_dbmon.sql</td><td>Monitor state of dataguard - suitable for both primary only</td></tr>
<tr><td>dataguard_ck_sysdba.sql</td><td>Monitor state of dataguard - suitable for both primary and secondary roles</td></tr>
<tr><td>instance_ck.sql</td><td>General report for instance level parameters</td></tr>
<tr><td>invalid_ck.sql</td><td>General check for invalid, offline, similar in error etc.</td></tr>
<tr><td>licence_ck_option_usage.sql</td><td>Option Pack Overview</td></tr>
<tr><td>licence_ck_used_options_details.sql</td><td>Option Pack Detailed Usage</td></tr>
<tr><td>login.sql</td><td>sql*plus settings for all scripts</td></tr>
<tr><td>mview_ck.sql</td><td>Materialized view reporting</td></tr>
<tr><td>obj_change.sql</td><td>List any object changes in the last 7 days</td></tr>
<tr><td>phys_ck.sql</td><td>List all physical files associated with the database</td></tr>
<tr><td>redo_logs_ck.sql</td><td>Redo Log Overview</td></tr>
<tr><td>scheduler_ck.sql</td><td>DBMS_Schedule jobs etc.</td></tr>
<tr><td>security_ck.sql</td><td>General Security information</td></tr>
</table>

