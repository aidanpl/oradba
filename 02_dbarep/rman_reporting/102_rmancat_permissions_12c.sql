/*

 Name:          rmancat_permissions_12c.sql

 Purpose:       Required synonyms/permissions from dbmon to rmancat - oracle 12c or higher implementation 

 Usage:       	If running Oracle 12 or higher these grants/synonyms are required as functionality is installed directly under the RMANCAT schema which reference data in the dbmon scheama  
				If running Oracle 11 or lower these views maybe created in DBMON with suitable grants/synonyms created 
					Please see script rmancat_permissions_11g.sql for information on how permissions can be granted to the DBMON monitoring user. 
 
Assuming schema names are DBMON and RMANCAT respectively 



 Date            Who             Description

 15th Jun 1017   Aidan Lawrence  Validated for git

*/

GRANT SELECT ON dbmon.dbarep_roadmap    TO rmancat;
GRANT SELECT ON dbmon.dbarep_parameters TO rmancat;

CREATE SYNONYM  rmancat.dbarep_roadmap    FOR  dbmon.dbarep_roadmap;
CREATE SYNONYM  rmancat.dbarep_parameters FOR  dbmon.dbarep_parameters;
