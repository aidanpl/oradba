/*

 Name:          cr_tab_vw_parameters.sql

 Purpose:       Parameter table to hold constants for various view reporting - avoids hard coding direct in views 
 
 Usage:			General documentation table to include in reports
                
 Date            Who             Description

 4th Jul 2017    Aidan Lawrence  Validated pre git 
 
 
*/

DROP TABLE vw_parameters
/

CREATE TABLE vw_parameters
(open_cursor_threshold number
)
/

--
-- Used in cur_xx cursor tuning views 

INSERT INTO vw_parameters
(open_cursor_threshold)
VALUES
(100)
/

COMMIT
/
