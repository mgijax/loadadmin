#!/bin/csh -f
#
#  fridaytasks.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for the Friday production tasks.
#
#  Usage:
#
#      fridaytasks.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - Process control flags
#
#  Outputs:
#
#      - Database backup files (in /extra1/sybase)
#          - mgd.prefridaybackup1, mgd.prefridaybackup2
#          - mgd.backup1, mgd.backup2
#          - radar.backup1 radar.backup2
#          - master.backup1, master.backup2
#          - wts.backup1, wts.backup2
#          - sybsystemprocs.backup1, sybsystemprocs.backup2
#
#      - Log file for the script (${LOG})
#
#      - Process control flags
#
#  Exit Codes:
#
#      0:  Successful completion
#      1:  Fatal error occurred
#
#  Assumes:  Nothing
#
#  Implementation:
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv DATABASES "master sybsystemprocs ${MGD_DBNAME} ${WTS_DBNAME} ${RADAR_DBNAME}"

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

#
# Use the GNU version of the date command to get tomorrow's date. This will
# be used to update the last dump date in the MGD database.
#
set tomorrow=`/usr/local/bin/date -d tomorrow +%m/%d/%Y`

date | tee -a ${LOG}
echo 'Reset all process control flags' | tee -a ${LOG}
${PROC_CTRL_CMD_DEV}/resetFlags ${NS_DEV_LOAD} ${SCRIPT_NAME}
${PROC_CTRL_CMD_PROD}/resetFlags ${NS_PROD_LOAD} ${SCRIPT_NAME}

# run this as early as possible for JAX folks
date | tee -a ${LOG}
echo 'MGI Marker Feed' | tee -a ${LOG}
${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh

date | tee -a ${LOG}
echo 'Create Pre-Friday Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME}" prefriday

date | tee -a ${LOG}
echo 'Set process control flag: MGD PreBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_PROD_LOAD} ${FLAG_MGD_PREBACKUP} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Update Statistics' | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateStatisticsAll.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${MGD_DBSCHEMADIR}

#date | tee -a ${LOG}
#echo 'Start DBCC Checker' | tee -a ${LOG}
#${MGI_DBUTILS}/bin/mgi_check_db.csh ${MGD_DBSERVER} ${MGD_DBNAME}

date | tee -a ${LOG}
echo 'Create Reference Set' | tee -a ${LOG}
${MGI_DBUTILS}/bin/runReferenceSet.csh ${MGD_DBSERVER} ${MGD_DBNAME}

date | tee -a ${LOG}
echo 'Update Last Dump Date' | tee -a ${LOG}
${MGI_DBUTILS}/bin/updateLastDumpDate.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${tomorrow}

date | tee -a ${LOG}
echo 'Create Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${DATABASES}"

date | tee -a ${LOG}
echo 'Set process control flag: MGD Backup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_DEV}/setFlag ${NS_DEV_LOAD} ${FLAG_MGD_BACKUP} ${SCRIPT_NAME}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_PROD_LOAD} ${FLAG_MGD_BACKUP} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Mammalian Phenotype Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh MP.config

date | tee -a ${LOG}
echo 'QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh

#
# run this last so that we are sure to pick up the new GO files that
# are downloaded at 1:30AM
#
date | tee -a ${LOG}
echo 'GO Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh GO.config

date | tee -a ${LOG}
echo 'Move JFiles' | tee -a ${LOG}
${JFILESCANNER}/moveJfiles.sh

#
# Uncomment this when an extra backup is needed.
#
#date | tee -a ${LOG}
#echo 'Create Post-Friday Database Backup' | tee -a ${LOG}
#${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME}" postfriday

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
