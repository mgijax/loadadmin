#!/bin/csh -f
#
#  load_prod_to_dev.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the development database(s).
#
#  Usage:
#
#      load_prod_to_dev.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - MGD database backup files (from /lindon/sybase)
#
#      - RADAR database backup files (from /lindon/sybase)
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
#      This script will perform following steps:
#
#      1) Source the configuration file to establish the environment.
#      2) Wait for the flag to signal that the MGD backup is available.
#      3) Load the MGD database.
#      4) Load the RADAR database.
#      5) Update statistics on all tables.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv MGD_BACKUP /lindon/sybase/mgd.backup
setenv RADAR_BACKUP /lindon/sybase/radar.backup

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

#
# Wait for the "MGD Backup Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MGD Backup Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_DEV}/getFlag ${NS_DEV_LOAD} ${FLAG_MGD_BACKUP}`
    setenv ABORT `${PROC_CTRL_CMD_DEV}/getFlag ${NS_DEV_LOAD} ${FLAG_ABORT}`

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
# Clear the "MGD Backup Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: MGD Backup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_DEV}/clearFlag ${NS_DEV_LOAD} ${FLAG_MGD_BACKUP} ${SCRIPT_NAME}

#
# Load MGD and RADAR databases from the production backups.
#
date | tee -a ${LOG}
echo "Load MGD database (DEV_MGI..mgd)" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh DEV_MGI mgd ${MGD_BACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

date | tee -a ${LOG}
echo "Load RADAR database (DEV_MGI..radar)" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh DEV_MGI radar ${RADAR_BACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
