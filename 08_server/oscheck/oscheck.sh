#!/bin/bash
#################################################################
#
# Name:          oscheck.sh
#
# Purpose:       OS level check split of from oscheck 
#
# Usage:         oscheck.sh. Note some hardcoding of paths etc for simplicity
#
# Date            Who             Description
#
# 12th Sep 2017   Aidan Lawrence  Fully genericised and validated for git
#

oscheck_content_header()
{
echo 'Content-Type: text/html; charset="us-ascii"'>> $OSCHECK_CONTENT
echo "<html>" >> $OSCHECK_CONTENT
echo "<H1>" >> $OSCHECK_CONTENT
echo "Healthcheck for server $MACHINE" >> $OSCHECK_CONTENT
echo "</H1>" >> $OSCHECK_CONTENT
# echo <meta charset=\"utf-8\" /> >> $OSCHECK_CONTENT
# echo <meta name=viewport content=\"width=device-width, initial-scale=1.0\"> >> $OSCHECK_CONTENT
# echo "<title>Healthcheck for server $MACHINE</title>"  >> $OSCHECK_CONTENT
echo "<body><pre>" >> $OSCHECK_CONTENT
}

oscheck_content_footer()
{
echo "" >> $OSCHECK_CONTENT
echo "<H1>" >> $OSCHECK_CONTENT
echo "Healthcheck for server $MACHINE complete" >> $OSCHECK_CONTENT
echo "" >> $OSCHECK_CONTENT
echo "</H1>" >> $OSCHECK_CONTENT
echo "</pre>" >> $OSCHECK_CONTENT
echo "</body>" >> $OSCHECK_CONTENT
echo "</html>" >> $OSCHECK_CONTENT
}

mail_oscheck()
{
	DISPLAYTIME=$(date +%c)
	echo Subject: oscheck completed for $MACHINE  at ${DISPLAYTIME} > $OSCHECK_SUBJECT
	cat $OSCHECK_SUBJECT $OSCHECK_CONTENT > $OSCHECK_MAIL
	/usr/sbin/sendmail  -t $EMAIL_DIST < $OSCHECK_MAIL

}

##
## Display uptime
##

uptime_ck()
{

uptime|awk '{print $2" "$3" "$4}'|sed -e 's/,.*//g'|grep day 2>&1 > /dev/null
if [ `echo $?` != 0 ]
then   
echo -e "System Uptime :" `uptime|awk '{print $2" "$3" "$4}'|sed -e 's/,.*//g'`" hours" >> $OSCHECK_CONTENT
else
echo -e "System Uptime :" `uptime|awk '{print $2" "$3" "$4}'|sed -e 's/,.*//g'` >> $OSCHECK_CONTENT
fi

}

##
## Load Average
##

load_average ()
{

echo -e "Current Load Average :" `uptime|grep -o "load average.*"|awk '{print $3" " $4" " $5}'` >> $OSCHECK_CONTENT

}

os_summary()
{

if [ -e /usr/bin/lsb_release ]
then 
echo -e "Operating System :" `lsb_release -d|awk -F: '{print $2}'|sed -e 's/^[ \t]*//'` >> $OSCHECK_CONTENT
else
echo -e  "Operating System :" `cat /etc/system-release` >> $OSCHECK_CONTENT
fi
echo -e "Kernel Version :"`uname -r` >> $OSCHECK_CONTENT

}


## Check for any read-only file system

filesystem_ro()
{
echo "" >> $OSCHECK_CONTENT
mount|egrep -viw "sys|proc|udev|tmpfs|devpts|none|iso9660|fuse|swap|sunrpc" > /tmp/mounted.fs.out

if [ `cat /tmp/mounted.fs.out|awk '{print $6}'|grep ro|wc -l` -ge 1 ];
then 
	echo "Read-only Filesystems found  " >> $OSCHECK_CONTENT
	cat /tmp/mounted.fs.out|grep -w 'ro' >> $OSCHECK_CONTENT
else
	echo "No read-only file systems found" >> $OSCHECK_CONTENT
fi

}

