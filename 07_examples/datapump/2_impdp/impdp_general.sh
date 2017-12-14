#!/bin/bash
#################################################################
#
# Name:          impdp_general.sh
#
# Purpose:       Front end script to datapump import
#
# Usage:         impdp_general.sh <db> <credentials> <impdp_parfile> 
#                impdp_general.sh dbarep hr/HRREP impdp_schema.par
#                impdp_general.sh dbarep dbmon/dbmonrep impdp_full.par
#
# Prerequisites  Datapump Parameter file must be prepared separately, including creation/validation of Oracle directory 
#
#                NB ./impdp_general.sh <db> <credentials> <impdp_parfile> & to allow to run in background
# Date            Who             Description
#
#  7th  Jun 2017  Aidan Lawrence  Cleanup for git 

#
# Validate parameters
#
if [[ -n $3 ]]; then
     #
     # Set parameters
     export ORACLE_SID=$1
	 export ORA_CRED=$2
	 export DP_PAR=$3
     #
     # User oraenv to set Oracle environment based on /etc/oratab
     export ORACLE_BASE=/opt/oracle
     export ORAENV_ASK=NO
     . /usr/local/bin/oraenv
     unset ORAENV_ASK
else
#
# Invalid input
#
    echo invalid input
    echo $1
    echo $2
	echo $3
    DISPLAYTIME=$(date +%c)
    echo Subject: Attempt to run impdp_general with invalid parameters
    exit 1
fi

BASE_DIR=${ORACLE_BASE}/admin
DP_DIR=/orabackup/datapump
SCRIPT_DIR=${BASE_DIR}/${ORACLE_SID}/1_impdp
LOGFILE=$SCRIPT_DIR/impdp_general.log
LOGFILE2=$SCRIPT_DIR/impdp_general_2.log

#
# Start the main  commands
#

cd $SCRIPT_DIR
pwd

#
# For full exports should use user with the DATAPUMP_EXP_FULL_DATABASE role

# sqlplus 'sys / as sysdba'
# GRANT DATAPUMP_EXP_FULL_DATABASE to system

TIME=$(date +%y%m%d_%H:%M:%S)
echo "${TIME} - impdp started " >>$LOGFILE
 
impdp $ORA_CRED parfile=$DP_PAR >>$LOGFILE 
# impdp dbmon/dbmonrep  parfile=impdp_xxx.par >>$LOGFILE

TIME=$(date +%y%m%d_%H:%M:%S)
echo "${TIME} - impdp completed " >>$LOGFILE

exit
