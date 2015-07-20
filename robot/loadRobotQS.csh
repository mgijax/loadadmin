#!/bin/csh -f
#
#  loadRobotQS.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the robot Quick Search (QS)
#      indexes.
#
#  Usage:
#
#      loadRobotQS.csh
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
#      - Robot QS indexes (${ST_ROBOT_INDEXES})
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
#      2) Wait for the flag to signal that the QS index tar file is available.
#      3) Load the robot QS indexes from the tar file.
#      4) Wait for the flag to signal that webshare has been swapped.
#      5) Regenerate templates and GlobalConfig from webshare.
#      6) Restart the robot QS JBoss instance.
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
# Wait for the "QS Index Tar File Ready" flag to be set. Stop waiting if the
# number of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "QS Index Tar File Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_ROBOT}/getFlag ${NS_ROBOT_LOAD} ${FLAG_QS_TAR_FILE}`
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
# Remove the contents of the robot QS index directory and reload it from the
# tar file.
#
date | tee -a ${LOG}
echo "Load robot QS indexes (${ST_ROBOT_INDEXES})" | tee -a ${LOG}
rm -rf ${ST_ROBOT_INDEXES}/*
cd ${ST_ROBOT_INDEXES}
tar xvf ${ST_PUB_TARFILE}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Wait for the "Webshare Swapped" flag to be set. Stop waiting if the
# number of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "Webshare Swapped" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_ROBOT}/getFlag ${NS_ROBOT_LOAD} ${FLAG_WEBSHR_SWAPPED}`
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
# Regenerate templates and GlobalConfig from webshare.
#
date | tee -a ${LOG}
echo 'Regenerate templates and GlobalConfig from webshare' | tee -a ${LOG}
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare

#
# Restart the robot QS JBoss instance.
#
date | tee -a ${LOG}
echo 'Restart the robot QS JBoss instance' | tee -a ${LOG}
${LOADADMIN}/jboss/restartSearchtool_robot >& /dev/null
sleep 60

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
