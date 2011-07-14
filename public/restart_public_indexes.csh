#!/bin/csh -f
#
#  restart_public_indexes.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for restarting the public indexes.
#
#  Usage:
#
#      restart_public_indexes.csh
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
#  Assumes:  Nothing
#
#  Implementation:
#
#      This script will perform following steps:
#
#      1) Source the configuration file to establish the environment.
#      2) Determine which public index is currently inactive.
#      3) Wait for the flag to signal that webshare has been swapped.
#      4) Regenerate templates and GlobalConfig from webshare.
#      5) Restart the inactive public JBoss server.
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
# to be restarted.
#
setenv SETTING `${PROC_CTRL_CMD_PUB}/getSetting ${SET_INACTIVE_PUB_DB}`
if ( "${SETTING}" != "pub_1" && "${SETTING}" != "pub_2") then
    echo 'Cannot determine which public index is inactive' | tee -a ${LOG}
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
# Clear the "Webshare Swapped" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: Webshare Swapped' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_PUB_LOAD} ${FLAG_WEBSHR_SWAPPED} ${SCRIPT_NAME}

#
# Regenerate templates and GlobalConfig from webshare.
#
date | tee -a ${LOG}
echo 'Regenerate templates and GlobalConfig from webshare' | tee -a ${LOG}
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare

#
# Restart the inactive public JBoss server.
#
date | tee -a ${LOG}
echo 'Restart the inactive public JBoss server' | tee -a ${LOG}
if ( "${SETTING}" == "pub_1" ) then
    ${LOADADMIN}/jboss/restartSearchtool_pub1
else
    ${LOADADMIN}/jboss/restartSearchtool_pub2
endif
sleep 60

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
