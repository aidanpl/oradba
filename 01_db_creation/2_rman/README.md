<H1>RMAN Backup</H1>

Copyright (c) 2017 Aidan Lawrence, Caduceus Consulting Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<H1>Overview</H1>

A set of standard RMAN scripts that can be used to prepare and implement backups. Please see Oracle documentation for general RMAN knowledge. 

<H1>Scripts and configuration files</H1>

<H2>RMAN .rcv configuration files</H2>

RMAN commands are stored in a series of configuration scripts. These will perform backups at database, tablespace, incremental level as preferred as well as archive log backups. A handful of other scripts for listing the status of backups and providing inital configuration.

Note most scripts have a hardcoded backup file name and location in them. This allows backups to be easily identified when listing at the OS level. This is a personal preference of the author and not strictly required. If you do not want to have repeated names/locations in individual scripts simply remove them at let the file names default. 

<H3>RMAN Backup scripts</H3> 

RMAN backup scripts at various levels of granularity.

<ul>
<li>rman_cold_backup.rcv  - A cold/offline backup</li>
<li>rman_inc_0_backup.rcv - An incremental level 0 or 'full' backup</li>
<li>rman_inc_1_backup.rcv - An incremental level 1 or 'partial' backup</li>
<li>rman_arc_backup.rcv - Archive log backup</li>
<li>rman_tbsp_gp1_backup.rcv - Tablespace level backup for specific tablespaces</li>
<li>rman_tbsp_gp2_backup.rcv - Tablespace level backup for specific tablespaces</li>
<li>rman_tbsp_gp3_backup.rcv - Tablespace level backup for specific tablespaces</li>
<li>rman_test_backup_success.rcv - Backup of single tablespace to test infrastructure</li>
<li>rman_test_backup_fail.rcv - Backup of single typing error tablespace to test infrastructure</li>
</ul>

<H3>RMAN Configuration scripts</H3> 

Other scripts useful within the environment

<ul>
<li>rman_config_<db>.rcv  - DB Specific Configuration values</li>
</ul>

<H3>RMAN Query</H3> 

A couple of files to list backups, query for missing backups 

<ul>
<li>rman_list_backup.rcv  - List information on available backups</li>
<li>rman_report_need_backup_days_n.rcv  - Report on any file that has not been backed up for 'n' days</li>
</ul>

<H2>rman_backup.sh bash script</H2>

A generic bash script rman_backup.sh is called with two parameters – the name of the database to be backed up, and the name of the RMAN configuration script to determine what is backed up. 

Before using for the first time note the values of the RMAN catalog location and email distribution list should be specified.

<H2>sql_flush_shared_pool.sql sql script</H2>

This file is called within rman_backup.sh and executes the 'ALTER SYSTEM FLUSH SHARED_POOL' command. The author has worked in two separate environments where RMAN backups were failing with ORA-01008 errors. Please see the script for further information on known Oracle bugs. If desired not to use this functionality it is easily removed from rman_backup.sh

<H2>crontab_oracle_dbarep.txt</H2>

An example crontab configuration file is also provided 

<H1>Initial Installation</H1>

To setup RMAN backups on a new database:

<H2>RMAN configuration</H2>

Clone and edit rman_config_dbarep.rcv for your database. This will set default backup retention policy and file locations for datafile, controlfile and snapshot backups. 

<H2>RMAN Catalog (optional)</H2>

If using an RMAN Catalog add the new database to it. 

<H2>RMAN backup.sh</H2>

Edit rman_backup.sh to specify values for the RMAN catalog location and email distribution list should be specified.

Clone and edit rman_config_dbarep.rcv for your database. This will set default backup retention policy and file locations for datafile, controlfile and snapshot backups. 

<H2>Initial Tests</H2>

The scripts rman_test_backup_success.rcv and rman_test_backup_fail.rcv are designed to peform simple, quick backups to test the infrastructure. They are a good place to start to enable tweaks while validating the overall environmnet.

<H2>Full or Incremental?</H2>

Decide your strategy for the backups. While a full/incremental 0 backup each day is a common strategy, this may not be appropriate for larger/stable databases. 

<H3>Full daily database backups</H3>

Schedule rman_inc_0_backup.rcv on a daily basis. This is a database and archivelog backup. 

<H3>Full weekly database, daily incremental backups</H3>

Schedule rman_inc_0_backup.rcv on a weekly basis.
Schedule rman_inc_1_backup.rcv on a daily basis.

These are database and archivelog backups. 

<H3>Tablespace groups spread across a week</H3>

Where a database is too large for even a weekly full backup, a useful strategy is to divide the database tablespace by tablespace. Separate rcv files of the form rman_tbsp_gp<n>_backup.rcv are created with hardcoded tablespace names in each file. Each backup can have its own schedule. These tablespace level backups deliberately do not include archivelog backups within the scripts so a separate rman_arc_backup.rcv is provided.  

The critical tablespaces - SYSTEM, UNDO and SYSAUX are typically grouped together to file rman_tbsp_gp1_backup.rcv and are backed up daily. 

Other tablespaces are divided up into rman_tbsp_gp2_backup.rcv, rman_tbsp_gp3_backup.rcv, rman_tbsp_gp4_backup.rcv etc. 

Once all of the files have been prepared the suggested schedule is:
<pre>
Schedule rman_tbsp_gp1_backup.rcv on a daily basis.
Schedule rman_arc_backup.rcv on a daily basis.
Schedule rman_tbsp_gp2_backup.rcv on a weekly basis.
Schedule rman_tbsp_gp3_backup.rcv on a weekly basis.
Schedule rman_tbsp_gp4_backup.rcv on a weekly basis.
..
..
where gp2, gp3 etc. are backed up on different days of the week.

The crontab_oracle_dbarep.txt shows an example strategy 
</pre>
