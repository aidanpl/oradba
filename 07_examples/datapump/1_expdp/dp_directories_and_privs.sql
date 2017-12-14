/*

 Name:          dp_directories_and_privs.sql

 Purpose:       expdp does not seem to like SYSDBA privs... 
 
 Usage:         Add directories/permissions as desired
  
 Date            Who             Description

 12th Sep 2013   Aidan Lawrence  Cloned from similar
  6th Jun 2017   Aidan Lawrence  Validated pre git publication 								 

*/

--
-- Linux example 
--
CREATE OR REPLACE DIRECTORY dp_std_dir AS 
'/orabackup/datapump';

GRANT READ, WRITE ON DIRECTORY dp_std_dir TO dbmon, hr, sh;

--
-- Grant the full exp/imp roles to the working user

GRANT DATAPUMP_EXP_FULL_DATABASE, DATAPUMP_IMP_FULL_DATABASE TO dbmon;

/*
--
-- Windows example
--

CREATE OR REPLACE DIRECTORY  DP_DIR_N_BACKUP AS 
'N:\oraback\sh\dpdump';

GRANT READ, WRITE ON DIRECTORY DP_DIR_N_BACKUP TO SH;

*/

