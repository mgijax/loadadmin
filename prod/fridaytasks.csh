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
#          - mgd.predailybackup1, mgd.predailybackup2
#          - mgd.backup1, mgd.backup2
#          - radar.backup1 radar.backup2
#          - master.backup1, master.backup2
#          - wts.backup1, wts.backup2
#          - sybsystemprocs.backup1, sybsystemprocs.backup2
#          - mgd.postdailybackup1, mgd.postdailybackup2
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
echo 'Reset process control flags in dev load namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_DEV}/resetFlags ${NS_DEV_LOAD} ${SCRIPT_NAME}
echo 'Reset process control flags in data loads namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/resetFlags ${NS_DATA_LOADS} ${SCRIPT_NAME}

#
# Generate the MGI marker feed as early as possible for JAX folks.
#
date | tee -a ${LOG}
echo 'MGI Marker Feed' | tee -a ${LOG}
${PUBRPTS}/mgimarkerfeed/mgimarkerfeed_reports.csh

date | tee -a ${LOG}
echo 'Create Pre-Daily Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME}" predaily

date | tee -a ${LOG}
echo 'Set process control flag: MGD PreBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_LOADS} ${FLAG_MGD_PREBACKUP} ${SCRIPT_NAME}

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
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_LOADS} ${FLAG_MGD_BACKUP} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo 'Mammalian Phenotype Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh MP.config

date | tee -a ${LOG}
echo 'Run EMAP Load' | tee -a ${LOG}
${EMAPLOAD}/bin/emapload.sh

date | tee -a ${LOG}
echo 'Nightly QC Reports' | tee -a ${LOG}
${QCRPTS}/qcnightly_reports.csh

#
date | tee -a ${LOG}
echo 'GO Load' | tee -a ${LOG}
${VOCLOAD}/runOBOIncLoad.sh GO.config

date | tee -a ${LOG}
echo 'Move JFiles' | tee -a ${LOG}
${JFILESCANNER}/moveJfiles.sh

date | tee -a ${LOG}
echo 'Create Post-Daily Database Backup' | tee -a ${LOG}
${MGI_DBUTILS}/bin/mgi_backup_to_disk.csh ${MGD_DBSERVER} "${MGD_DBNAME}" postdaily

date | tee -a ${LOG}
echo 'Set process control flag: MGD PostBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_DEV}/setFlag ${NS_DEV_LOAD} ${FLAG_MGD_POSTBACKUP} ${SCRIPT_NAME}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_LOADS} ${FLAG_MGD_POSTBACKUP} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