## Check for any zombie processes

zombie_procs()
{

echo "" >> $OSCHECK_CONTENT

if [ `ps -eo stat|grep -w Z|wc -l` -ge 1 ];
  then
  echo -e "Number of zombie process on the system are :" `ps -eo stat|grep -w Z|wc -l` >> $OSCHECK_CONTENT
else   
  echo -e "No zombie processes on the system" >> $OSCHECK_CONTENT
fi

}


##
## Display Disk Space Usage - non database specific candidate for oscheck.sh 
##

disk_space()
{


df -h >> $OSCHECK_CONTENT 

}

##
## Basic Memory usage 
##

memory_usage ()
{

echo -e "Total RAM in MB : "$((`grep -w MemTotal /proc/meminfo|awk '{print $2}'`/1024))", in GB :"$((`grep -w MemTotal /proc/meminfo|awk '{print $2}'`/1024/1024)) >> $OSCHECK_CONTENT
echo -e "Used RAM in MB  :"$((`free -m|grep -w Mem:|awk '{print $3}'`))", in GB :"$((`free -m|grep -w Mem:|awk '{print $3}'`/1024)) >> $OSCHECK_CONTENT
echo -e "Free RAM in MB  :"$((`grep -w MemFree /proc/meminfo|awk '{print $2}'`/1024))" , in GB :"$((`grep -w MemFree /proc/meminfo|awk '{print $2}'`/1024/1024)) >> $OSCHECK_CONTENT 

}

##
## Basic Processor Utilization
##

processor_utilization ()
{

echo "" >> $OSCHECK_CONTENT
echo -e "CPU Utilization" >> $OSCHECK_CONTENT
echo "" >> $OSCHECK_CONTENT
echo -e "Manufacturer: "`grep -w "vendor_id" /proc/cpuinfo|uniq|awk '{print $3}'` >> $OSCHECK_CONTENT
echo -e "Processor Model: "`grep -w "model name" /proc/cpuinfo|uniq|awk -F":" '{print $2}'|sed 's/^ //g'` >> $OSCHECK_CONTENT
echo -e "Number of processors/cores: "`cat /proc/cpuinfo |grep -wc processor` >> $OSCHECK_CONTENT

}

sar_stats ()
{
echo "" >> $OSCHECK_CONTENT
echo "sar 5 2 output " >> $OSCHECK_CONTENT
sar 5 2 >> $OSCHECK_CONTENT 
}

vmstat_stats ()
{
echo "" >> $OSCHECK_CONTENT
echo "vmstat 5 2 output " >> $OSCHECK_CONTENT
vmstat 5 2 >> $OSCHECK_CONTENT 
}

mpstat_stats ()
{
echo "" >> $OSCHECK_CONTENT
echo "mpstat 5 2 output " >> $OSCHECK_CONTENT
mpstat 5 2 >> $OSCHECK_CONTENT 
}

iostat_stats ()
{
echo "" >> $OSCHECK_CONTENT
echo "iostat 5 2 output " >> $OSCHECK_CONTENT
iostat 5 2 >> $OSCHECK_CONTENT 
}

##
## Compare oratab with running databases 
##

