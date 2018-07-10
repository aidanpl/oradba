/*

 Name:          cr_utility_functions.sql

 Purpose:       Common functions not provided as standard
 
 Usage:			Generic functions. Deliberately not put in individual package as no specific relationship
 
 Date            Who             Description

  7th Mar 2018   Aidan Lawrence  Start gathering for git
 
*/

CREATE OR REPLACE FUNCTION date_to_unix_ts (date_in IN DATE) 
RETURN NUMBER 
IS

c_module_name   CONSTANT VARCHAR2(30) := 'date_to_unix_ts';
v_error_message VARCHAR2(4000);
v_unix_ts       NUMBER;


BEGIN 

	-- Unix timestamps is defined as the number of seconds since 1st Jan 1970. 
	-- To convert standard Oracle date simply subtract 1st Jan 1970 from the date 
	-- and multiply by 60 seconds * 60 mins * 24 hours for no. of days. 

	v_unix_ts := (date_in - TO_DATE('01-JAN-1970','DD-MON-YYYY' )) * 60 * 60 * 24;
	RETURN v_unix_ts;
	
EXCEPTION 
      WHEN OTHERS
      THEN
        v_error_message :=  'Unknown Error ' || c_module_name || ' ' || sqlerrm;
		RAISE_APPLICATION_ERROR(-20001,v_error_message);		 	

END;
/
		
SHOW ERRORS



