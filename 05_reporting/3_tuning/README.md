<H1>Tuning Reports</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

A series of scripts for extracting tuning information from various parts of the data dictionary. The SQL is commonly based on views against the underlying dictionary. This allows the views to be used by any preferred front end. The scripts in this directory are typically used from a sql*plus command prompt. 

<H2>Provided Scripts</H2>

<H3>Generic</H3>

<table style="width:100%">
<tr><th width=30%>Script Name</th><th width=70%>Description</th></tr>
<tr><td>instance_tune_ck.sql</td><td>General instance reporting</td></tr>
<tr><td>lock_ck.sql</td><td>Current locks reporting</td></tr>
<tr><td>open_cursor_sql_text_ck.sql</td><td>Numbers of open Cursors</td></tr>
<tr><td>sga_pga_ck.sql</td><td>SGA/PGA Info and Advice</td></tr>
<tr><td>transaction_ck.sql</td><td>Current Transactions</td></tr>
<tr><td>undo_ck.sql</td><td>Undo reporting</td></tr>
</table>

<H3>High Resource Usage</H3>

<table style="width:100%">
<tr><th width=30%>Script Name</th><th width=70%>Description</th></tr>
<tr><td>high_sql_ck.sql</td><td>High Resource SQL by buffers, disk and time</td></tr>
<tr><td>high_io_ck.sql</td><td>IO and OS statistics</td></tr>
</table>


<H3>Stats Generation</H3>

<table style="width:100%">
<tr><th width=30%>Script Name</th><th width=70%>Description</th></tr>
<tr><td>stats_auto_gather_times.sql</td><td>Report timings for Auto stats generation</td></tr>
<tr><td>stats_collected_recent.sql</td><td>Number of stats collections per object</td></tr>
<tr><td>stats_last_analyzed.sql</td><td>Object lists by last analyze time</td></tr>
</table>

