<H1>OraSASH Implementation</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>0. Overview</H1>

OraSASH (Oracle Simulation ASH) is a open source project to allow access to Oracle Active Session History (ASH) data, save in a central repository without requiring the full Diagnostic and Tuning Pack license. 

Please see https://pioro.github.io/orasash/index.html (last accessed 8th Aug 2017) for further details. 

<H1>1. Installation</H1> 

Full instructions available at  https://pioro.github.io/orasash/installation.html (last accessed 8th Aug 2017)

<H1>2. Pre-requisites</H1> 

- A repository database (herafter referred to as REPO) 
- SYSDBA access to databases (herafter referred to as TARGET(s) ) to be monitored 


<H1>3. Implementation</H1>

<H2>3.1 Common errors</H2> 

During implementation you will be asked to provide a user, password and tablespace for the REPO and each TARGET database. Scripts will need to be executed as either SYSDBA or a the repository schema (typically SASH). SYSDBA is used for the initial installation, while SASH is used for ongoing monitoring. 

In essence before executing a script, sanity check whether you need to be:
	- sys/sysxxx@REPO as sysdba 
	- sys/sysxxx@TARGET as sysdba 
	- sash/sashyyy@REPO
	- sash/sashyyy@TARGET

<H2>3.1 Obtain software from github</H2>

git clone https://github.com/pioro/orasash

<H2>3.2 On TARGET for the first (or each) target to be monitored create SASH user and required schema objects</H2> 

<ul>
<li>sql*plus Connect to sys/sysxxx@<mark>TARGET</mark> as sysdba</li> 
<li>Examine then sash_dev/target_user_view_xxxx.sql where xxxx represents the version of your TARGET (can be different to repository) database</li> 
</ul>

This will create a user sash@<target> and create a new view SYS.SASHNOW to allow stats to be gathered. 

e.g. for 11.2 

<code>
sqlplus 'sys/sysxxx as sysdba'<br>

SQL> @target_user_view_11g2.sql<br>
"SASH user will be created and used only by repository connection via db link"<br>
"SASH privileges are limited to create session and select on system objects listed in script"<br>
Enter SASH password ? xxxxxx<br>
Enter SASH default tablespace [or enter to accept USERS tablespace] ?<br>
"SASH default tablespace is: " users<br>
<br>
..<br>
..<br>
"SASHNOW view will be created in SYS schema. This view will be accesed by repository database via DB link using user sash"
</code>

<H2>3.3 Install OraSASH on REPO and add the first TARGET to be monitored</H2>  

<ul>
<li>sql*plus Connect to sys/sysxxx@<mark>REPO</mark> as sysdba</li> 
<li>Examine then sash_dev/config.sql</li> 
</ul>

The first part will create the repository owner and install the OraSASH objects through various individual scripts. 

<code>
SQL> @config.sql<br>
"------------------------------------------------------------------------------------"<br>
Creating repository owner and job kill function using SYS user<br>
"------------------------------------------------------------------------------------"<br>
Enter user name (schema owner) [or enter to accept username sash] ?<br>
Enter user password ? xxxxxx<br>
Enter SASH user default tablespace [or enter to accept USERS tablespace] ?<br>
SASH default tablespace is: users<br>
"------------------------------------------------------------------------------------"<br>
Existing sash user will be deleted.<br>
</code>

Upon completion it will run the adddb.sql script to configure the first TARGET to be monitored. :

<code>
Enter database name db01<br>
Enter number of instances [default 1]<br>
Enter host name for instance number 1 xyz.example.com <br>
Enter instance name (or CDB for 12c) for instance number 1 [ default db01 ]<br>
Enter listener port number [default 1521]<br>
Enter SASH password on target database xxxxxx<br>
<br>
##################################################################################################<br>
Database added.<br>
##################################################################################################<br>

List of databases<br>

DBNAME                               DBID HOST                             INST_NUM CURRENT_DB<br>
------------------------------ ---------- ------------------------------ ---------- ----------<br>
db01                           1234342545 xyz.example.com                         1 *<br>
</code>

<H2>3.3 Check REPO jobs and log table</H2>

