
/*

 Name:          PURGE_DBA_RECYCLEBIN_job.sql

 Purpose:       Job for purge of recyclebin
 
 Usage:         Schedule this within the SYS schema. 
 
 Pre-Requirements: Equivalent schedule PURGE_DBA_RECYCLEBIN_SCH exists
 
 Need to create a PL/SQL procedure in SYS schema to do this first:
 
 CREATE OR REPLACE PROCEDURE purge_dba_recyclebin AS

v_statement VARCHAR2(100) := 'PURGE DBA_RECYCLEBIN';
BEGIN

EXECUTE IMMEDIATE v_statement;
END;
/
 
 
 
 Date            Who             Description

 31st Aug 2017   Aidan Lawrence  Validated for git 
*/

BEGIN

    DECLARE

    object_not_exist_exception EXCEPTION; 

    PRAGMA EXCEPTION_INIT (object_not_exist_exception, -27475); 

    BEGIN

        dbms_scheduler.drop_job(
        job_name            => 'PURGE_DBA_RECYCLEBIN_JOB'
        );
            
    EXCEPTION
    WHEN object_not_exist_exception
    THEN NULL; -- Ignore simple drop errors for object not existing;
    
    END;

dbms_scheduler.create_job(
    job_name            => 'PURGE_DBA_RECYCLEBIN_JOB' -- Job Name
  , schedule_name       => 'PURGE_DBA_RECYCLEBIN_SCH' -- When to run
  , job_type            => 'STORED_PROCEDURE'   -- What type of module
  , job_action          => 'PURGE_DBA_RECYCLEBIN'     -- Which Module
  , job_class           => 'DEFAULT_JOB_CLASS'
  , number_of_arguments => 0
  , enabled             => TRUE
  , comments            => 'Job to to control purge of recyclebin'
  , auto_drop           => FALSE
  );
   
end;
/ 