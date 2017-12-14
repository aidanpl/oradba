/*

 Name:          dbms_schedule_attribute_change.sql

 Purpose:       Examples for DBMS_SCHEDULE

 Contents:		Examples for setting attributes - e.g. changing the schedule, name of a procedure etc. 

 Date            Who             Description

 15th Jun 2017	 Aidan Lawrence  Example clean up for git 
 
*/

--
-- Amending atributes
--

--
-- Change to a daily frequency 

BEGIN
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'TBSP_STATS_TARGET_SCH'
     ,attribute => 'REPEAT_INTERVAL'
     ,value     => 'FREQ=DAILY; BYHOUR=06; BYMINUTE=00;BYSECOND=00'
    );
END;
/

--
-- Change to a weekly frequency 

BEGIN
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'TBSP_STATS_TARGET_SCH'
     ,attribute => 'REPEAT_INTERVAL'
     ,value     => 'FREQ=WEEKLY; BYDAY=FRI; BYHOUR=16; BYMINUTE=00;BYSECOND=00'
    );
END;
/

--
-- Changing the name of an executable
--

BEGIN
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'TBSP_STATS_TARGET_JOB'
     ,attribute => 'JOB_ACTION'
     ,value     => '<new proc name>');
END;
/

