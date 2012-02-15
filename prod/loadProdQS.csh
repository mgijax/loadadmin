#!/bin/csh -f
#
#  loadProdQS.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the production quick search
#      indexes.
#
#  Usage:
#
#      loadProdQS.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - Production index tar file (${ST_PROD_TARFILE})
#
#      - Process control flags
#
#  Outputs:
#
#      - Production indexes (${ST_PROD_INDEXES})
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
#      2) Wait for the flag to signal that the QS index tar file is
#         available.
#      3) Load the production QS indexes from the QS index tar file.
#      4) Regenerate templates and GlobalConfig from webshare.
#      5) Restart the production JBoss server.
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
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_PROD_LOAD} ${FLAG_QS_TAR_FILE}`
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
# Clear the "QS Index Tar File Ready" flag.
#
date | tee -a ${LOG}
echo 'Clear process control flag: QS Index Tar File Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PROD}/clearFlag ${NS_PROD_LOAD} ${FLAG_QS_TAR_FILE} ${SCRIPT_NAME}

#
# Remove the contents of the production index directory and reload it
# from the tar file.
#
date | tee -a ${LOG}
echo "Load production index (${ST_PROD_INDEXES})" | tee -a ${LOG}
rm -rf ${ST_PROD_INDEXES}/*
cd ${ST_PROD_INDEXES}
tar xvf ${ST_PROD_TARFILE}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Regenerate templates and GlobalConfig from webshare.
#
date | tee -a ${LOG}
echo 'Regenerate templates and GlobalConfig from webshare' | tee -a ${LOG}
cd ${MGI_LIVE}/mgiconfig/bin
gen_webshare_prod

#
# Restart the production JBoss server.
#
date | tee -a ${LOG}
echo 'Restart the production JBoss server' | tee -a ${LOG}
${LOADADMIN}/jboss/restartSearchtool_prod
sleep 60

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
