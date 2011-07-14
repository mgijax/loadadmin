#!/bin/csh -f
#
#  load_public_db.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the public database(s) and
#      initiating the WI swap.
#
#  Usage:
#
#      load_public_db.csh
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
#      2) Determine which public database is currently inactive.
#      3) Wait for the flag to signal that the MGD backup is available.
#      4) Load the inactive MGD database and delete private data.
#      5) Load the inactive SNP database.
#      6) Invoke the WI swap script.
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
# Determine which public database is currently inactive by checking the
# "Inactive Public DB" setting. The inactive databases (mgd/snp) are the
# ones that need to be loaded.
#
setenv SETTING `${PROC_CTRL_CMD_PUB}/getSetting ${SET_INACTIVE_PUB_DB}`
if ( "${SETTING}" == "pub_1" ) then
    setenv MGD_DB pub_1
    setenv SNP_DB snp_1
else if ( "${SETTING}" == "pub_2" ) then
    setenv MGD_DB pub_2
    setenv SNP_DB snp_2
else
    echo 'Cannot determine which public database is inactive' | tee -a ${LOG}
    exit 1
endif

#
# Wait for the "MGD Backup Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MGD Backup Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_MGD_BACKUP}`
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
# Clear the "MGD Backup Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: MGD Backup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/clearFlag ${NS_PUB_LOAD} ${FLAG_MGD_BACKUP} ${SCRIPT_NAME}

#
# Load inactive MGD database and delete private data.
#
date | tee -a ${LOG}
echo "Load inactive MGD database (${MGD_DBSERVER}..${MGD_DB}) and delete private data" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DB} ${MGD_BACKUP} deleteprivate
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Load inactive SNP database.
#
date | tee -a ${LOG}
echo "Load inactive SNP database (${SNP_DBSERVER}..${SNP_DB})" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${SNP_DBSERVER} ${SNP_DB} ${SNP_BACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "Public DB Loaded" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Public DB Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_PUB_DB_LOADED} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
