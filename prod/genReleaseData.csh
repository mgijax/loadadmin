#!/bin/csh -f
#
#  prepareData.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper around the processes that are needed to
#      convert Sybase databases to Postgres (exporter), build the frontend
#      Postgres database (mover) and build the inactive public/robot
#      frontend Solr indexes.
#
#  Usage:
#
#      prepareData.csh
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
#      2) Export the radar and mgd databases from Sybase to Postgres.
#      3) Set the flag to signal that the export is done.
#      4) Wait for the flag to signal that the snp database is ready.
#      5) Create a dump of the SNP Postgres database.
#      6) Build the frontend Postgres database.
#      7) Create a dump of the frontend Postgres database.
#      8) Set the flag to signal that the Postgres database dumps are ready.
#      9) Build the inactive public frontend Solr indexes.
#      10) Set the flag to signal that the inactive public frontend Solr
#          indexes have been loaded.
#      11) Build the inactive robot frontend Solr indexes.
#      12) Set the flag to signal that the inactive robot frontend Solr
#          indexes have been loaded.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv SNP_BACKUP /export/dump/snp.postgres.dump
setenv FE_BACKUP /export/dump/fe.postgres.dump

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

#
# Determine whether pub1 or pub2 is currently inactive by checking the
# "Inactive Public" setting.
#
date | tee -a ${LOG}
echo 'Determine if pub1 or pub2 is currently inactive' | tee -a ${LOG}

setenv INACTIVE_PUB `${PROC_CTRL_CMD_PUB}/getSetting ${SET_INACTIVE_PUB}`
if ( "${INACTIVE_PUB}" == "pub1" || "${INACTIVE_PUB}" == "pub2") then
    echo "Inactive Public: ${INACTIVE_PUB}" | tee -a ${LOG}
else
    echo 'Cannot determine whether pub1 or pub2 is inactive' | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Determine whether bot1 or bot2 is currently inactive by checking the
# "Inactive Robot" setting.
#
date | tee -a ${LOG}
echo 'Determine if bot1 or bot2 is currently inactive' | tee -a ${LOG}

setenv INACTIVE_BOT `${PROC_CTRL_CMD_ROBOT}/getSetting ${SET_INACTIVE_BOT}`
if ( "${INACTIVE_BOT}" == "bot1" || "${INACTIVE_BOT}" == "bot2") then
    echo "Inactive Robot: ${INACTIVE_BOT}" | tee -a ${LOG}
else
    echo 'Cannot determine whether bot1 or bot2 is inactive' | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Clear the "Postgres Dump Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: Postgres Dump Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/clearFlag ${NS_DATA_PREP} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}
${PROC_CTRL_CMD_PROD}/clearFlag ${NS_DATA_PREP} ${FLAG_EXPORT_DONE} ${SCRIPT_NAME}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_PUB_LOAD} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}
${PROC_CTRL_CMD_ROBOT}/clearFlag ${NS_ROBOT_LOAD} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}

#
# Export Sybase to Postgres.
#
date | tee -a ${LOG}
echo "Export Sybase to Postgres" | tee -a ${LOG}
${EXPORTER}/bin/export_wrapper.sh >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "Export Done" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Export Done' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_PREP} ${FLAG_EXPORT_DONE} ${SCRIPT_NAME}

#
# Wait for the "SNP Loaded" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "SNP Loaded" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_PREP} ${FLAG_SNP_LOADED}`
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
# Dump the SNP Postgres database.
#
date | tee -a ${LOG}
echo "Dump the SNP Postgres database" | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} snp ${SNP_BACKUP} >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Build the frontend Postgres database.
#
date | tee -a ${LOG}
echo "Build the frontend Postgres database" | tee -a ${LOG}
${FEMOVER}/control/buildDB.sh postgres >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Dump the frontend Postgres database.
#
date | tee -a ${LOG}
echo "Dump the frontend Postgres database" | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_FE_DBSERVER} ${PG_FE_DBNAME} fe ${FE_BACKUP} >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "Postgres Dump Ready" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Postgres Dump Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_PREP} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}
${PROC_CTRL_CMD_ROBOT}/setFlag ${NS_ROBOT_LOAD} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}

#
# Build the inactive public frontend Solr indexes.
#
date | tee -a ${LOG}
echo "Build the inactive public frontend Solr indexes" | tee -a ${LOG}
${FEINDEXER}/bin/configureAndBuildAll ${INACTIVE_PUB}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "Frontend Solr Indexes Loaded" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Frontend Solr Indexes Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_FEIDX_LOADED} ${SCRIPT_NAME}

#
# Build the inactive robot frontend Solr indexes.
#
date | tee -a ${LOG}
echo "Build the inactive robot frontend Solr indexes" | tee -a ${LOG}
${FEINDEXER}/bin/configureAndBuildAll ${INACTIVE_BOT}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "Frontend Solr Indexes Loaded" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Frontend Solr Indexes Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_ROBOT}/setFlag ${NS_ROBOT_LOAD} ${FLAG_FEIDX_LOADED} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