db_running()
{
        echo "<H3>" >> $OSCHECK_CONTENT
        echo "Contents of oratab:" >> $OSCHECK_CONTENT
		echo "</H3>" >> $OSCHECK_CONTENT
        cat /etc/oratab | grep -v [#] >> $OSCHECK_CONTENT
        echo "<H3>" >> $OSCHECK_CONTENT
        echo "Oracle PMON processes running: Should be one per oratab entry " >> $OSCHECK_CONTENT
		echo "</H3>" >> $OSCHECK_CONTENT
        ps -ef | grep pmon | grep -v grep >> $OSCHECK_CONTENT
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

#
# Ensure path includes sendmail:

export ORACLE_HOME=/opt/oracle/product/11.2.0/dbhome_1
export LD_LIBRARY_PATH=/opt/oracle/product/11.2.0/dbhome_1/lib
export PATH=$ORACLE_HOME/bin:/usr/local/bin:/usr/kerberos/bin:/bin:/usr/bin:/usr/sbin:
export TNS_ADMIN=/opt/oracle/tns
export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

SCRIPT_DIR=$BASE_DIR/scripts/oscheck
LOG_DIR=$BASE_DIR/logs/oscheck
OSCHECK_SUBJECT=$LOG_DIR/oscheck_result.subject 
OSCHECK_CONTENT=$LOG_DIR/oscheck_result.content
OSCHECK_MAIL=$LOG_DIR/oscheck_result.mail

#
# Validate parameters - NO current parameters - clone from similar if expanded 
#

#
# Clear out working files 

if [ -s $OSCHECK_SUBJECT ]
then
   rm $OSCHECK_SUBJECT
fi

if [ -s $OSCHECK_CONTENT ]
then
   rm $OSCHECK_CONTENT
fi

if [ -s $OSCHECK_MAIL ]
then
   rm $OSCHECK_MAIL
fi


#
# Post parameter validation
#

HISTFILE=$LOG_DIR/oscheck_history.log
OSCHECK_ORACLE_SID_MAIL=$LOG_DIR/oscheck_result.mail

cd $SCRIPT_DIR

#
# Clear out working files 

if [ -s $OSCHECK_MAIL ]
then
   rm $OSCHECK_MAIL
fi

#
# End of base_environment

###
# Main Checks starts here
###

#
# High level overview 
#

#
# Start the content 
oscheck_content_header

echo "<H2>" >> $OSCHECK_CONTENT
echo "Database availability " >> $OSCHECK_CONTENT
echo "</H2>" >> $OSCHECK_CONTENT
db_running

echo "<H2>" >> $OSCHECK_CONTENT
echo "Current OS Issues " >> $OSCHECK_CONTENT
echo "</H2>" >> $OSCHECK_CONTENT

# Checks for specific problems 
echo "<H3>" >> $OSCHECK_CONTENT
echo "Read-only Filesystems " >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
filesystem_ro

echo "<H3>" >> $OSCHECK_CONTENT
echo "Zombie processes " >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
zombie_procs

echo "<H2>" >> $OSCHECK_CONTENT
echo "Server Resources and Performance" >> $OSCHECK_CONTENT
echo "</H2>" >> $OSCHECK_CONTENT

echo "<H3>" >> $OSCHECK_CONTENT
echo "Uptime, Load average and OS kernel " >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
uptime_ck
load_average
os_summary


echo "<H3>" >> $OSCHECK_CONTENT
echo "Disk Space Usage " >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
disk_space

echo "<H3>" >> $OSCHECK_CONTENT
echo "Memory Utilization" >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
memory_usage

echo "<H3>" >> $OSCHECK_CONTENT
echo "Processor Utilization" >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
processor_utilization

echo "<H2>" >> $OSCHECK_CONTENT
echo "Performance Checks " >> $OSCHECK_CONTENT
echo "</H2>" >> $OSCHECK_CONTENT

echo "<H3>" >> $OSCHECK_CONTENT
echo "Recent sar output" >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
sar_stats 

echo "<H3>" >> $OSCHECK_CONTENT
echo "Recent vmstat output" >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
vmstat_stats

echo "<H3>" >> $OSCHECK_CONTENT
echo "Recent mpstat output" >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
mpstat_stats

echo "<H3>" >> $OSCHECK_CONTENT
echo "Recent iostat output" >> $OSCHECK_CONTENT
echo "</H3>" >> $OSCHECK_CONTENT
iostat_stats
 
oscheck_content_footer
mail_oscheck
exit

