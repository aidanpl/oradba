<H1>Notes on remote alert log monitoring</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

This functionality provides a method of remote monitoring of the text version of the Oracle alert log. An external table is created to point to the alert log and PL/SQL packages and views created to access the data. 

<H1>Standard Installation</H1>

Edit for dbname and excution the following scripts

<ol>
<li>101_alerts_directories_and_privs.sql</li>
</ol>

Create the schema objects:
<ol>
<li>201_cr_table_alert_log.sql</li> 
<li>202_cr_type_alert_log_row.sql</li>
<li>203_cr_type_alert_log_table.sql</li>
<li>204_cr_pkg_alert_log_monitor_spec.pks</li>
<li>205_cr_pkg_alert_log_monitor_body.pkb</li>
<li>206_cr_views_alerts.sql</li>
</ol>

<H1>Usage</H1>

<H2>Log Filtering</H2>

The alert log contains many information only messages and can grow rapidly  depending on database activity. Accessing the log remotely requires a filter be put in place based upon one or more of :

<ul>
<li>Message of interest - e.g. ORA-, Startup/Shutdown etc.</li>
<li>Time - e.g. show me the last 24 hours</li> 
<li>Active management - have I already looked at this message</li> 
</ul>

For an up to date list of filtered messages check the PL/SQL package PKG_ALERT_LOG_MONITOR. This is easily edited to an individual DBA preference. To flag whether a message has been viewed, the underlying PL/SQL function can be called to append a line with the text '<---LogCheck--->' to the actual alert log as it browses the messages. In subsequent views and entries earlier than the most recent LogCheck message are not shown.

<H2>Alert Views </H2>

A series of views are provided. 

<ul>
<li>ALERTS_ALL</li> 
		Show all messages of interest 

<li>ALERTS_H24</li> 
		Show all messages of interest in the last 24 hours

<li>ALERTS_RECENT_AND_CLEAR</li>
		Show all messages since the last <---LogCheck---> message and write a fresh <---LogCheck---> line to the log 

<li>ALERTS_RECENT_AND_NOCLEAR</li>
		Show all messages since the last <---LogCheck---> message but DO NOT write a fresh <---LogCheck---> line to the log.  
</ul>

