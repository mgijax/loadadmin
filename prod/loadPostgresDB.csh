#!/bin/csh -f
#
#  loadPostgresDB.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the prod/pub Postgres databases
#      that are needed by the weekly data generation processes.
#
#  Usage:
#
#      loadPostgresDB.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - MGD schema dump - with private data
#
#      - MGD schema dump - without private data
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
#      2) Wait for the flag to signal that the Postgres dumps are available.
#      3) Load the MGD schema in the prod database from the MGD dump with
#         private data.
#      4) Load the MGD schema in the pub database from the MGD dump without
#         private data.
#      5) Set the flag to signal that the Postgres databases have been loaded.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv MGD_BACKUP ${DB_BACKUP_DIR}/mgd.postgres.dump
setenv MGD_NOPRIVATE_BACKUP ${DB_BACKUP_DIR}/mgd.noprivate.postgres.dump

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

#
# Wait for the "Postgres Dump Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "Postgres Dump Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_PREP} ${FLAG_PG_DUMP_READY}`
    setenv ABORT `${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_PREP} ${FLAG_ABORT}`

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
# Load prod database.
#
date | tee -a ${LOG}
echo "Load prod database (${PG_PROD_DBSERVER}.${PG_PROD_DBNAME}.mgd)" | tee -a ${LOG}
${PG_DBUTILS}/bin/loadDB.csh ${PG_PROD_DBSERVER} ${PG_PROD_DBNAME} mgd ${MGD_BACKUP} >> ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Load pub database.
#
date | tee -a ${LOG}
echo "Load pub database (${PG_PUB_DBSERVER}.${PG_PUB_DBNAME}.mgd)" | tee -a ${LOG}
${PG_DBUTILS}/bin/loadDB.csh ${PG_PUB_DBSERVER} ${PG_PUB_DBNAME} mgd ${MGD_NOPRIVATE_BACKUP} >> ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

date | tee -a ${LOG}
echo 'Set process control flag: Postgres DB Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_PREP} ${FLAG_PG_DB_LOADED} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
