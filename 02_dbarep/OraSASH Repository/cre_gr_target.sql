/*

 Name:          cre_gr_target.sql

 Purpose:       Additional grants for SASH user on each target to allow views to make use of v$session on the target database. 
 
 Usage:       sqlplus -s sys/pw@target as sysdba @cre_gr_target 
 
 Date            Who             Description

 9th Aug 2017    Aidan Lawrence  Revalidated for git

*/

--
-- As SYSDBA 

GRANT SELECT on v_$session TO SASH;
