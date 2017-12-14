#!/bin/bash
#################################################################
#
# Name:          tidy_adrci_tnslsnr.sh
#
# Purpose:       Script to manage tns listener log files via adrci plus manual audit dump dest and text alert log 
#
# Date            Who             Description
#
# 14th Jan 2014   Aidan Lawrence  Cloned from rdbms equivalent 
# 12th Sep 2017   Aidan Lawrence  Validating for git 
#
# $1 File retention period (Days)
#
# Example usage /opt/oracle/admin/scripts/tidy_adrci_tnslsnr.sh 30
#

# Set Core environment 
export ORACLE_BASE=/opt/oracle 
export DIAG_DEST=$ORACLE_BASE/diag 
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin:/usr/local/bin:/usr/ccs/bin:/usr/xpg4/bin:/sbin:/usr/sbin:/usr/bin:

#
# Validate parameters 
#
if [[ -n "$1" ]]; then
 if [ $1 -ne 0 -o $1 -eq 0 2>/dev/null ]
 then
   if [[ $1 -lt 0 ]]; then
     echo invalid input
     exit 1
   else
	 #
	 # Set retention periods in terms of days and minutes
     days=$1
     minutes=$((1440 * $days))
     echo days=$days
     echo minutes=$minutes
   fi
 fi
else
#
# If no parameter supplied default to 14 days retention
#
 echo days=14
 days=14
 minutes=$((1440 * $days))
 echo days=$days
 echo minutes=$minutes
fi
 
echo "INFO: adrci tnslsnr purge started at `date`"

adrci exec="show homes tnslsnr " | grep -v : | while read file_line
do
   echo "INFO: adrci purging diagnostic destination for " $file_line
   echo "INFO: purging ALERT older than $1 days."
   adrci exec="set homepath $file_line;purge -age $minutes -type ALERT"
   echo "INFO: purging INCIDENT older than $1 days."
   adrci exec="set homepath $file_line;purge -age $minutes -type INCIDENT"
   echo "INFO: purging TRACE older than $1 days."
   adrci exec="set homepath $file_line;purge -age $minutes -type TRACE"
   echo "INFO: purging CDUMP older than $1 days."
   adrci exec="set homepath $file_line;purge -age $minutes -type CDUMP"
   echo "INFO: purging HM older than $1 days."
   adrci exec="set homepath $file_line;purge -age $minutes -type HM"
   echo "INFO: purging UTSCDMP older than $1 days."
   adrci exec="set homepath $file_line;purge -age $minutes -type UTSCDMP"   
   echo ""
   echo ""
done


echo "Please see /etc/logrotate.d/oracle-alertlog for rotation of text log files"

#
# Below is the original code using find and gzip as an alternative to standard OS logrotate. 
# Consider using this if root access for logrotate is unavailable or you simply prefer to manage these more manually 

<<'COMMENT'


# echo "INFO: Manage text listener.log file outside of adrci  started at `date`"

#
# Assumes listener is called 'listener.log' 
#
for listener_log in `find $DIAG_DEST/tnslsnr -name "listener.log"`
do
 listener_file=`echo "$listener_log" | awk -Ftrace/ '{print $2}'`
 echo $listener_log
 echo $listener_file
 fname="${listener_log}_`date '+%Y%m%d'`.gz"
 fname1="${listener_log}_`date '+%Y%m%d'`"
 echo $fname
 if [ -e $fname ]
 then
   echo "Already cleared $listener_log today"
 else
   # Copy current log to date stamped file and zip
   cp $listener_log $fname1
   gzip $fname1
   # Remove any zipped files older than retention period 
   find $DIAG_DEST/tnslsnr -name ${listener_file}*.gz -mtime +$days | xargs -i ksh -c "echo deleting {}; rm {}"
   # Nullify the existing log 
   echo > $listener_log
 fi
# done

COMMENT

echo "SUCC: Purge completed successfully at `date`"
exit 0

