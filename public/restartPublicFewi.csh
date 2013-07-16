#!/bin/csh -f
#
#  restartPublicFewi.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for restarting the public Fewi JBoss
#      instance.
#
#  Usage:
#
#      restartPublicFewi.csh
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
#            one (based on the "Inactive Public" Setting) at the time
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
#      5) Restart the public Fewi JBoss instance.
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
# "Inactive Public" setting. The inactive Fewi is the one that needs to be
# restarted.
#
date | tee -a ${LOG}
echo 'Determine if pub1 or pub2 is currently inactive' | tee -a ${LOG}

setenv SETTING `${PROC_CTRL_CMD_PUB}/getSetting ${SET_INACTIVE_PUB}`
if ( "${SETTING}" == "pub1" || "${SETTING}" == "pub2") then
    echo "Inactive Public: ${SETTING}" | tee -a ${LOG}
else
    echo 'Cannot determine whether pub1 or pub2 is inactive' | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Determine if the "Inactive Public" setting corresponds to this server by
# comparing the last digit from the setting and server name. If this is not
# the inactive Fewi server, just end the script.
#
# NOTE: This assumes that the server name ends with "1" or "2" to match
# "pub1" or "pub2".
#
set PUB_NUM=`echo ${SETTING} | sed 's/.*\(.\)$/\1/'`
set SERVER_NUM=`uname -n | sed 's/.*\(.\)$/\1/'`

if ( "${PUB_NUM}" != "${SERVER_NUM}" ) then
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
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_WEBSHR_SWAPPED}`
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
# Regenerate templates and GlobalConfig from webshare.
#
date | tee -a ${LOG}
echo 'Regenerate templates and GlobalConfig from webshare' | tee -a ${LOG}
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare

#
# Reinstall Fewi to pull in GlobalConfig.
#
date | tee -a ${LOG}
echo 'Reinstall Fewi to pull in GlobalConfig' | tee -a ${LOG}
cd ${MGI_LIVE}/fewi
./Install

#
# Restart the public Fewi JBoss instance.
#
date | tee -a ${LOG}
echo 'Restart the public Fewi JBoss instance' | tee -a ${LOG}
${LOADADMIN}/jboss/restartFewi >& /dev/null

#
# Restart the public Fewi Batch JBoss instance.
#
date | tee -a ${LOG}
echo 'Restart the public Fewi Batch JBoss instance' | tee -a ${LOG}
${LOADADMIN}/jboss/restartFewiBatch >& /dev/null

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
