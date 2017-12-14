<H1>Block Distribution</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

A series of scripts to help understand the block usage for a given table or datafile. This can help with working out how to counter an unexpectedly high high watermark for a file or segment when trying to save space. 

<strong>Acknowledgements:</strong>

These scripts are evolved from those used in Learning Tree International Oracle Database Administration courses. Acknowledgement is given to the Carl Dudley, the author of these courses over many years, for the base ideas. 

<H2>Provided Scripts</H2>

<table style="width:100%">
<tr><th width=30%>Script Name</th><th width=70%>Description</th></tr>
<tr><td>all_blocks.sql</td><td>Show block usage for a given table</td></tr>
<tr><td>all_blocks_single_file.sql</td><td>Show block usage for a given datafile</td></tr>
<tr><td>row_blocks.sql</td><td>Show row distribution for a given table</td></tr>
<tr><td>login.sql</td><td>sql*plus settings for all scripts</td></tr>
</table>