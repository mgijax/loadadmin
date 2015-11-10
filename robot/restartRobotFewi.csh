#!/bin/csh -f
#
#  restartRobotFewi.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for restarting the robot Fewi JBoss
#      instance.
#
#  Usage:
#
#      restartRobotFewi.csh
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
#  Exit Codes:
#
#      0:  Successful completion
#      1:  Fatal error occurred
#
#  Assumes:  The Fewi that needs to be restarted is still the inactive
#            one (based on the "Inactive Robot" Setting) at the time
#            when this script is started.
#
#  Implementation:
#
#      This script will perform the following steps:
#
#      1) Source the configuration file to establish the environment.
#      2) Determine if this script is being run on the Fewi server
#         that is currently inactive. Exit if this server is active.
#      3) Wait for the flag to signal that webshare has been swapped.
#      4) Regenerate templates and GlobalConfig from webshare.
#      5) Reinstall and deploy the Fewi.
#      6) Restart the robot Fewi JBoss instance.
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
# Determine whether bot1 or bot2 is currently inactive by checking the
# "Inactive Robot" setting. The inactive Fewi is the one that needs to be
# restarted.
#
date | tee -a ${LOG}
echo 'Determine if bot1 or bot2 is currently inactive' | tee -a ${LOG}

setenv SETTING `${PROC_CTRL_CMD_ROBOT}/getSetting ${SET_INACTIVE_BOT}`
if ( "${SETTING}" == "bot1" || "${SETTING}" == "bot2") then
    echo "Inactive Robot: ${SETTING}" | tee -a ${LOG}
else
    echo 'Cannot determine whether bot1 or bot2 is inactive' | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Determine if the "Inactive Robot" setting corresponds to this server by
# comparing the last digit from the setting and server name. If this is not
# the inactive Fewi server, just end the script.
#
# NOTE: This assumes that the server name ends with "1" or "2" to match
# "bot1" or "bot2".
#
set BOT_NUM=`echo ${SETTING} | sed 's/.*\(.\)$/\1/'`
set SERVER_NUM=`uname -n | sed 's/.*\(.\)$/\1/'`

if ( "${BOT_NUM}" != "${SERVER_NUM}" ) then
    echo 'This is not the inactive Fewi server ... exiting' | tee -a ${LOG}
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
# Reinstall and deploy the Fewi.
#
date | tee -a ${LOG}
echo 'Reinstall and deploy the Fewi' | tee -a ${LOG}
cd ${MGI_LIVE}/fewi
./Install

#
# Restart the robot Fewi JBoss instance.
#
date | tee -a ${LOG}
echo 'Restart the robot Fewi JBoss instance' | tee -a ${LOG}
${LOADADMIN}/jboss/restartFewi >& /dev/null

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
