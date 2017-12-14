/*

 Name:          user_account_views_vw.sql

 Purpose:       Views for dba_users et al 

 Usage:         A series for views typically called from front end sh,perl/cgi anything you like  etc.

 Required direct Grants for view creations
  
GRANT SELECT ON dba_users to DBMON;
 
 Next Steps:

 Date            Who             Description

  4th Apr 2017   Aidan Lawrence  Ongoing tidyup
 27th Jun 2017   Aidan Lawrence  Validated pre git publication       

*/

CREATE OR REPLACE VIEW users_1_locked
--
-- Locked Users 
-- 
AS SELECT 
    username
  , to_char(lock_date,'DD-MON-YYYY') as locked_on   
  , to_char(expiry_date,'DD-MON-YYYY HH24:MI') as expired_on 
FROM dba_users
WHERE lock_date is not null 
ORDER BY 
  lock_date desc
  , username
/

CREATE OR REPLACE VIEW users_2_future_expire
--
-- Future Expiring Users
-- 
AS SELECT 
    username
  , to_char(expiry_date,'DD-MON-YYYY HH24:MI') as expiring_on   
FROM dba_users
WHERE trunc(expiry_date) BETWEEN trunc(sysdate) AND trunc(sysdate) + 7
ORDER BY 
  expiry_date desc
  , username
/


