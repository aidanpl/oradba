#!/bin/bash
#################################################################
#
# Name:          dbcheck.sh (Fully genericised)
#
# Purpose:       Cleaned up version of dbcheck to better split OS and db including primary/standby differences)
#
# Usage:         dbcheck.sh <sid>
#                dbcheck.sh dbarep01
#
# Date            Who             Description
#
# 12th Sep 2017   Aidan Lawrence  Fully genericised and validated for git

dbcheck_content_header()
{
echo 'Content-Type: text/html; charset="us-ascii"'>> $DBCHECK_CONTENT
echo "<html>" >> $DBCHECK_CONTENT
echo "<H1>" >> $DBCHECK_CONTENT
echo "Healthcheck for database $ORACLE_SID on $MACHINE" >> $DBCHECK_CONTENT
echo "</H1>" >> $DBCHECK_CONTENT
echo "<body><pre>" >> $DBCHECK_CONTENT
}

dbcheck_content_footer()
{
echo "" >> $DBCHECK_CONTENT
echo "<H1>" >> $DBCHECK_CONTENT
echo "Healthcheck for database $ORACLE_SID on $MACHINE complete" >> $DBCHECK_CONTENT
echo "" >> $DBCHECK_CONTENT
echo "</H1>" >> $DBCHECK_CONTENT
echo "</pre>" >> $DBCHECK_CONTENT
echo "</body>" >> $DBCHECK_CONTENT
echo "</html>" >> $DBCHECK_CONTENT
}

mail_dbcheck()
{
    DISPLAYTIME=$(date +%c)
    echo Subject: dbcheck completed for $ORACLE_SID on $MACHINE  at ${DISPLAYTIME} > $DBCHECK_SUBJECT
    cat $DBCHECK_SUBJECT $DBCHECK_CONTENT > $DBCHECK_ORACLE_SID_MAIL
    /usr/sbin/sendmail  -t $EMAIL_DIST < $DBCHECK_ORACLE_SID_MAIL

}


##
## Check database is up and running
##

db_running()
{

     # echo "" >> $DBCHECK_CONTENT
     # echo "Checking Database $ORACLE_SID is up" >> $DBCHECK_CONTENT
     # echo "" >> $DBCHECK_CONTENT
     echo "Check for Oracle pmon process for database $ORACLE_SID" >> $DBCHECK_CONTENT
     if ps -ef | grep pmon | grep -v grep | grep $ORACLE_SID >> $DBCHECK_CONTENT
     then
        echo "" >> $DBCHECK_CONTENT
        echo "Oracle Database $ORACLE_SID is running" >> $DBCHECK_CONTENT
        echo "" >> $DBCHECK_CONTENT
        is_db_running=YES
     else
        echo "" >> $DBCHECK_CONTENT
        echo "Oracle Database $ORACLE_SID is not running. Please check it" >> $DBCHECK_CONTENT
        echo "" >> $DBCHECK_CONTENT
        is_db_running=NO
     fi
}

##
#  Checking role of the database as this script should only run against a Primary database
##

db_role()
{
   dbtype=`sqlplus -s <<END
             / as sysdba
       spool dbtype.lst
       set heading off
       set pagesize 0
       set tab off
       SELECT initcap(database_role)
       from v\\$database
       /
       spool off
        exit;
        END`

    echo "" >> $DBCHECK_CONTENT
    echo "Database role for $ORACLE_SID is $dbtype" >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT

}

standby_db()
{
   stbydb=`sqlplus -s <<END
             / as sysdba
        spool stbydb.lst
        set heading off
        set pagesize 0
        set tab off
        select
        case when value is null then 'None'
        else value
        end
        from v\\$parameter
        where name = 'fal_server'
        /
        spool off
        exit;
        END`
    echo "" >> $DBCHECK_CONTENT
    echo "Failover database for $ORACLE_SID is $stbydb" >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
}

Recoverable_space()
{

  recovery_area_percent_used=`sqlplus -s <<endofsql
  / as sysdba
  spool recovery_area_percent_used.lst
  set pagesize 132
  set tab off
  set heading off
  column recovery_area_percent_used format 999
  select to_number(sum(percent_space_used)) as recovery_area_percent_used
  from v\\$recovery_area_usage
  /
  exit;
  spool off
  endofsql`

  no_files=`sqlplus -s <<endofsql
  / as sysdba
  spool no_files.lst
  set pagesize 132
  set tab off
  set heading off
  column recovery_area_percent_used format 999
  select number_of_files
  from v\\$recovery_area_usage
  where file_type = 'ARCHIVED LOG'
  /
  spool off
  exit;
  endofsql`

  echo "Number of archive logs in Flash Recovery Area is $no_files" >> $DBCHECK_CONTENT
  echo ""
  if [ "$recovery_area_percent_used" -ge 90 ]; then
     echo "<font color=red>Flash Recovery Area usage CRITICAL at $recovery_area_percent_used %</font>" >> $DBCHECK_CONTENT
  fi

  if [ "$recovery_area_percent_used" -ge 75 ] && [ "$recovery_area_percent_used" -lt 90 ]; then
     echo "<font color=blue>Flash Recovery Area usage WARNING at $recovery_area_percent_used %</font>" >> $DBCHECK_CONTENT
  fi

  if [ "$recovery_area_percent_used" -lt 75 ]; then
     echo "Flash Recovery Area usage is acceptable at $recovery_area_percent_used %" >> $DBCHECK_CONTENT
  fi

}

