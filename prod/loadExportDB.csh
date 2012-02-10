#!/bin/csh -f
#
#  loadExportDB.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the production database that is
#      needed by the exporter.
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
#      - MGD database backup files (from /lindon/sybase)
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
#      2) Reset all flags in the export database namespace.
#      3) Wait for the flag to signal that the MGD backup is available.
#      4) Load the MGD export database.
#      5) Set the flag to signal that the export database has been loaded.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv MGD_BACKUP /lindon/sybase/mgd.backup

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Reset process control flags in database export namespace' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/resetFlags ${NS_DB_EXPORT} ${SCRIPT_NAME}

#
# Wait for the "MGD Backup Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MGD Backup Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_MGD_BACKUP}`
    setenv ABORT `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_ABORT}`

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
echo "Load MGD export database (${MGDEXP_DBSERVER}..${MGDEXP_DBNAME}) and delete private data" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${MGDEXP_DBSERVER} ${MGDEXP_DBNAME} ${MGD_BACKUP} deleteprivate
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

date | tee -a ${LOG}
echo 'Set process control flag: Export DB Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DB_EXPORT} ${FLAG_EXP_DB_LOADED} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
