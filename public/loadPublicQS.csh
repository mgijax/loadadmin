#!/bin/csh -f
#
#  loadPublicQS.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the inactive public Quick
#      Search (QS) indexes.
#
#  Usage:
#
#      loadPublicQS.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - QS index tar file (${ST_PUB_TARFILE})
#
#      - Process control flags
#
#  Outputs:
#
#      - Public QS indexes (${ST_PUB1_INDEXES} or ${ST_PUB2_INDEXES})
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
#      2) Determine which public QS indexes are currently inactive.
#      3) Wait for the flag to signal that the QS index tar file is available.
#      4) Load the inactive public QS indexes from the tar file.
#      5) Set the flag to signal that the public QS indexes have been loaded.
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
# Determine whether pub1 or pub2 is currently inactive by checking the
# "Inactive Public" setting. The inactive QS indexes are the ones that need
# to be loaded.
#
date | tee -a ${LOG}
echo 'Determine if pub1 or pub2 is currently inactive' | tee -a ${LOG}

setenv SETTING `${PROC_CTRL_CMD_PUB}/getSetting ${SET_INACTIVE_PUB}`
if ( "${SETTING}" == "pub1" ) then
    setenv ST_INDEX ${ST_PUB1_INDEXES}
else if ( "${SETTING}" == "pub2" ) then
    setenv ST_INDEX ${ST_PUB2_INDEXES}
else
    echo 'Cannot determine whether pub1 or pub2 is inactive' | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif
echo "Inactive Public: ${SETTING}" | tee -a ${LOG}

#
# Wait for the "QS Index Tar File Ready" flag to be set. Stop waiting if the
# number of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "QS Index Tar File Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_QS_TAR_FILE}`
    setenv ABORT `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_ABORT}`

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
# Remove the contents of the inactive public QS indexes directory and reload
# it from the tar file.
#
date | tee -a ${LOG}
echo "Load inactive public QS indexes (${ST_INDEX})" | tee -a ${LOG}
rm -rf ${ST_INDEX}/*
cd ${ST_INDEX}
tar xvf ${ST_PUB_TARFILE}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "QS Indexes Loaded" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: QS Indexes Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_QS_LOADED} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