ts_growth_prediction()
{
    time_limit=10
    echo "Show tablespaces estimated to extend in the next $time_limit days" >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @ts_growth_prediction_ck.sql $time_limit >/dev/null
    cat ts_growth_prediction_ck.lst >> $DBCHECK_CONTENT

    #
    # Specific link for production primary
    # if [ "$DB_PRIM" == "db01" ]
    # then
      #   echo "See <a href='http://db01.example.com/14_daily_storage_growth.cgi?database=db01#tbsp2'>Latest Production Tablespace Growth</a> for further information" >> $DBCHECK_CONTENT
        # echo "" >> $DBCHECK_CONTENT
    # fi
}

Arc_log_frequency()
{
    arc_limit=30
    echo "Showing hourly log switches greater than $arc_limit for the last 24 hours" >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @arc_log_frequency_ck.sql $arc_limit >/dev/null
    cat arc_log_frequency_ck.lst >> $DBCHECK_CONTENT
}

Job_failures()
{
    time_limit=1
    echo "Show failed jobs in the last $time_limit days" >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @job_failures_ck.sql $time_limit >/dev/null
    cat job_failures_ck.lst >> $DBCHECK_CONTENT
}

Job_overruns()
{
    overrun_limit=60
    echo "Show jobs running for more than $overrun_limit minutes" >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @job_overruns_ck.sql $overrun_limit >/dev/null
    cat job_overruns_ck.lst >> $DBCHECK_CONTENT
}

non_zero_audit_ck()
{
    time_limit=7
    echo "Show audited actions with non_zero return codes in the last $time_limit days" >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @non_zero_audit_ck.sql $time_limit >/dev/null
    cat non_zero_audit_ck.lst >> $DBCHECK_CONTENT
}

Unusable_indexes()
{
    echo "Show any Unusable Indexes" >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @unusable_indexes_ck.sql >/dev/null
    cat unusable_indexes_ck.lst >> $DBCHECK_CONTENT
}

forced_logging_ck()
{
    echo "Show any issues with forced logging " >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @forced_logging_ck.sql >/dev/null
    cat forced_logging_ck.lst >> $DBCHECK_CONTENT
}

Failed_Logins()
{
    failure_limit=5
    echo "Show failed login attempts over or above a count of $failure_limit attempts " >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @failed_logins_ck.sql $failure_limit >/dev/null
    cat failed_logins_ck.lst >> $DBCHECK_CONTENT
}

Files_needing_backup()
{
    time_limit=8
    echo "Show files not backed up within the last $time_limit days" >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @files_needing_backup_ck.sql $time_limit >/dev/null
    cat files_needing_backup_ck.lst >> $DBCHECK_CONTENT
}

mview_refresh()
{
    time_limit=24
    echo "Show materialized views not refreshed in the last $time_limit hours " >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @mview_refresh_ck.sql $time_limit >/dev/null
    cat mview_refresh_ck.lst >> $DBCHECK_CONTENT
}

sga_resize_ck()
{
    time_limit=24
    echo "Show SGA resize operations in the last $time_limit hours " >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @sga_resize_ck.sql $time_limit >/dev/null
    cat sga_resize_ck.lst >> $DBCHECK_CONTENT
}


dataguard_status()
{
    #
    # Some hardcoded primary/standby to get the script up and running
    export DB_PRIM=db01
    export DB_STBY=db01_stdby

    dgmgrl / "show database '$DB_PRIM'" >   $DBCHECK_PRIM
    dgmgrl / "show database '$DB_STBY'" >   $DBCHECK_STBY
    cat $DBCHECK_PRIM $DBCHECK_STBY | grep -v DGMGRL | grep -v Welcome | grep -v Copyright | grep -v Connected >> $DBCHECK_CONTENT
}

specific_check_db()
{
export DBCHECK_SPECIFIC_SQL=specific_ck_$ORACLE_SID.sql
export DBCHECK_SPECIFIC_LST=specific_ck_$ORACLE_SID.lst

if [ -s $DBCHECK_SPECIFIC_SQL ]
then
    echo "Running database specific check script $DBCHECK_SPECIFIC_SQL " >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
    sqlplus -s '/ as sysdba' @$DBCHECK_SPECIFIC_SQL >/dev/null
    cat $DBCHECK_SPECIFIC_LST >> $DBCHECK_CONTENT
else
    echo "No specific checks for $ORACLE_SID " >> $DBCHECK_CONTENT
    echo "" >> $DBCHECK_CONTENT
fi

}


###
# Main Body Of Script Starts Here with environment setup (Not a function)
###

#
# Base Environment
#

MACHINE=`uname -n`
BASE_DIR=/opt/oracle/admin
EMAIL_DIST=oracle@db01.example.com

