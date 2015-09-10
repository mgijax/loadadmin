#!/bin/csh -f
#
#  genReleaseData.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper around the steps that are needed to
#      generate data for the weekly public/robot update.
#
#  Usage:
#
#      genReleaseData.csh
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
#      2) Determine which public and robot instances are inactive.
#      3) Reset process control namespaces.
#      4) Load the database used for public data generation.
#      5) Set the flag to signal that the public data generation databases
#         have been loaded.
#      6) Wait for the flag to signal that the snp database is ready.
#      7) Dump the SNP schema.
#      8) Delete private data from the MGD schema.
#      9) Dump the MGD schema (with no private data).
#      10) Set the flag to signal that the Postgres dumps are ready.
#      11) Build the frontend schema.
#      12) Dump the frontend schema.
#      13) Set the flag to signal that the FE dump is ready.
#      14) Build the inactive public Solr indexes.
#      15) Set the flag to signal that the inactive public Solr indexes
#          have been loaded.
#      16) Build the inactive robot Solr indexes.
#      17) Set the flag to signal that the inactive robot Solr indexes
#          have been loaded.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv PROD_MGD_BACKUP ${DB_BACKUP_DIR}/mgd.postdaily.dump

setenv SNP_BACKUP /export/dump/snp.postgres.dump
setenv MGD_NOPRIVATE_BACKUP /export/dump/mgd.noprivate.postgres.dump
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
# Reset process control namespaces.
#
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
# Load the database for public data generation.
#
date | tee -a ${LOG}
echo 'Load the database for public data generation' | tee -a ${LOG}
${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${PROD_MGD_BACKUP} >>& ${LOG}

#
# Set the "Gen DB Loaded" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Gen DB Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_PREP} ${FLAG_GEN_DB_LOADED} ${SCRIPT_NAME}

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
# Dump the SNP schema.
#
date | tee -a ${LOG}
echo "Dump the SNP schema" | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} snp ${SNP_BACKUP} >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Delete private data from the MGD schema.
#
date | tee -a ${LOG}
echo "Delete private data from the MGD schema" | tee -a ${LOG}
${PG_DBUTILS}/sp/MGI_deletePrivateData.csh ${PG_DBSERVER} ${PG_DBNAME} >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Dump the MGD schema (with no private data).
#
date | tee -a ${LOG}
echo "Dump the MGD schema (with no private data)" | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${MGD_NOPRIVATE_BACKUP} >>& ${LOG}
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

#
# Build the frontend schema.
#
date | tee -a ${LOG}
echo "Build the frontend schema" | tee -a ${LOG}
${FEMOVER}/control/buildDB.sh postgres >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Dump the frontend schema.
#
date | tee -a ${LOG}
echo "Dump the frontend schema" | tee -a ${LOG}
${PG_DBUTILS}/bin/dumpDB.csh ${PG_FE_DBSERVER} ${PG_FE_DBNAME} fe ${FE_BACKUP} >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "FE Dump Ready" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: FE Dump Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_FE_DUMP_READY} ${SCRIPT_NAME}
${PROC_CTRL_CMD_ROBOT}/setFlag ${NS_ROBOT_LOAD} ${FLAG_FE_DUMP_READY} ${SCRIPT_NAME}

#
# Build the inactive public Solr indexes.
#
date | tee -a ${LOG}
echo "Build the inactive public Solr indexes" | tee -a ${LOG}
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
# Build the inactive robot Solr indexes.
#
date | tee -a ${LOG}
echo "Build the inactive robot Solr indexes" | tee -a ${LOG}
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
