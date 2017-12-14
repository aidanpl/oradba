#!/bin/bash
#################################################################
#
# Name:          dbms_stats_purge.sh
#
# Purpose:       Script to manage optimiser stats when Oracle MMON not coping 
#			     See Oracle doc 1055547.1 for further information on this bug
#
# Date            Who             Description
#
# 24rd Sep 2015   Aidan Lawrence  Cloned from similar
# 12th Sep 2017   Aidan Lawrence  Validated for git 
#
# $1 Database to purge 
# $2 Stats retention period (Days)
#
# Example usage /opt/oracle/admin/scripts/dbms_stats_purge.sh db01 14
#

#
# Trivial Set Core environment 
# 

export ORACLE_BASE=/opt/oracle
export DIAG_DEST=$ORACLE_BASE/diag
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin:/usr/local/bin:/usr/ccs/bin:/usr/xpg4/bin:/sbin:/usr/sbin:/usr/bin:

export ORACLE_SID=$1
export retention_days=$2

BASE_DIR=/opt/oracle/admin
SCRIPT_DIR=${BASE_DIR}/scripts
LOGFILE=$SCRIPT_DIR/dbms_stats_purge_history.log

#
# Run the script 
#

cd $SCRIPT_DIR

TIME=$(date +%y%m%d_%H:%M:%S)
echo "${TIME} - dbms_stats_purge retention days $retention_days started for $ORACLE_SID" >>$LOGFILE

sqlplus '/ as sysdba' @dbms_stats_purge.sql $retention_days

TIME=$(date +%y%m%d_%H:%M:%S)
echo "${TIME} - dbms_stats_purge completed for $ORACLE_SID" >>$LOGFILE

exit 0
