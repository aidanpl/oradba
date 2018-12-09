#!/bin/bash
#################################################################
#
# Name:          tkprof_example.sh 
#
# Purpose:       Simple examples for tkprof usage. No attempt to genericise Adjust environment as desired  
#
# Usage:         tkprof_example.sh <db> <trace_file> <schema> <pw>
#                tkprof_example.sh dbarep dbarep_ora_2476_BUG-123_HR_emp_dept HR <pw> 
#
#                Various tkprof options are shown - simply choose whichever you prefer, with/without edit 
#
# Assumptions:   The trace file has been generated from whatever source of SQL, PL/SQL as described elsewhere
#
# Date            Who             Description
#
# 18th Jan 2018   Aidan Lawrence  Examples brought together for git 
#

#
# Validate parameters 
#
if [[ -n "$2" ]]; then
	 #
	 # Set parameters
     export ORACLE_SID=$1
     export TRACE_FILE=$2
	 export SCHEMA=$3
	 export PW=$4
else
#
# Invalid input
#
	echo "invalid input"
	echo "Subject: Attempt to run tkprof with invalid parameters"
	echo "usage is tkprof_example.sh <db> <trace_file> <schema> <pw>"
    exit 1
	
fi

#
# Trivial Set Core environment 
#

export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.1.0/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin:/usr/local/bin:/usr/ccs/bin:/usr/xpg4/bin:/sbin:/usr/sbin:/usr/bin:

export DIAG_DEST=$ORACLE_BASE/diag
export TRACE_DEST=$DIAG_DEST/rdbms/$ORACLE_SID/$ORACLE_SID/trace

#
# Run the script 
#

cd $TRACE_DEST


# Full tkprof syntax:
#
# tkprof filename1 filename2 [waits=yes|no] [sort=option] [print=n] [aggregate=yes|no] [insert=filename3] [sys=yes|no] [table=schema.table] [explain=user/password] [record=filename4] [width=n]
#
# Standard default tkprof #
# tkprof ${TRACE_FILE}.trc ${TRACE_FILE}.lst 
# less ${TRACE_FILE}.lst

#
# tkprof has numerous sort options - see documentation for full list
# Be careful to understand the three stages:
# PRS - Parsing stage - translate SQL into execution plan, check security etc. 
# EXE - Execution stage - mostly for insert, update, delete. for select stage of identifying rows
# FCH - Fetch stage - actually return rows for select 
# 
# For a typical long running query, it is the fetch stage where most of the activty takes place 
# e.g. Sort by number of consistent mode blocks during fetch
#
#
tkprof ${TRACE_FILE}.trc ${TRACE_FILE}.lst_cpu sort=fchqry explain=${SCHEMA}/${PW}
# less ${TRACE_FILE}.lst_cpu

#
# Other tkprof options of interest 
#
# INSERT - can create an insert script to store stats as a table 
# RECORD - can create a sql script to extrace the SQL used 
#
# tkprof ${TRACE_FILE}.trc ${TRACE_FILE}.lst record=${TRACE_FILE}.sql
# tkprof ${TRACE_FILE}.trc ${TRACE_FILE}.lst insert=${TRACE_FILE}_insert.sql

# less ${TRACE_FILE}.sql 
# less ${TRACE_FILE}_insert.sql 

echo "Trace Destination is " $TRACE_DEST

exit 0
