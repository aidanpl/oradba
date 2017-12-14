<H1>Data Dictionary Storage Reports</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

A series of scripts reporting against storage usage. The SQL is commonly based on views against the underlying dictionary. This allows the views to be used by any preferred front end. The scripts in this directory are typically used from a sql*plus command prompt. 

<H2>Provided Scripts</H2>

<table style="width:100%">
<tr><th width=20%>Script Name</th><th width=60%>Description</th>

<tr><td>login.sql</td><td>sql*plus settings for all scripts</td></tr>
<tr><td>lob_ck.sql</td><td>Lob segment detail</td></tr>
<tr><td>schema_frag_ck.sql</td><td>Schema fragmentation</td></tr>
<tr><td>schema_usage_ck.sql</td><td>Schema summary by tablespace and type</td></tr>
<tr><td>seg_all_ck.sql</td><td>Segment details all including block usage, last analyzed etc</td></tr>
<tr><td>seg_all_csv_ind.sql</td><td>Generate csv file listing indexes</td></td></tr>
<tr><td>seg_all_csv_ind_part.sql</td><td>Generate csv file listing index partitions</td></tr>
<tr><td>seg_all_csv_ind_subpart.sql</td><td>Generate csv file listing index subpartitions</td></tr>
<tr><td>seg_all_csv_tab.sql</td><td>Generate csv file listing tables</td></tr>
<tr><td>seg_all_csv_tab_part.sql</td><td>Generate csv file listing table partitions</td></tr>
<tr><td>seg_all_csv_tab_subpart.sql</td><td>Generate csv file listing table subpartitions</td></tr>
<tr><td>seg_tbsp_ck.sql</td><td>Segment detail for a single tablespace</td></tr>

</table>


