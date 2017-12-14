<H1>Database Creation</H1> 

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

A standard approach when creating a new database from scratch. This may be preferable to using the supplied wizards as it avoids much of the optional 'bloatware' that the DBCA wizard will typically install. The scripts here show the creation procedure common to most databases. Some databases will require optional Oracle functionality - this is documented elsewhere. 

These notes focus on the practicalities of database creation. For the theory and principles of database creation and management please see the Oracle documentation and similar material 

<H1>Preparation</H1> 

The database creation scripts do require a certain amount of hardcoded values. Things like database names, physical file locations, memory sizes etc. should be reviewed and adjusted as required for each new database. In the examples below <sid> refers to the system identified which is normally simply the name of the database. For example for database called dbarep, init<sid>.ora would be physically implemented as initdbarep.ora 

<H1>Implementation</H1> 

<H2>Prepare init<sid>.ora parameter file</H2>

The sample initdbarep.ora is an adequate starting point for the commonly required parameter settings. 

<ul>
<li>Clone sample initdbarep.ora to init<sid>.ora parameter file</li> 
<li>Perform a search/replace to change the dbarep name to your database name</li> 
<li>Adjust all file locations to match your file structure</li> 
<li>Adjust Memory Sizes as desired</li> 
<li>Consider adding further parameters as your applications/environment require</li> 
</ul>

Once happy with the contents the file should be copied to the required area within the Oracle software.

<ul>
<li>On Linux copy the file to $ORACLE_HOME/dbs</li> 
<li>On Windows copy the file to %ORACLE_HOME%\database</li> 
</ul>

<H2>Create the operating system directories</H2>

<p> See 01_cre_dir.sh for examples </p>

<H2>(Windows only) Create the Oracle Service</H2>

If running in Windows execute the oradim command to create the windows service. 

e.g. oradim -new -sid dbarep -syspwd sysdbarep -startmode auto -spfile 

Please see Oracle documentation for further details. 

<H2>Set base environment and start instance</H2>

Prepare for the CREATE DATABASE command 

<ol>
<li>Set the correct ORACLE_SID, ORACLE_HOME and PATH as per your operating system</li> 
<li>sql*plus with a sysdba connection</li> 
<li>STARTUP NOMOUNT to nomount the database</li> 
</ol>

STARTUP NOMOUNT will validate the contents of the init.ora file. Any errors in directory names, permissions, memory sizes may cause the NOMOUNT command to fail. If so, deal with the errors and retry. 

<H2>Create standard empty database </H2>

Adjust the names/file locations in the following scripts and execute in order

<ol>
<li>cr_db_01.sql - CREATE DATABASE command</li> 
<li>cr_db_02.sql - Catalog/Catproc to create data dictionary and standard packages</li> 
<li>cr_db_03.sql - Adjust some default values post DB creation</li> 
<li>cr_tbs_01.sql - Create standard tablespaces</li> 
</ol>

<H2>Create spfile</H2>

While connected as SYSDBA issue the CREATE SPFILE command and bounce the database to allow parameters to be managed with ALTER SYSTEM going forward. 

<H2>Consider Archivelog mode</H2>

Switch database to archivelog mode using standard DBA techniques. 

<H2>Consider Initial Cold backup</H2>

A cold backup at this stage may make recovery faster should problems occur during initial application setup.  

