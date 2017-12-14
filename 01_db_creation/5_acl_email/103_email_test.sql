/*

 Name           103_email_test.sql

 Purpose:       Test email 
 
 Usage:			Test email process for your preferred user 
 
				Execute while connected as your user (previous steps where as sysdba)

 Date            Who             Description

 29th Jun 2017   Aidan Lawrence  Cleaned up for git   

*/

--
-- Ensure test schema has access to the utl_mail package:

/*

sqlplus / as sysdba 

GRANT EXECUTE ON UTL_MAIL to dbmon;

*/


DECLARE
    --
    -- Mail variables/constants - good enough for development
    --

      v_sender          CONSTANT VARCHAR2(100) := 'Aidan.Lawrence@example.com';
      v_recipients      CONSTANT VARCHAR2(500) := 'Aidan.Lawrence@example.com';
      v_subject         CONSTANT VARCHAR2(500) := 'Test subject update '||to_char(sysdate,'Dd FMMonth YYYY');
      v_db              VARCHAR2(50);
      v_schema          VARCHAR2(50);
      
      v_message         VARCHAR2(4000);

BEGIN

    v_db     := 'DBAREP';
    v_schema := 'DBMON';
    v_message := 'Test email from user ' || v_schema || ' db ' || v_db || to_char(sysdate,'Dd FMMonth YYYY');

    UTL_MAIL.SEND        (sender      => v_sender,
                          recipients  => v_recipients,
                          subject     => v_subject,
                          message     => v_message,
                          mime_type => 'text; charset=us-ascii'
                          );

END;
/
