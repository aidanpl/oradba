/*

 Name:          cr_tab_dbarep_parameters.sql

 Purpose:       Define dbarep_parameters
 
 Usage:			Parameters for things like email lists 
                
 Date            Who             Description

 8th Jun 2017    Aidan Lawrence  Validated pre git 
 
*/

DROP TABLE dbarep_parameters;
--
-- LOAD_PARAMETERS  (Table) 
--
CREATE TABLE dbarep_parameters
(
  PARAM_NAME   VARCHAR2(100),
  PARAM_VALUE  VARCHAR2(4000),
  VALID        VARCHAR2(1)
)
;

ALTER TABLE dbarep_parameters
ADD CONSTRAINT dbarep_parameters_pk
PRIMARY KEY (param_name, param_value, valid);

--
-- Generic parameters
--      

Insert into dbarep_parameters
   (PARAM_NAME, PARAM_VALUE, VALID)
 Values
   ('SMTP_SERVER', 'TBA', 'Y');
  
Insert into dbarep_parameters
   (PARAM_NAME, PARAM_VALUE, VALID)
 Values
   ('DB_NAME', 'dbarep', 'Y');   
   
Insert into dbarep_parameters
   (PARAM_NAME, PARAM_VALUE, VALID)
 Values
   ('SCHEMA', 'dbmon', 'Y');      

--
-- RMAN reporting parameters
--      


Insert into dbarep_parameters
   (PARAM_NAME, PARAM_VALUE, VALID)
 Values
   ('RMAN_REPORT_SENDER', 'john.doe@example.com', 'Y');    
   
Insert into dbarep_parameters
   (PARAM_NAME, PARAM_VALUE, VALID)
 Values
   ('RMAN_REPORT_SUBJECT', 'RMAN Daily Report', 'Y');         
   
Insert into dbarep_parameters
   (PARAM_NAME, PARAM_VALUE, VALID)
 Values
   ('RMAN_REPORT_JOB_NAME', 'dba_rep_rman_report', 'Y');    
 
COMMIT;
