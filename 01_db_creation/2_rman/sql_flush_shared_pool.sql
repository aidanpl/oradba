/*

 Name:          sql_flush_shared_pool.sql

 Purpose:       Script to flush the shared pool 
 
 Usage:			RMAN may sometimes experience ORA-01008 errors on connection. See Oracle Metalink doc ID: 1280447.1 . Also forum comment 'bug 9877980 on 11.2.0.2 where cursor_sharing is set to force' 
                This script may be run first to clear out the pool 
				
 Date            Who             Description

 18th Jul 2017   Aidan Lawrence  Validated for git
 
*/


spool sql_flush_shared_pool.lst
set echo on

ALTER SYSTEM FLUSH SHARED_POOL;

spool off
exit
