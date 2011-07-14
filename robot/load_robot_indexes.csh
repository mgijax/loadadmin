#!/bin/csh -f
#
#  load_robot_indexes.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the robot indexes.
#
#  Usage:
#
#      load_robot_indexes.csh
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
#      - Robot indexes (${ST_ROBOT_INDEXES})
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
#      2) Wait for the flag to signal that the index tar file is available.
#      3) Load the robot indexes from the tar file.
#      4) Restart the robot JBoss server.
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
# Wait for the "Index Tar File Ready" flag to be set. Stop waiting if the
# number of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "Index Tar File Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_ROBOT}/getFlag ${NS_ROBOT_LOAD} ${FLAG_INDEX_TAR_FILE}`
    setenv ABORT `${PROC_CTRL_CMD_ROBOT}/getFlag ${NS_ROBOT_LOAD} ${FLAG_ABORT}`

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
${PROC_CTRL_CMD_ROBOT}/clearFlag ${NS_ROBOT_LOAD} ${FLAG_INDEX_TAR_FILE} ${SCRIPT_NAME}

#
# Remove the contents of the robot index directory and reload it from the
# tar file.
#
date | tee -a ${LOG}
echo "Load robot index (${ST_ROBOT_INDEXES})" | tee -a ${LOG}
rm -rf ${ST_ROBOT_INDEXES}/*
cd ${ST_ROBOT_INDEXES}
tar xvf ${ST_PUB_TARFILE}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Restart the robot JBoss server.
#
date | tee -a ${LOG}
echo 'Restart the robot JBoss server' | tee -a ${LOG}
${LOADADMIN}/jboss/restartSearchtool_robot
sleep 60

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
