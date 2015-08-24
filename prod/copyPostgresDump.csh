#!/bin/csh -f
#
#  copyPostgresDump.csh
###########################################################################
#
#  Purpose:
#
#      This script copies the MGD Postgres dump to the public FTP site
#      and copies the MGD and SNP Postgres dumps to the adhoc server.
#
#  Usage:
#
#      copyPostgresDump.csh
#
#  Env Vars:
#
#      See Configuration file (loadadmin product)
#
#      See master.config.csh (mgiconfig product)
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
#      1) Source the configuration files to establish the environment.
#      2) Wait for the flag to signal that the Postgres dumps are available.
#      3) Copy the MGD Postgres dump to public FTP site.
#      4) Copy the MGD Postgres dump to adhoc server.
#      5) Copy the SNP Postgres dump to adhoc server.
#      6) Set the flag to signal that the Postgres dumps are ready for the
#         adhoc load.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv MGD_NOPRIVATE_BACKUP /export/dump/mgd.noprivate.postgres.dump
setenv SNP_BACKUP /export/dump/snp.postgres.dump
setenv MGD_DEST_BACKUP mgd.postgres.dump
setenv ADHOC_DIR mgi-adhoc:/export/upload

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

#
# Wait for the "Postgres Dump Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "Postgres Dump Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_PREP} ${FLAG_PG_DUMP_READY}`
    setenv ABORT `${PROC_CTRL_CMD_PROD}/getFlag ${NS_DATA_PREP} ${FLAG_ABORT}`

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
# Copy the MGD Postgres dump to the public FTP site.
#
date | tee -a ${LOG}
echo 'Copy MGD Postgres dump to public FTP site' | tee -a ${LOG}
cp -p ${MGD_NOPRIVATE_BACKUP} ${FTPROOT}/pub/database_backups/${MGD_DEST_BACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Copy the MGD Postgres dump to the adhoc server.
#
date | tee -a ${LOG}
echo 'Copy MGD Postgres dump to adhoc server' | tee -a ${LOG}
scp -p ${MGD_NOPRIVATE_BACKUP} ${ADHOC_DIR}/${MGD_DEST_BACKUP}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Copy the SNP Postgres dump to the adhoc server.
#
date | tee -a ${LOG}
echo 'Copy SNP Postgres dump to adhoc server' | tee -a ${LOG}
scp -p ${SNP_BACKUP} ${ADHOC_DIR}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "Postgres Dump Ready" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: Postgres Dump Ready' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_ADHOC_LOAD} ${FLAG_PG_DUMP_READY} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}

exit 0
