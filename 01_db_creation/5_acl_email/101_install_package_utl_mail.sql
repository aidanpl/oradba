/*

 Name           101_install_package_utl_mail.sql

 Purpose:       Install package UTL_MAIL as part of email configuration 
 
 Usage:			This is the first of two steps to allow email from Oracle databases. See notes on ACL access for the second step 
 
                Both steps should be executed as SYSDBA

 Date            Who             Description

 29th Jun 2017   Aidan Lawrence  Cleaned up for git   

*/


/*

Step 1 - Install UTL_MAIL Package

For security reasons, UTL_MAIL is not enabled by default. 

Install it by executing the utlmail.sql and prvtmail.plb scripts in the $ORACLE_HOME/rdbms/admin directory as SYSDBA. 

cd $ORACLE_HOME/rdbms/admin

> ls -l *mail*
-rw-r--r--   1 oracle   oinstall    6233 Sep 25  2011 prvtmail.plb
-rw-r--r--   1 oracle   oinstall    7285 Jan  6  2009 utlmail.sql

e.g.


*/
. oraenv 
cd $ORACLE_HOME/rdbms/admin
sqlplus '/ as sysdba'
@$ORACLE_HOME/rdbms/admin/utlmail.sql
@$ORACLE_HOME/rdbms/admin/prvtmail.plb 

/*
> 

SQL> @utlmail.sql
Package created.
Synonym created.
SQL> @prvtmail.plb
Package created.
Package body created.
Grant succeeded.
Package body created.
No errors.
SQL>

*/

/*

UTL_MAIL relies on an initialization parameter, SMTP_OUT_SERVER, to point to an outgoing SMTP server 

Step 2 - Set smtp_out_server to the appropriate server 

*/

ALTER SYSTEM SET smtp_out_server = 'mail.test.example.com' scope=both;

/*
Step 3 GRANT EXECUTE ON utl_mail to xxxx as required 
*/

GRANT EXECUTE ON UTL_MAIL to dbmon;

