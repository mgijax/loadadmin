#!/bin/csh -f
#
#  robotRelease.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper that controls the robot release.
#
#  Usage:
#
#      robotRelease.csh
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
#      2) Determine whether "bot1" or "bot2" is currently inactive.
#      4) Wait for the flag to signal that the inactive databases have been
#         loaded and the inactive robot frontend Solr indexes have been loaded.
#      5) Swap the webshare GlobalConfig links.
#      6) Regenerate templates and GlobalConfig from webshare.
#      7) Set the flag to signal that webshare has been swapped.
#      8) Toggle the inactive robot setting.
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
# "Inactive Robot" setting. This setting will need to be toggled
# when the release is completed.
#
date | tee -a ${LOG}
echo 'Determine if bot1 or bot2 is currently inactive' | tee -a ${LOG}

setenv SETTING `${PROC_CTRL_CMD_ROBOT}/getSetting ${SET_INACTIVE_BOT}`
if ( "${SETTING}" == "bot1" ) then
    setenv NEW_INACTIVE_BOT bot2
else if ( "${SETTING}" == "bot2" ) then
    setenv NEW_INACTIVE_BOT bot1
else
    echo 'Cannot determine whether bot1 or bot2 is inactive' | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif
echo "Inactive Robot: ${SETTING}" | tee -a ${LOG}


#
# Wait for the "DB Loaded" and "Frontend Solr Indexes Loaded" flags to be set.
# Stop waiting if the number of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the flags to start release' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY1 `${PROC_CTRL_CMD_ROBOT}/getFlag ${NS_ROBOT_LOAD} ${FLAG_DB_LOADED}`
    setenv READY2 `${PROC_CTRL_CMD_ROBOT}/getFlag ${NS_ROBOT_LOAD} ${FLAG_FEIDX_LOADED}`
    setenv ABORT `${PROC_CTRL_CMD_ROBOT}/getFlag ${NS_ROBOT_LOAD} ${FLAG_ABORT}`

    if ((${READY1} == 1 && ${READY2} == 1) || ${ABORT} == 1) then
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
# Swap GlobalConfig file links.
#
date | tee -a ${LOG}
echo 'Swap GlobalConfig file links' | tee -a ${LOG}
cd ${MGI_LIVE}/webshare/config
mv GlobalConfig.old saveold
mv GlobalConfig GlobalConfig.old
mv saveold GlobalConfig

#
# Regenerate templates and GlobalConfig from webshare.
#
date | tee -a ${LOG}
echo 'Regenerate templates and GlobalConfig from webshare' | tee -a ${LOG}
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare

#
# Set the "Webshare Swapped" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Webshare Swapped' | tee -a ${LOG}
${PROC_CTRL_CMD_ROBOT}/setFlag ${NS_ROBOT_LOAD} ${FLAG_WEBSHR_SWAPPED} ${SCRIPT_NAME}

#
# Toggle the "Inactive Robot" setting.
#
date | tee -a ${LOG}
echo "Set inactive robot setting: ${NEW_INACTIVE_BOT}" | tee -a ${LOG}
${PROC_CTRL_CMD_ROBOT}/setSetting ${SET_INACTIVE_BOT} ${NEW_INACTIVE_BOT} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
