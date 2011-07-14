#!/bin/csh -f
#
#  public_release.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper that controls the public release.
#
#  Usage:
#
#      public_release.csh
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
#      This script will perform following steps:
#
#      1) Source the configuration file to establish the environment.
#      2) Determine which public database is currently inactive.
#      3) Wait for the flag to signal that the databases have been loaded.
#      4) Run the dbdepends script on the inactive Python WI.
#      5) Wait for the flags to signal that indexes have been loaded and
#         the public reports are ready.
#      6) Set the flag to signal that the public release may begin.
#      7) Swap the webshare GlobalConfig links.
#      8) Regenerate templates and GlobalConfig from webshare.
#      9) Set the flag to signal that webshare has been swapped.
#      10) Swap Java WI configuration file links.
#      11) Clean memory cache, reload config file, suggest garbage collection.
#      12) Swap Java WI cache directory links and clean out the old one.
#      13) Run gen_includes on the inactive Python WI.
#      14) Swap the links for the Python WI.
#      15) Run cleanup on the inactive Python WI (the old instance).
#      16) Update stats and include files for MGI Home.
#      17) Set the flag to signal that the WIs have been swapped.
#      18) Toggle the inactive DB setting to the opposite database.
#      19) Wait for the flag to signal that the MouseBLAST has been swapped.
#      20) Send email notification that the public release is done.
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

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

#
# Determine which public database is currently inactive by checking the
# "Inactive Public DB" setting. This setting will need to be toggled
# when the release is completed.
#
setenv SETTING `${PROC_CTRL_CMD_PUB}/getSetting ${SET_INACTIVE_PUB_DB}`
if ( "${SETTING}" == "pub_1" ) then
    setenv NEW_MGD_DB pub_2
else if ( "${SETTING}" == "pub_2" ) then
    setenv NEW_MGD_DB pub_1
else
    echo 'Cannot determine which public database is inactive' | tee -a ${LOG}
    exit 1
endif

#
# Wait for the "Public DB Loaded" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "Public DB Loaded" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_PUB_DB_LOADED}`
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
# Clear the "Public DB Loaded" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: Public DB Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_PUB_LOAD} ${FLAG_PUB_DB_LOADED} ${SCRIPT_NAME}

#
# Run dbdepends script on the inactive Python WI.
#
date | tee -a ${LOG}
echo 'Run dbdepends script on the inactive Python WI' | tee -a ${LOG}
${MGI_LIVE}/wiinactive/admin/dbdepends

#
# Wait for the "Index Loaded" and "Public Reports Ready" flags to be set.
# Stop waiting if the number of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "Index Loaded" and "Public Reports Ready" flags to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY1 `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_INDEX_LOADED}`
    setenv READY2 `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_PUB_RPT_READY}`
    setenv ABORT `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_ABORT}`

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
# Clear the "Index Loaded" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: Index Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_PUB_LOAD} ${FLAG_INDEX_LOADED} ${SCRIPT_NAME}
#
# Clear the "Public Reports Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: Public Reports Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_PUB_LOAD} ${FLAG_PUB_RPT_READY} ${SCRIPT_NAME}

#
# Set the "Public Release" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Public Release' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/setFlag ${NS_PUB_LOAD} ${FLAG_PUB_RELEASE} ${SCRIPT_NAME}

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
# Swap Java WI configuration file links.
#
date | tee -a ${LOG}
echo 'Swap Java WI configuration file links' | tee -a ${LOG}
cd ${MGI_LIVE}/javawi2/WEB-INF/classes
mv wi.config.old saveold
mv wi.config wi.config.old
mv saveold wi.config

#
# Clean memory cache, reload config file, suggest garbage collection.
#
date | tee -a ${LOG}
echo 'Clean memory cache, reload config file, suggest garbage collection' | tee -a ${LOG}
${LOADADMIN}/bin/pokeTomcat.py

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
# Toggle the "Inactive Public DB" setting.
#
date | tee -a ${LOG}
echo "Set inactive public DB setting: ${NEW_MGD_DB}" | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setSetting ${SET_INACTIVE_PUB_DB} ${NEW_MGD_DB} ${SCRIPT_NAME}

#
# Wait for the "MouseBLAST Swapped" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MouseBLAST Swapped" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_MBLAST_SWAPPED}`
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
# Clear the "MouseBLAST Swapped" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: MouseBLAST Swapped' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_PUB_LOAD} ${FLAG_MBLAST_SWAPPED} ${SCRIPT_NAME}

date | tee -a ${LOG}
echo "Send notification that the public load has completed" | tee -a ${LOG}
set dayname=`date '+%A'`
echo "This is an automated email. The public load has completed." | mailx -s "The public load has completed for $dayname" ${NOTIFY_LIST}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
