/*

 Name:          Convert SQL query to JSON output 

 Purpose:       Sample use of JSON_ARRAY and JSON_OBJECT
 
 Usage:         Note JSON_ARRAY/OBJECT provided from Oracle 12.2 and later - see JSON Developers guide for further information
 
 Date            Who             Description

 7th Mar 2018	 Aidan Lawrence  Simple examples based on HR.employee similar to that provided in documentation
*/

set pages 999
col json_1 format a100 heading 'Json|Output'
--
-- Simple output using JSON_ARRAY

SELECT JSON_ARRAY(
employee_id
, first_name
, last_name
, hire_date
--, (date_to_unix_ts(hire_date) * 1000) 
, salary
) as json_1 
FROM employees
WHERE first_name like 'A%'
ORDER BY employee_id;


/*

Typical output

Json                                                                                               
Output                                                                                             
----------------------------------------------------------------------------------------------------
[103,"Alexander","Hunold","2006-01-03T00:00:00",9000]
[115,"Alexander","Khoo","2003-05-18T00:00:00",3100]
[121,"Adam","Fripp","2005-04-10T00:00:00",8200]

..
..
*/

--
-- Key Value pairs using JSON_OBJECT (Note use of dbmon date_to_unix_ts function for alternate numeric timestamp output)

SELECT JSON_OBJECT
( 'Employee id' VALUE employee_id
, 'name'      VALUE first_name || ' ' || last_name
, 'HireDate'  VALUE hire_date
, 'HireDateTS'  VALUE (dbmon.date_to_unix_ts(hire_date) * 1000) 
, 'Salary'      VALUE salary
, 'ContactInfo' VALUE json_object('mail' VALUE email,'phone' VALUE phone_number)
FORMAT JSON
) as json_1
FROM employees
WHERE first_name like 'A%';


/*

Typical output

Json                                                                                               
Output                                                                                             
----------------------------------------------------------------------------------------------------
{"Employee id":167,"name":"Amit Banda","HireDate":"2008-04-21T00:00:00","HireDateTS":1208736000000,"
Salary":6200,"ContactInfo":{"mail":"ABANDA","phone":"011.44.1346.729268"}}

{"Employee id":185,"name":"Alexis Bull","HireDate":"2005-02-20T00:00:00","HireDateTS":1108857600000,
"Salary":4100,"ContactInfo":{"mail":"ABULL","phone":"650.509.2876"}}

{"Employee id":187,"name":"Anthony Cabrio","HireDate":"2007-02-07T00:00:00","HireDateTS":11708064000
00,"Salary":3000,"ContactInfo":{"mail":"ACABRIO","phone":"650.509.4876"}}

..
..
*/