<ul>
<li>sql*plus Connect to sash/sashyyy@<mark>REPO</mark></li>
<li>execute job_stat.sql - This is simply a check of user_scheduler_jobs</li> 
</ul>

</code>
SQL>@job_stat<br>

set linesize 200<br>
col LAST_START_DATE format a35<br>
col NEXT_RUN_DATE format a35<br>
col job_name format a30 <br>
select job_name, LAST_START_DATE, NEXT_RUN_DATE, STATE, FAILURE_COUNT  from user_scheduler_jobs;<br>
<br>
<p>
JOB_NAME                       LAST_START_DATE                     NEXT_RUN_DATE                       STATE           FAILURE_COUNT<br>
------------------------------ ----------------------------------- ----------------------------------- --------------- -------------<br>
SASH_PKG_COLLECT_1_1234342545  08-AUG-17 10.22.38.684657 AM +00:00 08-AUG-17 10.22.38.000000 AM +00:00 RUNNING                     0<br>
SASH_PKG_GET_ALL_1_1234342545  08-AUG-17 10.30.01.006888 AM +00:00 08-AUG-17 10.45.00.000000 AM +00:00 SCHEDULED                   0<br>
SASH_REPO_PURGE                                                    09-AUG-17 12.00.00.000000 AM +00:00 SCHEDULED                   0<br>
SASH_REPO_WATCHDOG             08-AUG-17 10.27.40.945932 AM +00:00 08-AUG-17 10.32.39.000000 AM +00:00 SCHEDULED                   0<br>
<br>
</p>

<ul>
<li>sql*plus Connect to sash/sashyyy@<mark>REPO</mark></li> 
<li>execute checklog.sql - lists contents of sash_log</li>
</ul>

<code>
SQL>@checklog.sql <br>
W 2017-08-08 10:14:07       add_db                                           no db link - moving forward db01_xyx.example.com <br>
I 2017-08-08 10:14:07       configure_db                                     get_event_names<br>
I 2017-08-08 10:14:07       configure_db                                     get_users<br>
I 2017-08-08 10:14:08       configure_db                                     get_params<br>
I 2017-08-08 10:14:08       configure_db                                     get_data_files<br>
I 2017-08-08 10:14:08       configure_db                                     get_metrics<br>
I 2017-08-08 10:14:09       add_instance_job                                 adding scheduler job sash_pkg_collect_1_1234342545<br>
I 2017-08-08 10:14:09       add_instance_job                                 adding scheduler job sash_pkg_get_all_1_1234342545<br>
I 2017-08-08 10:14:10       create_repository_jobs                           adding new repository job<br>
I 2017-08-08 10:14:11       start_snap_collecting_jobs                       starting scheduler job SASH_PKG_GET_ALL_1_1234342545<br>
</code>

<H2>3.4 For additional targets to be monitored</H2> 

The OraSASH repository can monitor multiple databases. To add a second and subsequent target:

<ul>
<li>sql*plus Connect to sys/sysxxx@<mark>TARGET</mark> as sysdba</li> 
<li>Examine then sash_dev/target_user_view_xxxx.sql where xxxx represents the version of your TARGET (can be different to repository) database</li> 
</ul>

<ul>
<li>sql*plus Connect to sash/sashyyy@<mark>REPO</mark></li>
<li>execute adddb.sql</li> 
</ul>

Upon completion you should have a second and more databases, with the most recent addition showing as the 'current db' 

<code>
List of databases<br>
<br>
DBNAME                               DBID HOST                             INST_NUM CURRENT_DB<br>
------------------------------ ---------- ------------------------------ ---------- ----------<br>
db01                           123434254  xyz.example.com                         1 <br>
db02                           987643321  abc.example.com                         1 *<br>
</code>

<H1>4. SQL*Developer Reporting</H1>

The OraSASH authors have provided a number of SQL*Developer reports in the sqldeveloper-reports subfolder. If desired you can simply extract the SQL from the XML text files. 

<H1>5. Additional Reporting</H1>

Please see README_supplementary.md for supporting scripts including additional views on OraSASH. 