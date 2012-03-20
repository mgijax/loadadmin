#!/bin/csh -f
#
#  loadPublicDB.csh
###########################################################################
#
#  Purpose:
#
#      This script is a wrapper for loading the inactive public databases.
#
#  Usage:
#
#      loadPublicDB.csh
#
#  Env Vars:
#
#      - See Configuration file (loadadmin product)
#
#      - See master.config.csh (mgiconfig product)
#
#  Inputs:
#
#      - Postgres database backup files (in ${DB_BACKUP_DIR})
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
#      2) Determine if this script is being run on the database server
#         that is currently inactive. Exit if this server is active.
#      3) Wait for the flag to signal that the Postgres backups are available.
#      4) Load the radar schema.
#      5) Load the mgd schema.
#      6) Grant modify permission on the text search tables.
#      7) Load the snp schema.
#      8) Load the fe schema.
#      9) Set the flag to signal that the databases have been loaded.
#
#  Notes:  None
#
###########################################################################

cd `dirname $0` && source ./Configuration

setenv SCRIPT_NAME `basename $0`

setenv RADAR_BACKUP ${DB_BACKUP_DIR}/radar.postgres.dump
setenv MGD_BACKUP ${DB_BACKUP_DIR}/mgd.postgres.dump
setenv SNP_BACKUP ${DB_BACKUP_DIR}/snp.postgres.dump
setenv FE_BACKUP ${DB_BACKUP_DIR}/fe.postgres.dump

setenv LOG ${LOGSDIR}/${SCRIPT_NAME}.log
rm -f ${LOG}
touch ${LOG}

echo "$0" >> ${LOG}
env | sort >> ${LOG}

#
# Determine whether pub1 or pub2 is currently inactive by checking the
# "Inactive Public" setting.
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
# the inactive database server, just end the script.
#
# NOTE: This assumes that the server name ends with "1" or "2" to match
# "pub1" or "pub2".
#
set PUB_NUM=`echo ${SETTING} | sed 's/.*\(.\)$/\1/'`
set SERVER_NUM=`uname -n | sed 's/.*\(.\)$/\1/'`

if ( "${PUB_NUM}" != "${SERVER_NUM}" ) then
    echo 'This is not the inactive database server ... exiting' | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Wait for the "Postgres Dump Ready" flag to be set. Stop waiting if the number
# of retries expires or the abort flag is found.
#
date | tee -a ${LOG}
echo 'Wait for the "Postgres Dump Ready" flag to be set' | tee -a ${LOG}

setenv RETRY ${PROC_CTRL_RETRIES}
while (${RETRY} > 0)
    setenv READY `${PROC_CTRL_CMD_PUB}/getFlag ${NS_PUB_LOAD} ${FLAG_PG_DUMP_READY}`
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
# Load the radar schema.
#
date | tee -a ${LOG}
echo "Load radar schema (${PG_DBSERVER}.${PG_DBNAME}.radar)" | tee -a ${LOG}
${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar ${RADAR_BACKUP} >> ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Load the mgd schema.
#
date | tee -a ${LOG}
echo "Load mgd schema (${PG_DBSERVER}.${PG_DBNAME}.mgd)" | tee -a ${LOG}
${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} ${PG_DBNAME} mgd ${MGD_BACKUP} >> ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Grant modify permission on the text search tables.
#
date | tee -a ${LOG}
echo "Grant modify permission on the text search tables." | tee -a ${LOG}
${PG_DBUTILS}/bin/grantTxtPerms.csh ${PG_DBSERVER} ${PG_DBNAME} >> ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Load the snp schema. Run analyze command on "pub" database.
#
date | tee -a ${LOG}
echo "Load snp schema (${PG_DBSERVER}.${PG_DBNAME}.snp)" | tee -a ${LOG}
${PG_DBUTILS}/bin/loadDB.csh -a ${PG_DBSERVER} ${PG_DBNAME} snp ${SNP_BACKUP} >> ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Load the fe schema. Run analyze command on "fe" database.
#
date | tee -a ${LOG}
echo "Load fe schema (${PG_FE_DBSERVER}.${PG_FE_DBNAME}.fe)" | tee -a ${LOG}
${PG_DBUTILS}/bin/loadDB.csh -a ${PG_FE_DBSERVER} ${PG_FE_DBNAME} fe ${FE_BACKUP} >> ${LOG}
if ( $status != 0 ) then
    echo "${SCRIPT_NAME} failed" | tee -a ${LOG}
    date | tee -a ${LOG}
    exit 1
endif

#
# Set the "DB Loaded" flag.
#
date | tee -a ${LOG}
echo 'Set process control flag: DB Loaded' | tee -a ${LOG}
${PROC_CTRL_CMD_PUB}/setFlag ${NS_PUB_LOAD} ${FLAG_DB_LOADED} ${SCRIPT_NAME}

echo "${SCRIPT_NAME} completed successfully" | tee -a ${LOG}
date | tee -a ${LOG}
exit 0
