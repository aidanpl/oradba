/*

 Name           102_email_acl_configuration

 Purpose:       Enable ACL for email configuration 
 
 Usage:			This is the second of two steps to allow email from Oracle databases. See notes on utl_mail package for first step 
 
				Both steps should be executed as SYSDBA

 Date            Who             Description

 29th Jun 2017   Aidan Lawrence  Cleaned up for git   

*/

/*

From 11g onwards ACL requires configuration to enable UTL_MAIL to be used 

Without this may get something like this 

ORA-24247: network access denied by access control list (ACL)
ORA-06512: at "SYS.UTL_TCP", line 17
..
..

Two/Three steps are required

	0) Validated if DBMS_NETWORK_ACL_ADMIN is installed
	1) Drop/Create the ACL itself
	2) Grant access to the ACL for the schema/role 

*/


/*

Validate if DBMS_NETWORK_ACL_ADMIN is installed. This is part of 'Oracle XML Database'

set lines 172
col comp_name format a40
col version format a30
col status  format a20
select comp_name, version, status
from dba_registry;

COMP_NAME                                VERSION                        STATUS              
---------------------------------------- ------------------------------ --------------------
Oracle XML Database                      11.2.0.2.0                     VALID               
Oracle Database Catalog Views            11.2.0.2.0                     VALID               
Oracle Database Packages and Types       11.2.0.2.0                     VALID         

If no line for 'Oracle XML Database' then install as per standard procedures - see note 1292089.1

*/


/*

Drop/Create an ACL with a sensible name 

*/


BEGIN
DBMS_NETWORK_ACL_ADMIN.DROP_ACL 
 			(
			acl 		=> 'utl_mail.xml'
			);
END;
/

COMMIT
/

/*

When first creating the ACL you need to assign to at least one user
In theory could create and assign a standard role - but in 11g testing shows that role doesn't seem to work - try it but if problem GRANT access directly to user)

*/


BEGIN
DBMS_NETWORK_ACL_ADMIN.CREATE_ACL 
 			(
			acl 		=> 'utl_mail.xml',
			description => 'Enables mail to be sent',
			principal 	=> 'DBMON', 
			is_grant 	=> true,
			privilege 	=> 'connect'
			);
END;
/

COMMIT
/

/*
Assign the ACL to the smtp server/port - typically 25
*/

BEGIN
DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL 
			(
			acl => 'utl_mail.xml',
			host => 'mail.test.example.com',
			lower_port => 25
			);
END;
/

COMMIT
/

