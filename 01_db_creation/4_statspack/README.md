<H1>Instructions for implementation of statspack</H1> 

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

Where AWR and ASH are not available to the DBA due to licence restrictions, tuning stats can be gathered using statspack 

<H1>Standard Installation</H1> 

<H2>Server connection and setup your standard Oracle environment</H2>

<pre>
cd $ORACLE_HOME/rdbms/admin 
sqlplus '/ as sysdba'
@spcreate 
Give answers for 
	- perfstat password 
	- default tablespace (default of SYSAUX generally acceptable)
	- temp tablespace (default of TEMP generally acceptable)
</pre>
Supplied scripts will go ahead and create the PERFSTAT schema and associated objects 

<H2>Manually generate two snapshots and report</H2> 	

Connect as perfstat and execute the statspack.snap procedure. This may take 10-20 seconds to run.
Wait for a moderate period of time and execute again

Upon completion you will have two snapshots and a report can be run to show the performance between them.

While connected as perfstat execute the spreport.sql and select the begin and end snapshots:
<pre>
                                                       Snap
Instance     DB Name        Snap Id   Snap Started    Level Comment
------------ ------------ --------- ----------------- ----- --------------------
dbarep       DBAREP               1 04 Jul 2017 09:12     5
                                  2 04 Jul 2017 09:13     5

Specify the Begin and End Snapshot Ids
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Enter value for begin_snap: 1
Begin Snapshot Id specified: 1

Enter value for end_snap: 2
End   Snapshot Id specified: 2

Specify the Report Name
~~~~~~~~~~~~~~~~~~~~~~~
The default report file name is sp_1_2.  To use this name,
press <return> to continue, otherwise enter an alternative. 

A report will now be generated 
</pre>

<H2>Setup periodic perfstat job</H2> 

Create DBMS_SCHEDULE objects to periodically execute statspack.snap

As SYSDBA GRANT SCHEDULER_ADMIN to PERFSTAT; 

Edit and execute DBMS_SCHEDULE scripts to perform the snap:
<ol>
<li>11_perfstat_snap_schedule.sql</li>
<li>12_perfstat_snap_job.sql</li>
<li>13_perfstat_snap_one_off_run.sql</li>
</ol>

Sanity check using usual methods that job has been setup successfully

<H2>Setup periodic perfstat purge job</H2>

Create DBMS_SCHEDULE objects to periodically execute statspack.purge(n) where n is the number of days to keep 

- As SYSDBA GRANT SCHEDULER_ADMIN to PERFSTAT; 

Edit and execute DBMS_SCHEDULE scripts to perform the purge:
<ol>
<li>21_perfstat_snap_purge_schedule.sql</li>
<li>22_perfstat_snap_purge_job.sql</li>
<li>23_perfstat_snap_purge_one_off_run.sql</li>
</ol>

Sanity check using usual methods that job has been setup successfully