SCRIPT_DIR=/opt/oracle/admin/scripts/dbcheck
LOG_DIR=/opt/oracle/admin/logs/dbcheck
DBCHECK_SUBJECT=$LOG_DIR/dbcheck_result.subject
DBCHECK_CONTENT=$LOG_DIR/dbcheck_result.content
DBCHECK_MAIL=$LOG_DIR/dbcheck_result.mail

DBCHECK_PRIM=$LOG_DIR/dbcheck_prim.content
DBCHECK_STBY=$LOG_DIR/dbcheck_stby.content

#
# Validate parameters
#
if [[ -n $1 ]]; then
     #
     # Set parameters
     export ORACLE_SID=$1
     #
     # User oraenv to set Oracle environment based on /etc/oratab
     export ORACLE_BASE=/opt/oracle
     export ORAENV_ASK=NO
     . /usr/local/bin/oraenv
     unset ORAENV_ASK

    # NB Ensure path includes sendmail:
    export PATH=$PATH:/usr/local/bin:/usr/kerberos/bin:/bin:/usr/bin:/usr/sbin:
    export TNS_ADMIN=/opt/oracle/tns
    export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

else
#
# Invalid input
#
    echo invalid input
    echo $1
    echo $2
    DISPLAYTIME=$(date +%c)
    echo Subject: Attempt to run dbcheck with invalid parameters on $MACHINE  at ${DISPLAYTIME} > $DBCHECK_SUBJECT
    # Add the content - for failure include the rman log
    echo Please sanity check if a problem with a live script or just a human test gone wrong... >> $DBCHECK_CONTENT
    dbcheck_content_footer
    # Build and send the mail
    cat $DBCHECK_SUBJECT $DBCHECK_CONTENT > $DBCHECK_MAIL
    /usr/sbin/sendmail  -t $EMAIL_DIST < $DBCHECK_MAIL
    exit 1

fi

#
# Clear out working files

if [ -s $DBCHECK_SUBJECT ]
then
   rm $DBCHECK_SUBJECT
fi

if [ -s $DBCHECK_CONTENT ]
then
   rm $DBCHECK_CONTENT
fi

if [ -s $DBCHECK_MAIL ]
then
   rm $DBCHECK_MAIL
fi

#
# Start the content
dbcheck_content_header

#
# Post parameter validation
#

export HISTFILE=$LOG_DIR/dbcheck_${ORACLE_SID}_history.log
export DBCHECK_ORACLE_SID_MAIL=$LOG_DIR/dbcheck_result_$ORACLE_SID.mail

cd $SCRIPT_DIR

#
# Clear out working files

if [ -s $DBCHECK_ORACLE_SID_MAIL ]
then
   rm $DBCHECK_ORACLE_SID_MAIL
fi

#
# End of base_environment

###
# Main Checks starts here
###
#
# Main script
#
#
# Check for database running
echo "<H2>" >> $DBCHECK_CONTENT
echo "Database availability " >> $DBCHECK_CONTENT
echo "</H2>" >> $DBCHECK_CONTENT
db_running
if [ $is_db_running = "YES" ]
then
#
# Determine primary and standby roles
echo "<H2>" >> $DBCHECK_CONTENT
echo "Primary/Standby environment" >> $DBCHECK_CONTENT
echo "</H2>" >> $DBCHECK_CONTENT
   db_role
   standby_db

   if [ "$stbydb" != "None" ]
   then
   echo "<H3>" >> $DBCHECK_CONTENT
   echo "Overall Dataguard Status " >> $DBCHECK_CONTENT
   echo "</H3>" >> $DBCHECK_CONTENT
   dataguard_status
   fi

   if [ "$dbtype" == "Primary" ]
   then
        echo "<H2>" >> $DBCHECK_CONTENT
        echo "Primary specific checks " >> $DBCHECK_CONTENT
        echo "</H2>" >> $DBCHECK_CONTENT

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Tablespace Growth Prediction" >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        ts_growth_prediction

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Job Failures " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        Job_failures

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Job Overruns " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        Job_overruns

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Files needing backup " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        Files_needing_backup

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Materialized views needing refresh " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        mview_refresh

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Recent SGA Resize operations " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        sga_resize_ck

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Recoverable Space" >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        Recoverable_space

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Archive Log frequency" >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        Arc_log_frequency

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Unusable Indexes " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        Unusable_indexes

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Forced Logging " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        forced_logging_ck

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Excessive Failed Logins " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        Failed_Logins

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Non zero audited actions " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        non_zero_audit_ck

        echo "<H3>" >> $DBCHECK_CONTENT
        echo "Database Specific Checks " >> $DBCHECK_CONTENT
        echo "</H3>" >> $DBCHECK_CONTENT
        specific_check_db

   else
        echo "<H2>" >> $DBCHECK_CONTENT
        echo "Standby specific checks - limited checks being carried out" >> $DBCHECK_CONTENT
        echo "</H2>" >> $DBCHECK_CONTENT

   fi
fi

dbcheck_content_footer
mail_dbcheck
exit

