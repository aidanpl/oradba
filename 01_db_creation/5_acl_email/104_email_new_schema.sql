/*

 Name           104_email_new_schema.sql

 Purpose:       Allow additional schemas to send email 
 
 Usage:			Email maintenance. Example given here for RMANCAT 
 
 Date            Who             Description

 29th Jun 2017   Aidan Lawrence  Cleaned up for git   

*/

-- 1) Grant access to the utl_mail for the users:

sqlplus '/ as sysdba'

GRANT EXECUTE ON utl_mail TO rmancat;

/*
Grant privileges on the ACL to the new user:
*/

BEGIN
	DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE 
			(
			acl 		=> 'utl_mail.xml',
			principal 	=> 'RMANCAT', -- user 
			is_grant 	=> TRUE,
			privilege 	=> 'connect'
			);
END;
/

COMMIT
/

--
-- Try a test email from that user...


