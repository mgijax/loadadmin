#!/bin/csh -f
#
#  load_robot_db.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the robot databases.
#
#  Usage:
#
#      load_robot_db.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - MGD database backup files (from /lindon/sybase)
#
#      - SNP database backup files (from /hobbiton/extra1/sybase)
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
#      2) Wait for the flag to signal that the MGD backup is available.
#      3) Load the MGD database.
#      4) Load the SNP database.
#      5) Run the dbdepends script on the inactive Python WI.
#      6) Swap Java WI cache directory links and clean out the old one.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv MGD_BACKUP /lindon/sybase/mgd.backup
setenv SNP_BACKUP /hobbiton/extra1/sybase/snp.backup

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" | tee -a ${LOG}
env | sort | tee -a ${LOG}

#
# Wait for the "MGD Backup Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MGD Backup Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_ROBOT}/getFlag ${NS_ROBOT_LOAD} ${FLAG_MGD_BACKUP}`
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
# Clear the "MGD Backup Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: MGD Backup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_ROBOT}/clearFlag ${NS_ROBOT_LOAD} ${FLAG_MGD_BACKUP} ${SCRIPT_NAME}

#
# Load MGD database and delete private data.
#
date | tee -a ${LOG}
echo "Load MGD database (${MGD_DBSERVER}..${MGD_DBNAME}) and delete private data" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} ${MGD_BACKUP} deleteprivate
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Load SNP database.
#
date | tee -a ${LOG}
echo "Load SNP database (${SNP_DBSERVER}..${SNP_DBNAME})" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${SNP_DBSERVER} ${SNP_DBNAME} ${SNP_BACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Run dbdepends script on the Python WI.
#
date | tee -a ${LOG}
echo 'Run dbdepends script on the Python WI' | tee -a ${LOG}
${MGI_LIVE}/wi/admin/dbdepends

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
# Regenerate templates and GlobalConfig from webshare.
#
date | tee -a ${LOG}
echo 'Regenerate templates and GlobalConfig from webshare' | tee -a ${LOG}
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
