<H1>Data Dictionary Storage Reports</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

** APL ** Just need some brief comments - probably clone from existing tbsp_stats
Comment on link to views in 03_dbmon_user/capacity/target/05_tbsp_stats_view_vw.sql

<H2>Provided Scripts</H2>

<table style="width:100%">
<tr><th width=20%>Script Name</th><th width=60%>Description</th></tr>

<tr><td>login.sql</td><td>sql*plus settings for all scripts</td></tr>
<tr><td>tbsp_stats_0.sh</td><td>Driving shell script for each report</td></tr>
<tr><td>tbsp_stats_1_overview_ck.sql</td><td>Tablespace General Overview</td></td></tr>
<tr><td>tbsp_stats_2_growth_predict_ck.sql</td><td>Tablespace Daily Growth</td></td></tr>
<tr><td>tbsp_stats_3_hwm_summary_ck.sql</td><td>Datafile Highwatermark Overview</td></td></tr>
<tr><td>tbsp_stats_4_hwm_by_file_ck.sql</td><td>Datafile Highwatermark by file with reclaimable space</td></td></tr>

</table>


