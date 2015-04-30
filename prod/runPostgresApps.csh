#!/bin/csh -f
#
#  runPostgresApps.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper around the steps that need to be run
#      against the Postgres database for the weekly public update.
#
#  Usage:
#
#      runPostgresApps.csh
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
#      2) Wait for the flag to signal that the Postgres database has
#         been loaded.
#      3) Call the script that builds the public QS indexes.
#      4) Call the script that reloads biomart.
#      5) Call the script that generates the weekly public reports.
#      6) Set the flag to signal that the public reports are ready.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

#
# Wait for the "Postgres DB Loaded" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "Postgres DB Loaded" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_PREP} ${FLAG_PG_DB_LOADED}`
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
# Build the public QS indexes.
#
date | tee -a ${LOG}
echo "Build the public QS indexes" | tee -a ${LOG}
${LOADADMIN}/prod/buildQSIndexes.csh >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Reload Biomart.
#
date | tee -a ${LOG}
echo "Reload Biomart" | tee -a ${LOG}
${BIOMARTLOAD}/bin/reloadBiomart.csh >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Generate weekly public reports.
#
date | tee -a ${LOG}
echo "Generate weekly public reports" | tee -a ${LOG}
${PUBRPTS}/run_weekly.csh >>& ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "Public Reports Ready" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Public Reports Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_PUB_RPT_READY} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
