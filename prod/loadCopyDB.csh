#!/bin/csh -f
#
#  loadCopyDB.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the production copy database.
#      It uses the production backup files that are created each day at
#      the start of the nightly processing. The day of the week is used
#      to determine which backup files to use.
#
#  Usage:
#
#      loadCopyDB.csh
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
#        mgd.predailybackup OR
#        mgd.prefridaybackup OR
#        mgd.presaturdaybackup OR
#        mgd.presundaybackup
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
#      2) Wait for the flag to signal that the MGD pre-backup is available.
#      3) Determine which backup files to use, based on the day.
#      4) Load the MGD copy database.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv MGD_PREBACKUP /lindon/sybase

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

set weekday=`date '+%u'`

#
# Wait for the "MGD PreBackup Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "MGD PreBackup Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_MGD_PREBACKUP}`
    setenv ABORT `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_ABORT}`

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
# Clear the "MGD PreBackup Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: MGD PreBackup Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/clearFlag ${NS_PROD_LOAD} ${FLAG_MGD_PREBACKUP} ${SCRIPT_NAME}

#
# Determine which set of backup files to use, based on the day of the week.
#
if ( $weekday == 5 ) then
    setenv MGD_PREBACKUP ${MGD_PREBACKUP}/mgd.prefridaybackup
else if ( $weekday == 6 ) then
    setenv MGD_PREBACKUP ${MGD_PREBACKUP}/mgd.presaturdaybackup
else if ( $weekday == 7 ) then
    setenv MGD_PREBACKUP ${MGD_PREBACKUP}/mgd.presundaybackup
else
    setenv MGD_PREBACKUP ${MGD_PREBACKUP}/mgd.predailybackup
endif

#
# Load MGD copy database.
#
date | tee -a ${LOG}
echo "Load MGD copy database (${MGDCOPY_DBSERVER}..${MGDCOPY_DBNAME})" | tee -a ${LOG}
echo "Use ${MGD_PREBACKUP}" | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${MGDCOPY_DBSERVER} ${MGDCOPY_DBNAME} ${MGD_PREBACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
