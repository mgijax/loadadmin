#!/bin/csh -f
#
#  load_public_indexes.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the public indexes.
#
#  Usage:
#
#      load_public_indexes.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - Public index tar file (${ST_PUB_TARFILE})
#
#      - Process control flags
#
#  Outputs:
#
#      - Public indexes (${ST_PUB1_INDEXES} or ${ST_PUB2_INDEXES})
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
#      2) Determine which public index is currently inactive.
#      3) Wait for the flag to signal that the index tar file is available.
#      4) Load the inactive public indexes from the tar file.
#      5) Set the flag to signal that the indexes have been loaded.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

#
# Determine which public index is currently inactive by checking the
# "Inactive Public DB" setting. The inactive index is the one that needs
# to be loaded.
#
setenv SETTING `${PROC_CTRL_CMD_PUB}/getSetting ${SET_INACTIVE_PUB_DB}`
if ( "${SETTING}" == "pub_1" ) then
    setenv ST_INDEX ${ST_PUB1_INDEXES}
else if ( "${SETTING}" == "pub_2" ) then
    setenv ST_INDEX ${ST_PUB2_INDEXES}
else
    echo 'Cannot determine which public index is inactive' | tee -a ${LOG}
    exit 1
endif

#
# Wait for the "Index Tar File Ready" flag to be set. Stop waiting if the
# number of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "Index Tar File Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_INDEX_TAR_FILE}`
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
# Clear the "Index Tar File Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: Index Tar File Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_PUB_LOAD} ${FLAG_INDEX_TAR_FILE} ${SCRIPT_NAME}

#
# Remove the contents of the inactive public index directory and reload it
# from the tar file.
#
date | tee -a ${LOG}
echo "Load inactive public index (${ST_INDEX})" | tee -a ${LOG}
rm -rf ${ST_INDEX}/*
cd ${ST_INDEX}
tar xvf ${ST_PUB_TARFILE}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "Index Loaded" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Index Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_INDEX_LOADED} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
