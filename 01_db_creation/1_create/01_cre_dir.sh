#
# Database specific

mkdir -p /data/oradata/dbarep

#
# Standard Admin directories
mkdir -p /opt/oracle/admin/dbarep
mkdir -p /opt/oracle/admin/dbarep/create
mkdir -p /opt/oracle/admin/dbarep/scripts
mkdir -p /opt/oracle/admin/dbarep/logs
mkdir -p /opt/oracle/admin/dbarep/old_logs
#
# Always manually create area for Audit dump files
#
mkdir -p /opt/oracle/admin/dbarep/adump

#
# Always manually create area for flash 
#
mkdir -p /oraflash/dbarep/flash_recovery_area

#
# Backup locations - assumes /orabackup is already mounted - db01 is example hostname

mkdir -p /orabackup/rman/db01/dbarep
mkdir -p /orabackup/datapump/db01/dbarep
