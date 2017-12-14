#!/bin/bash
#################################################################
#
# Name:          rman_backup.sh
#
# Purpose:       Script to run rman for a supplied database and specific rman script 
#
# Usage:       rman_backup.sh <db> <rman_script> 
#              rman_backup.sh dbarep rman_inc_0_backup
#
#
# Limitations: The script has functionality to connect to an RMAN catalog and to email a success/fail message on completion with the full log sent in the event of failure. 
# If not using either the catalog or email, the rman commands can be run without the catalog connection and the parts of the script relating to email easily removed 
# For simplicity the script deliberately hard codes values for $ORACLE_HOME, PATH and similar. This is reduce the occurence of errors due to some glitch in any oraenv setup, bash profiles etc. 
#              
# Preparation:   Before first usage check the values for 
#				 RMAN_CATALOG 
#                EMAIL_DIST
#                $ORACLE_HOME and associated paths
#
# Date            Who             Description
#
# 18th Jul 2017   Aidan Lawrence  Validated for git
#

#
# Get the machine name for reporting purposes
MACHINE=`uname -n`
BASE_DIR=/opt/oracle/admin
#
# Set RMAN_CATALOG and EMAIL_DIST to your personal prefernce
RMAN_CATALOG=<rman_schema>/<rman_pw>@<catalog_database>
EMAIL_DIST=oracle@db01.example.com

#
# Ensure path includes sendmail:
export ORACLE_HOME=/opt/oracle/product/12.1.0/dbhome_1
export LD_LIBRARY_PATH=/opt/oracle/product/12.1.0/dbhome_1/lib
export PATH=$ORACLE_HOME/bin:/usr/local/bin:/usr/kerberos/bin:/bin:/usr/bin:/usr/sbin:
export TNS_ADMIN=/opt/oracle/tns
#
# Setting NLS_DATE_FORMAT to include HH24:MI:SS will result in the rman log showing timestamps in this format. Without this it will use whatever the database default is - typically at a day granularity - not very useful in a backup script..
export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

#
# Validate parameters 
#
if [[ -n "$2" ]]; then
	 #
	 # Set parameters
     export ORACLE_SID=$1
     RMAN_SCRIPT=$2
	 #echo $ORACLE_SID
	 #echo $RMAN_SCRIPT
else
#
# Invalid input
#
	echo invalid input
	DISPLAYTIME=$(date +%c)
	echo Subject: Attempt to run rman_backup with invalid parameters on $MACHINE  at ${DISPLAYTIME} > rman_result.subject
	# Add the content - for failure include the rman log 
	echo Please sanity check if a problem with a live script or just a human test gone wrong... > rman_result.content 
	# Build and send the mail 
	cat rman_result.subject rman_result.content > rman_result.mail
	# ****/usr/sbin/sendmail  -t $EMAIL_DIST < rman_result.mail
    exit 1
	
	fi

SCRIPT_DIR=${BASE_DIR}/${ORACLE_SID}/scripts/rman
HISTFILE=$SCRIPT_DIR/rman_${ORACLE_SID}_history.log

#
# Change to working directory 
#

cd $SCRIPT_DIR

#
# Clear out working files 

if [ -s $SCRIPT_DIR/rman_result.subject ]
then
   rm $SCRIPT_DIR/rman_result.subject
fi

if [ -s $SCRIPT_DIR/rman_result.content ]
then
   rm $SCRIPT_DIR/rman_result.content
fi

if [ -s $SCRIPT_DIR/rman_result.mail ]
then
   rm $SCRIPT_DIR/rman_result.mail
fi


#
# Optionally flush shared pool - see sql_flush_shared_pool.sql script for why this may be necessary. 
TIME=$(date +%c)
echo "${TIME} - sql flush shared pool pre-rman executed for $ORACLE_SID" 
sqlplus '/ as sysdba' @sql_flush_shared_pool.sql

TIME=$(date +%c)
echo "${TIME} - rman $RMAN_SCRIPT started for $ORACLE_SID" >>$HISTFILE

#
# Execute rman with catalog connection 
# If not using a catalog simply remove the connection 
#
rman target / catalog $RMAN_CATALOG @$SCRIPT_DIR/${RMAN_SCRIPT}.rcv log=${RMAN_SCRIPT}_$ORACLE_SID.log

# No catalog version
# rman target / @$SCRIPT_DIR/${RMAN_SCRIPT}.rcv log=${RMAN_SCRIPT}_$ORACLE_SID.log

RETURN_STATUS=$?

if [ $RETURN_STATUS -eq 0 ]
	then
		TIME=$(date +%c)
		echo "${TIME} - rman $RMAN_SCRIPT complete success for $ORACLE_SID" >>$HISTFILE
		
		# Describe the subject for the email 
		# echo Subject: rman $RMAN_SCRIPT success for $ORACLE_SID on $MACHINE at ${TIME} > rman_result.subject
		echo Subject: Success. $ORACLE_SID on $MACHINE. rman $RMAN_SCRIPT at ${TIME} > rman_result.subject
		# Add the content - for success just a single line directed to the log file 
		echo Please see logfile $SCRIPT_DIR/${RMAN_SCRIPT}_$ORACLE_SID.log on $MACHINE for further detail > rman_result.content
		# Build and send the mail 
		cat rman_result.subject rman_result.content > rman_result.mail
		# ****sendmail -t $EMAIL_DIST < rman_result.mail
    else
		TIME=$(date +%c)
		echo "${TIME} - rman $RMAN_SCRIPT complete fail for $ORACLE_SID with return code $RETURN_STATUS " >>$HISTFILE	
		# echo Subject: rman $RMAN_SCRIPT FAILURE for $ORACLE_SID on $MACHINE with return code $RETURN_STATUS  at ${TIME} > rman_result.subject
		echo Subject: FAILURE. $ORACLE_SID on $MACHINE. rman $RMAN_SCRIPT at ${TIME} > rman_result.subject
		# Add the content - for failure include the rman log 
		cat ${RMAN_SCRIPT}_$ORACLE_SID.log > rman_result.content 
		# Build and send the mail 
		cat rman_result.subject rman_result.content > rman_result.mail
		# ****sendmail  -t $EMAIL_DIST < rman_result.mail
fi

exit

