#!/bin/csh -f
#
#  publicRelease.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper that controls the public release.
#
#  Usage:
#
#      publicRelease.csh
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
#      2) Determine whether "pub1" or "pub2" is currently inactive.
#      3) Wait for the flag to signal that the inactive databases have been
#         loaded.
#      4) Run the dbdepends script on the inactive Python WI.
#      5) Wait for the flags to signal that the public reports have been
#         generated, the inactive public QS indexes have been loaded and the
#         inactive public frontend Solr indexes have been loaded.
#      6) Swap the webshare GlobalConfig links.
#      7) Regenerate templates and GlobalConfig from webshare.
#      8) Set the flag to signal that webshare has been swapped.
#      9) Restart tomcat.
#      10) Swap Java WI cache directory links and clean out the old one.
#      11) Run gen_includes on the inactive Python WI.
#      12) Swap the links for the Python WI.
#      13) Run cleanup on the inactive Python WI (the old instance).
#      14) Refresh MGI Home.
#      15) Set the flag to signal that the WIs have been swapped.
#      16) Toggle the inactive public setting.
#      17) Wait for the flag to signal that the MouseBLAST WI has been
#          updated.
#      18) Send email notification that the public release is done.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv NOTIFY_LIST mgi

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

#
# Determine whether pub1 or pub2 is currently inactive by checking the
# "Inactive Public" setting. This setting will need to be toggled
# when the release is completed.
#
date | tee -a ${LOG}
echo 'Determine if pub1 or pub2 is currently inactive' | tee -a ${LOG}

setenv SETTING `${PROC_CTRL_CMD_PUB}/getSetting ${SET_INACTIVE_PUB}`
if ( "${SETTING}" == "pub1" ) then
    setenv NEW_PUB pub2
else if ( "${SETTING}" == "pub2" ) then
    setenv NEW_PUB pub1
else
    echo 'Cannot determine whether pub1 or pub2 is inactive' | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif
echo "Inactive Public: ${SETTING}" | tee -a ${LOG}

#
# Wait for the "DB Loaded" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "DB Loaded" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_DB_LOADED}`
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
# Run dbdepends script on the inactive Python WI.
#
date | tee -a ${LOG}
echo 'Run dbdepends script on the inactive Python WI' | tee -a ${LOG}
${MGI_LIVE}/wiinactive/admin/dbdepends

#
# Wait for the "Public Reports Ready", "QS Indexes Loaded" and
# "Frontend Solr Indexes Loaded" flags to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the flags to start release' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY1 `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_PUB_RPT_READY}`
    setenv READY2 `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_QS_LOADED}`
    setenv READY3 `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_FEIDX_LOADED}`
    setenv ABORT `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_ABORT}`

    if ((${READY1} == 1 && ${READY2} == 1 && ${READY3} == 1) || ${ABORT} == 1) then
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
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_WEBSHR_SWAPPED} ${SCRIPT_NAME}

#
# Restart tomcat
#
date | tee -a ${LOG}
echo 'Restart tomcat' | tee -a ${LOG}
${LOADADMIN}/bin/restartTomcat

#
# Swap Java WI cache directory links and clean out the old one.
#
date | tee -a ${LOG}
echo 'Swap Java WI cache directory links and clean out the old one' | tee -a ${LOG}
cd ${MGI_LIVE}
mv javawi2.cache.old saveold
mv javawi2.cache javawi2.cache.old
mv saveold javawi2.cache
rm -rf ${MGI_LIVE}/javawi2.cache.old/*

#
# Run gen_includes on the inactive Python WI.
#
date | tee -a ${LOG}
echo 'Run gen_includes on the inactive Python WI' | tee -a ${LOG}
cd ${MGI_LIVE}/wiinactive/admin
gen_includes

#
# Swap the links for the Python WI.
#
date | tee -a ${LOG}
echo 'Swap the links for the Python WI' | tee -a ${LOG}
cd ${MGI_LIVE}
mv wiinactive saveold
mv wicurrent wiinactive
mv saveold wicurrent

#
# Run cleanup on the inactive Python WI (the old instance).
#
date | tee -a ${LOG}
echo 'Run cleanup on the inactive Python WI' | tee -a ${LOG}
${MGI_LIVE}/wiinactive/admin/cleanup tmp

#
# Update stats and include files for MGI Home.
#
date | tee -a ${LOG}
echo 'Update stats and include files for MGI Home' | tee -a ${LOG}
cd ${MGI_LIVE}/mgihome/admin
gen_stats
gen_includes

#
# Set the "WI Swapped" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: WI Swapped' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_WI_SWAPPED} ${SCRIPT_NAME}

#
# Toggle the "Inactive Public" setting.
#
date | tee -a ${LOG}
echo "Set inactive public setting: ${NEW_PUB}" | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setSetting ${SET_INACTIVE_PUB} ${NEW_PUB} ${SCRIPT_NAME}

#
# Wait for the "MouseBLAST Updated" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MouseBLAST Updated" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_MBLAST_UPDATED}`
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

date | tee -a ${LOG}
echo "Send notification that the public load has completed" | tee -a ${LOG}
set dayname=`date '+%A'`
echo "This is an automated email. The public load has completed." | mailx -s "The public load has completed for $dayname" ${NOTIFY_LIST}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
