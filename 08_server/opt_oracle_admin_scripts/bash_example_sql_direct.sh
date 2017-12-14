#!/bin/bash
#################################################################
#
# Name:          bash_example_sql_direct.sh
#
# Purpose:       Example bash script with embedded SQL. Clone as desired
#                Commonly used for simple SQL commands where a separate SQL script would be overkill.
#
# Usage:         bash_example_sql_direct.sh <sid>
#                bash_example_sql_direct.sh dbarep
#
#                Note some hardcoding of base Oracle installation
#
# Date            Who             Description
#
# 12th Sep 2017   Aidan Lawrence  Cleaned up for git
#

#
# Validate parameters
#
if [[ -n "$1" ]]; then
     #
     # Set parameters
     export ORACLE_SID=$1
     #
     # User oraenv to set Oracle environment based on /etc/oratab
     export ORACLE_BASE=/opt/oracle
     export ORAENV_ASK=NO
     . /usr/local/bin/oraenv
     unset ORAENV_ASK

    export PATH=$PATH:/usr/local/bin:/usr/kerberos/bin:/bin:/usr/bin:/usr/sbin:
    export TNS_ADMIN=/opt/oracle/tns
    export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

else
#
# Invalid input
#
    echo invalid input
    DISPLAYTIME=$(date +%c)
    echo Subject: Attempt to run bash_example_sql_direct.sh with invalid parameter $1 $2 at ${DISPLAYTIME}
    exit 1
fi
#
# Execute desired command as sysdba

# Logfile switch example
sqlplus -s '/ as sysdba ' <<EOF
            alter system switch logfile;
            exit
EOF

# Purge Recyclebin example
# sqlplus -s '/ as sysdba ' <<EOF
#            purge dba_recyclebin;
#            exit
# EOF

RESULT=$?

            if [ $RESULT -eq 0 ] # purge ok
            then
                            echo "OK"
                            echo $RESULT
            else
                            echo "NOT OK"
                            echo $RESULT
            fi

exit 0
