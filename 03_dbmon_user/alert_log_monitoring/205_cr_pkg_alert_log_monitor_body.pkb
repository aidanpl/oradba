CREATE OR REPLACE PACKAGE BODY pkg_alert_log_monitor 
as
/*

 Name:          cr_pkg_alert_log_monitor.pks

 Purpose:       PL/SQL Package for accessing text version of alert log for easier front end monitoring
 
 Usage:			Alert log monitoring. Various strings to search for (ORA-, TNS- etc) are hard coded. Feels overkill to try and put these as constants. 
 
 Dependencies:  Requires specific grants:
 
 GRANT EXECUTE ON sys.dbms_system TO dbmon;
				                
 Date            Who             Description

 1st Aug 2017    Aidan Lawrence  Cleaned up from inherited system 
 
*/  

FUNCTION alert_log_filter 
		( clear_logs   IN VARCHAR2 DEFAULT 'no'  
		, recent_logs  IN VARCHAR2 DEFAULT 'no' ) 
	RETURN alert_log_table IS
	
    buffer       VARCHAR2(255);
    bytes        NUMBER;
    alert_time   DATE;
    result       alert_log_table;
	
BEGIN
	-- Create an empty output 
    result := alert_log_table ();
	--
	-- Write a start line of output to avoid scenarios of null output 
	
	--result.extend;
	--result(result.last) := alert_log_row(sysdate,0,pkg_alert_log_monitor.c_logcheck_begin);
	
	
  --
  -- For each log_line in the alert_log table ( will be the whole thing)
  --
    FOR line IN (
        SELECT log_line
        FROM alert_log
    ) LOOP
        buffer := line.log_line;
	--
    -- If the line is a date then store that date in variable alert_time
        BEGIN
            SELECT TO_DATE(buffer,'Dy Mon dd hh24:mi:ss yyyy')
            INTO alert_time
            FROM dual;
        EXCEPTION
	  -- 
	  -- If line is not a date then do nothing 
	  -- 
            WHEN OTHERS THEN
                NULL;
        END;
	--
	-- if the line is an error message of interest based on hard coded values: 
	--

        IF
            ( substr(buffer,1,4) = 'ORA-' )
		 OR ( substr(buffer,1,6) = 'Failed' )
		 OR ( substr(buffer,1,7) = 'Corrupt' )
        THEN
            result.extend;
            result(result.last) := alert_log_row(alert_time,1,buffer);
        END IF;
	--
	-- if the line is a TNS error message of interest based on hard coded values: 
	--

        IF
            ( substr(buffer,1,4) = 'TNS-' )
		 OR ( substr(buffer,1,5) = 'Fatal' )
        THEN
            result.extend;
			result(result.last) := alert_log_row(alert_time,2,buffer);
        END IF;

	--
	-- if the line is a Starting/Shutdown or LGWR switch: 
	--		
        IF
            ( substr(buffer,1,8) = 'Starting' ) 
		 OR ( substr(buffer,1,8) = 'Shutting' )
		 OR regexp_like(buffer,'LGWR')
        THEN
            result.extend;
            result(result.last) := alert_log_row(alert_time,3,buffer);
        END IF;

		--
		-- If the LogCheck line is encountered and recent_logs = 'Yes', clear out any entries returned so far. 
		-- Principle is these will already have been checked
		-- This will only happen if the function is deliberately called with the non-default value of recent_logs = 'Yes'
		
        IF
            buffer = pkg_alert_log_monitor.c_logcheck_message
			AND recent_logs = 'Yes'
        THEN
            result := alert_log_table ();
        END IF;
    END LOOP;

	    --
		-- If function called with clear_logs = 'YES', write a 'LogCheck line' into the text alert log. This will cause future calls of this routine to ignore data returned before this line. Useful if a particularly large alert_log is encountered. 
	
		IF
			( upper(clear_logs) = 'YES' )
		THEN
			pkg_alert_log_monitor.insert_logcheck_message(
				message_target => pkg_alert_log_monitor.c_logcheck_target,
				message => pkg_alert_log_monitor.c_logcheck_message
			);
		END IF;

	--
	-- Write a final line of output to avoid scenarios of null output 
	
	result.extend;
	result(result.last) := alert_log_row(sysdate,0,pkg_alert_log_monitor.c_logcheck_end);
		-- 
		-- Return the result table 
		-- 
		
		RETURN result;
END;

PROCEDURE insert_logcheck_message
	( message_target IN NUMBER
	, message        IN VARCHAR2)
IS

BEGIN
	
     -- Write a message to the alert log 
	        sys.dbms_system.ksdwrt(message_target,message);
	        --sys.dbms_system.ksdwrt(1,'Aidan test 1');
			--sys.dbms_system.ksdwrt(2,'Aidan test 2');
			--sys.dbms_system.ksdwrt(3,'Aidan test 3');

	/*
	
	NB Package DBMS_SYSTEM is not including in the standard Oracle documentation.
	Broad documentation located here http://psoug.org/reference/dbms_system.html (accessed 1st Aug 2017)
	

Prints a message to the target file (alert log and/or trace file)	dbms_system.ksdwrt (dest IN BINARY_INTEGER, tst IN VARCHAR2);

1: Write to the standard trace file
2: Write to the alert log
3: Write to both files at once
exec dbms_system.ksdwrt(3, '-- Start Message --');
exec dbms_system.ksdwrt(3, 'Test Message');
exec dbms_system.ksdwrt(3, '-- End Message --');
	
	As of 11.2 encrypted code is available in $ORACLE_HOME/rdbms/admin/prvtsys.plb. 
	Oracle has not exposed the package - for example uses try grep -i DBMS_SYSTEM while in $ORACLE_HOME/rdbms/admin

	This shows examples such as:
	
	dbms_system.ksdwrt(dbms_system.alert_file,
                    'a1101000.sql: Error while compiling type' ||
                    typ_rec.referenced_owner|| '.' || typ_rec.referenced_name);
					
    dbms_system.ksdwrt(dbms_system.trace_file,
                         'AQ: propagation schedule downgrade failed ' ||
                         ' for queue:'||s_c_rec.oid ||
                         ' destination:'|| s_c_rec.destination||
                         ' Job :'||jobname);					

    DBMS_SYSTEM.ksdwrt(1, 'Upgrade Queue table subscriber format' ||
                             'AQ$_'||qt_name || '_S') ;
					
	dbms_system.ksdwrt(2, msg);
	
	*/

END;

FUNCTION font_class_0 return VARCHAR2
IS 
	
BEGIN
	RETURN pkg_alert_log_monitor.c_font_class_0;
END;

FUNCTION font_class_1 return VARCHAR2
IS 
	
BEGIN
	RETURN pkg_alert_log_monitor.c_font_class_1;
END;

FUNCTION font_class_2 return VARCHAR2
IS 
	
BEGIN
	RETURN pkg_alert_log_monitor.c_font_class_2;
END;

FUNCTION font_class_3 return VARCHAR2
IS 
	
BEGIN
	RETURN pkg_alert_log_monitor.c_font_class_3;
END;

FUNCTION font_class_end return VARCHAR2
IS 
	
BEGIN
	RETURN pkg_alert_log_monitor.c_font_class_end;
END;



END pkg_alert_log_monitor;
/

SHOW ERRORS
