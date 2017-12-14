#!/bin/bash
#################################################################
#
# Name:          tbsp_stats_0.sh
#
# Purpose:       Trivial Driving script for tbsp_stats
#
# Usage:         tbsp_stats_0.sh  <DBNAME> <user> <pw>
#                tbsp_stats_0.sh dbarep dbmon <dbmonpw>
#
# Date            Who             Description
#
# 18th Dec 2015   Aidan Lawrence  Incorporated NTT standards with mine
#
#

#
# Base Environment 
#

#
# Ensure path includes sendmail:
export ORACLE_HOME=/opt/oracle/product/11.2.0/dbhome_1
export LD_LIBRARY_PATH=/opt/oracle/product/11.2.0/dbhome_1/lib
export PATH=$ORACLE_HOME/bin:/usr/local/bin:/usr/kerberos/bin:/bin:/usr/bin:/usr/sbin:
export TNS_ADMIN=/opt/oracle/tns
export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

#
# Validate parameters 
#
if [[ -n "$3" ]]; then
	 #
	 # Set parameters
     DBNAME=$1
     DBUSER=$2
	 DBPW=$3
else
#
# Invalid input
#
	echo Attempt to run tbsp_stats_0 with invalid parameters 
    exit 1
	
fi

# DBNAME set from input parameters. 

SCRIPT_DIR=~oracle/aidan/1_sql_master/1_data_dictionary_storage_reports/tbsp_stats

#
# Change to working directory 
#

cd $SCRIPT_DIR


TIME=$(date +%c)
echo "${TIME} - Running tbsp_stats scripts for $DBNAME" 
sqlplus -s $DBUSER/$DBPW@$DBNAME @tbsp_stats_1_overview_ck.sql
sqlplus -s $DBUSER/$DBPW@$DBNAME @tbsp_stats_2_growth_predict_ck.sql
sqlplus -s $DBUSER/$DBPW@$DBNAME @tbsp_stats_3_hwm_summary_ck.sql
sqlplus -s $DBUSER/$DBPW@$DBNAME @tbsp_stats_4_hwm_by_file_ck.sql

exit

