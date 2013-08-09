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
#      3) Export the radar and mgd databases from Sybase to Postgres.
#      4) Set the flag to signal that the export is done.
#      5) Wait for the flag to signal that the snp database is ready.
#      6) Create a dump of the SNP schema.
#      7) Delete private data from the MGD schema.
#      8) Create a dump of the MGD schema (with no private data).
#      9) Build the frontend schema.
#      10) Create a dump of the frontend schema.
#      11) Set the flag to signal that the Postgres dumps are ready.
#      12) Build the inactive public Solr indexes.
#      13) Set the flag to signal that the inactive public Solr indexes
#          have been loaded.
#      14) Build the inactive robot Solr indexes.
#      15) Set the flag to signal that the inactive robot Solr indexes
#          have been loaded.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

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
# Clear the "Postgres Dump Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: Postgres Dump Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/clearFlag ${NS_DATA_PREP} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}
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
date >> ${LOG}
echo 'Wait for the "SNP Loaded" flag to be set' >> ${LOG}

RETRY=${PROC_CTRL_RETRIES}
while [ ${RETRY} -gt 0 ]
do
    READY=`${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_PREP} ${FLAG_SNP_LOADED}`
    ABORT=`${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_PREP} ${FLAG_ABORT}`

    if [ ${READY} -eq 1 -o ${ABORT} -eq 1 ]
    then
        break
    else
        sleep ${PROC_CTRL_WAIT_TIME}
    fi

    RETRY=`expr ${RETRY} - 1`
done

#
# Terminate the script if the number of retries expired or the abort flag
# was found.
#
if [ ${RETRY} -eq 0 ]
then
    echo "${SCRIPT_NAME} timed out" >> ${LOG}
    date >> ${LOG}
    exit 1
elif [ ${ABORT} -eq 1 ]
then
    echo "${SCRIPT_NAME} aborted by process controller" >> ${LOG}
    date >> ${LOG}
    exit 1
fi

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
# Set the "Postgres Dump Ready" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Postgres Dump Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_DATA_PREP} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}
${PROC_CTRL_CMD_ROBOT}/setFlag ${NS_ROBOT_LOAD} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}

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
