/*

 Name:          install_sampleschemas.sql

 Purpose:       Document variables chosen for this sample schema install

 Usage:         See below.

 Sanity checks: Before running this, check for any invalid indexes using invalid_index_ck.sql
                After moving tables indexes will be left in an unusable state.
                Rebuild them using other scripts as appropriate

 Date            Who             Description

 30th May 2017   Aidan Lawrence  Documented on first use

*/

/*

Follow instructions from main README.md and README.txt files

Includes setting up working directory - example below

run the following to change __SUB__CWD__ to the current working directory 

perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat

Sanity check afterwards by diff the original files .bak files with the amended one - should see your working directory

dbarep:db01:~/aidan/db-sample-schemas-master $ diff mk_dir.sql.bak mk_dir.sql
58,60c58,60
< CREATE OR REPLACE DIRECTORY data_file_dir AS '__SUB__CWD__/sales_history/';
< CREATE OR REPLACE DIRECTORY log_file_dir  AS '__SUB__CWD__/log/';
< CREATE OR REPLACE DIRECTORY media_dir     AS '__SUB__CWD__/product_media/';
---
> CREATE OR REPLACE DIRECTORY data_file_dir AS '/opt/oracle/admin/git-base/db-sample-schemas/sales_history/';
> CREATE OR REPLACE DIRECTORY log_file_dir  AS '/opt/oracle/admin/git-base/db-sample-schemas/log/';
> CREATE OR REPLACE DIRECTORY media_dir     AS '/opt/oracle/admin/git-base/db-sample-schemas/product_media/';


*/

/*

Need to

1) Choose/create a tablespace

CREATE TABLESPACE SAMPLE_SCHEMAS
    DATAFILE  '/data/oradata/dbarep/sample_schemas_01.dbf' SIZE 1G AUTOEXTEND ON NEXT 100M MAXSIZE 8G;

2) Get hold of sysdba and system passwords

3) Agree template for specifying the passwords

4) Create a log directory

mkdir /opt/oracle/admin/git-base/db-sample-schemas/log

*/


/*

Template to run mksample is

@mksample <SYSTEM_password> <SYS_password>
        <HR_password> <OE_password> <PM_password> <IX_password>
        <SH_password> <BI_password> EXAMPLE TEMP
        $ORACLE_HOME/demo/schema/log/ localhost:1521/pdb

Change as required and update below

*/

@mksample dbarep_system dbarep_sys HRREP OEREP PMREP IXREP SHREP BIREP SAMPLE_SCHEMAS TEMP /opt/oracle/admin/git-base/db-sample-schemas/log/ dbarep
