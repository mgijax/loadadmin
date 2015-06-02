#!/bin/csh -f
#
#  loadExportDB.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the MGD and RADAR databases
#      that are needed by the exporter.
#
#  Usage:
#
#      loadExportDB.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - MGD database backup files (from /extra1/sybase on lindon)
#
#      - RADAR database backup files (from /extra1/sybase on lindon)
#
#      - Process control flags
#
#  Outputs:
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
#      This script will perform the following steps:
#
#      1) Source the configuration file to establish the environment.
#      2) Reset all flags in the namespaces pertaining to the data update.
#      3) Wait for the flag to signal that the MGD backup is available.
#      4) Load the MGD export database.
#      5) Load the RADAR export database.
#      6) Set the flag to signal that the export database has been loaded.
#
#  Notes:  None
#
#  Usage: 
#       1) ./loadExportDB.csh   (the default,without arguments)
#       2) ./loadExportDB.csh BUILD  (to load DEV2_MGI.*_build databases)
#       3) ./loadExportDB.csh REL  (to load PROD1_MGI.*_be databases)
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

#
# This section sets sybase database server and database name
# to use for the exporter. It also sets the backups to use.
# By default, it uses the settings for weekly data generation
#
# This allows to use the same script for different tasks 
# (weekly update, production build, or alpha build) 
# 
if ( $# > 0 ) then
    echo "Usage: $0 $1"
    if("$1" == "BUILD") then
        setenv MGD_BACKUP ${BUILD_MGD_BACKUP}
        setenv RADAR_BACKUP ${BUILD_RADAR_BACKUP} 
        setenv MGDEXP_DBSERVER ${BUILD_MGDEXP_DBSERVER}
        setenv MGDEXP_DBNAME ${BUILD_MGDEXP_DBNAME}
        setenv RDREXP_DBSERVER ${BUILD_RDREXP_DBSERVER}
        setenv RDREXP_DBNAME ${BUILD_RDREXP_DBNAME}
     else
        setenv MGD_BACKUP ${REL_MGD_BACKUP}
        setenv RADAR_BACKUP ${REL_RADAR_BACKUP}
        setenv MGDEXP_DBSERVER ${REL_MGDEXP_DBSERVER}
        setenv MGDEXP_DBNAME ${REL_MGDEXP_DBNAME}
        setenv RDREXP_DBSERVER ${REL_RDREXP_DBSERVER}
        setenv RDREXP_DBNAME ${REL_RDREXP_DBNAME}
     endif
endif
setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
date | tee -a ${LOG}
echo "MGD backups used: ${MGD_BACKUP}" | tee -a ${LOG}
echo "Radar backups used: ${RADAR_BACKUP}" | tee -a ${LOG}
echo "MGD Sybase server used: ${MGDEXP_DBSERVER}" | tee -a ${LOG}
echo "MGD Database used: ${MGDEXP_DBNAME}" | tee -a ${LOG}
echo "Radar Sybase server used: ${RDREXP_DBSERVER}" | tee -a ${LOG}
echo "Radar Database used: ${RDREXP_DBNAME}" | tee -a ${LOG}
echo ""
env | sort >> ${LOG}

date | tee -a ${LOG}
echo 'Reset process control flags in data prep namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/resetFlags ${NS_DATA_PREP} ${SCRIPT_NAME}
echo 'Reset process control flags in public load namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/resetFlags ${NS_PUB_LOAD} ${SCRIPT_NAME}
echo 'Reset process control flags in robot load namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_ROBOT}/resetFlags ${NS_ROBOT_LOAD} ${SCRIPT_NAME}
echo 'Reset process control flags in adhoc load namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/resetFlags ${NS_ADHOC_LOAD} ${SCRIPT_NAME}

#
# Wait for the "MGD PostBackup Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MGD PostBackup Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_LOADS} ${FLAG_MGD_POSTBACKUP}`
    setenv ABORT `${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_LOADS} ${FLAG_ABORT}`

    if (${READY} == 1 || ${ABORT} == 1) then
        break
    else
        sleep ${PROC_CTRL_WAIT_TIME}
    endif

    setenv RETRY `expr ${RETRY} - 1`
end

#
# Terminate the script if the number of retries expired or the abort flag
# was found.
#
if (${RETRY} == 0) then
    echo "${SCRIPT_NAME} timed out" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
else if (${ABORT} == 1) then
    echo "${SCRIPT_NAME} aborted by process controller" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Load MGD export database.
#
date | tee -a ${LOG}
echo "Load MGD export database (${MGDEXP_DBSERVER}..${MGDEXP_DBNAME})" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${MGDEXP_DBSERVER} ${MGDEXP_DBNAME} ${MGD_BACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Load RADAR export database.
#
date | tee -a ${LOG}
echo "Load RADAR export database (${RDREXP_DBSERVER}..${RDREXP_DBNAME})" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${RDREXP_DBSERVER} ${RDREXP_DBNAME} ${RADAR_BACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

date | tee -a ${LOG}
echo 'Set process control flag: Export DB Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_PREP} ${FLAG_EXP_DB_LOADED} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
