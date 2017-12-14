<H1>opt/oracle/admin scripts</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

An area for non-db specific shell scripts to support Oracle database management 
Examples here include:

<ul>
<li>tidy_adrci_rdbms.sh - using adrci purge functionality to manage database log and trace files
<li>tidy_adrci_tnslsnr.sh - using adrci purge functionality to manage TNS listener log and trace files
<li>dbms_stats_purge.sh and dbms_stats_purge.sql - example bash script calling .sql script. This specific example is due to an acknowledged bug where Oracle was not purging historical stats 
<li>bash_example_sql_direct.sh - An example bash script with embedded SQL - an alternative to using sql*plus when the commands are simple. 
</ul>

<p>
The two tidy_adrci_xxx.sh scripts should be part of a standard management for any Oracle server. The dbms_stats_purge scripts show working examples of how additional functionality can be executed directly on the server.
</p>

An example crontab configuration file is also provided 

